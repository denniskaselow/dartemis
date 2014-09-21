part of transformer;

class SystemTransformer extends AggregateTransformer implements DeclaringAggregateTransformer {

  Map<String, ClassHierarchyNode> nodes = {};

  SystemTransformer.asPlugin();

  @override
  apply(AggregateTransform transform) {
    return transform.primaryInputs.toList().then((assets) {
      return Future.wait(assets.map((asset) {
        return asset.readAsString().then((content) {
          return new AssetWithCompilationUnit(asset, analyze(content));
        });
      })).then((List<AssetWithCompilationUnit> assets) {
        assets.forEach((asset) {
          processContent(transform, asset);
        });
      });
    });
  }

  CompilationUnit analyze(String content) {
    var unit = parseCompilationUnit(content);
    var builder = new ClassHierarchyBuildingVisitor();
    unit.visitChildren(builder);
    nodes.addAll(builder.nodes);
    return unit;
  }

  void processContent(AggregateTransform transform, AssetWithCompilationUnit asset) {
    var mapperInitializer = new MapperInitializingAstVisitor(nodes);
    asset.unit.visitChildren(mapperInitializer);
    if (mapperInitializer.modified) {
      transform.addOutput(new Asset.fromString(asset.asset.id, asset.unit.toSource()));
    }
  }

  @override
  declareOutputs(DeclaringAggregateTransform transform) {
    transform.primaryIds.forEach((assetId) => transform.declareOutput(assetId));
  }

  @override
  classifyPrimary(AssetId id) {
    if (id.extension == '.dart') {
      return 'dart';
    }
    return null;
  }
}

class AssetWithCompilationUnit {
  Asset asset;
  CompilationUnit unit;
  AssetWithCompilationUnit(this.asset, this.unit);
}

class ClassHierarchyBuildingVisitor extends SimpleAstVisitor {
  Map<String, ClassHierarchyNode> nodes = {};

  visitClassDeclaration(ClassDeclaration node) {
    if (null == node.extendsClause) return;
    nodes[node.name.name] = new ClassHierarchyNode(node.name.name, node.extendsClause.superclass.name.name);
  }
}

class ClassHierarchyNode {
  String name;
  String parent;
  ClassHierarchyNode(this.name, this.parent);
}

class MapperInitializingAstVisitor extends SimpleAstVisitor<AstNode> {

  Map<String, ClassHierarchyNode> nodes;
  var modified = false;

  MapperInitializingAstVisitor(this.nodes);

  @override
  ClassDeclaration visitClassDeclaration(ClassDeclaration node) {
    if (isEntitySystem(node.name.name)) {
      var fieldCollector = new FieldCollectingAstVisitor();
      node.visitChildren(fieldCollector);
      if (fieldCollector.mappers.length > 0) {
        var initializeMethodDeclaration = node.getMethod('initialize');
        if (null == node.getMethod('initialize')) {
          initializeMethodDeclaration = createInitializeMethodDeclaration();
          node.members.add(initializeMethodDeclaration);
          modified = true;
        }
        fieldCollector.mappers.forEach((mapper) {
          var mapperName = mapper.fields.variables[0].name.name;
          var mapperType = mapper.fields.type.typeArguments.arguments[0].name.name;
          (initializeMethodDeclaration.body as BlockFunctionBody).block.statements.insert(0, createMapperAssignment(mapperName, mapperType));
          modified = true;
        });
      }
    }
    return node;
  }

  bool isEntitySystem(String className) {
    if (null == nodes[className] || null == nodes[className].parent) {
      return false;
    } else if (nodes[className].parent == 'EntitySystem') {
      return true;
    }
    return isEntitySystem(nodes[className].parent);
  }
}

class FieldCollectingAstVisitor extends SimpleAstVisitor {
  List<FieldDeclaration> mappers = <FieldDeclaration>[];

  visitFieldDeclaration(FieldDeclaration node) {
    if (null != node.fields.type && node.fields.type.name.name == 'Mapper') {
      mappers.add(node);
    }
  }
}


MethodDeclaration createInitializeMethodDeclaration() {
  var comment = null;
  var metadata = [new Annotation(new Token(TokenType.AT, 0), new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, 'override', 0)), null, null, null)];
  var externalKeyword = null;
  var modifierKeyword = null;
  var returnType = new TypeName(new SimpleIdentifier(new KeywordToken(Keyword.VOID, 0)), null);
  var propertyKeyword = null;
  var operatorKeyword = null;
  var name = new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, 'initialize', 0));
  var parameters = new FormalParameterList(new BeginToken(TokenType.OPEN_PAREN, 0), null, null, null, new Token(TokenType.CLOSE_PAREN, 0));
  var block = new Block(new BeginToken(TokenType.OPEN_CURLY_BRACKET, 0), [], new Token(TokenType.CLOSE_CURLY_BRACKET, 0));
  var body = new BlockFunctionBody(null, null, block);
  return new MethodDeclaration(comment, metadata, externalKeyword, modifierKeyword, returnType, propertyKeyword, operatorKeyword, name, parameters, body);
}

ExpressionStatement createMapperAssignment(String mapperName, String mapperType) {
  var rightHandSide = new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, mapperName, 0));
  var keyword = new KeywordToken(Keyword.NEW, 0);
  var arguments = [new TypeName(new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, mapperType, 0)), null)];
  var typeArguments = new TypeArgumentList(new Token(TokenType.LT, 0), arguments, new Token(TokenType.GT, 0));
  var period = null;
  var name = null;
  var constructorName = new ConstructorName(new TypeName(new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, 'Mapper', 0)), typeArguments), period, name);
  var argumentList = new ArgumentList(new BeginToken(TokenType.OPEN_PAREN, 0), [new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, mapperType, 0)), new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, 'world', 0))], new Token(TokenType.CLOSE_PAREN, 0));
  var leftHandSide = new InstanceCreationExpression(keyword, constructorName, argumentList);
  var assigmentStatement = new AssignmentExpression(rightHandSide, new Token(TokenType.EQ, 0), leftHandSide);
  return new ExpressionStatement(assigmentStatement, new Token(TokenType.SEMICOLON, 0));
}