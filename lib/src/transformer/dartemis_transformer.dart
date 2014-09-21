part of transformer;

class DartemisTransformer extends AggregateTransformer implements DeclaringAggregateTransformer {

  Map<String, ClassHierarchyNode> nodes = {};

  DartemisTransformer.asPlugin();

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
    if (_isOfType(nodes, node.name.name, 'EntitySystem') || _isOfType(nodes, node.name.name, 'Manager')) {
      var fieldCollector = new FieldCollectingAstVisitor(nodes);
      node.visitChildren(fieldCollector);
      if (fieldCollector.mappers.length > 0 || fieldCollector.managers.length > 0) {
        var initializeMethodDeclaration = node.getMethod('initialize');
        if (null == node.getMethod('initialize')) {
          initializeMethodDeclaration = _createInitializeMethodDeclaration();
          node.members.add(initializeMethodDeclaration);
          modified = true;
        }
        fieldCollector.mappers.forEach((mapper) {
          var mapperName = mapper.fields.variables[0].name.name;
          var mapperType = mapper.fields.type.typeArguments.arguments[0].name.name;
          (initializeMethodDeclaration.body as BlockFunctionBody).block.statements.insert(0, _createMapperAssignment(mapperName, mapperType));
          modified = true;
        });
        fieldCollector.managers.forEach((manager) {
          var managerName = manager.fields.variables[0].name.name;
          var managerType = manager.fields.type.name.name;
          (initializeMethodDeclaration.body as BlockFunctionBody).block.statements.insert(0, _createManagerAssignment(managerName, managerType));
          modified = true;
        });
      }
    }
    return node;
  }

  MethodDeclaration _createInitializeMethodDeclaration() {
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

  ExpressionStatement _createMapperAssignment(String mapperName, String mapperType) {
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

  ExpressionStatement _createManagerAssignment(String managerName, String managerType) {
    var rightHandSide = new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, managerName, 0));
    var target = new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, 'world', 0));
    var period = new Token(TokenType.PERIOD, 0);
    var methodName = new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, 'getManager', 0));
    var argumentList = new ArgumentList(new BeginToken(TokenType.OPEN_PAREN, 0), [new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, managerType, 0))], new Token(TokenType.CLOSE_PAREN, 0));
    var leftHandSide = new MethodInvocation(target, period, methodName, argumentList);
    var assigmentStatement = new AssignmentExpression(rightHandSide, new Token(TokenType.EQ, 0), leftHandSide);
    return new ExpressionStatement(assigmentStatement, new Token(TokenType.SEMICOLON, 0));
  }

}

class FieldCollectingAstVisitor extends SimpleAstVisitor {
  List<FieldDeclaration> mappers = <FieldDeclaration>[];
  List<FieldDeclaration> managers = <FieldDeclaration>[];
  Map<String, ClassHierarchyNode> nodes;

  FieldCollectingAstVisitor(this.nodes);

  visitFieldDeclaration(FieldDeclaration node) {
    if (null != node.fields.type) {
      var typeName = node.fields.type.name.name;
      if (typeName == 'Mapper') {
        mappers.add(node);
      } else if (_isOfType(nodes, typeName, 'Manager')) {
        managers.add(node);
      }
    }
  }
}

bool _isOfType(Map<String, ClassHierarchyNode> nodes, String className, String superclassName) {
  if (null == nodes[className] || null == nodes[className].parent) {
    return false;
  } else if (nodes[className].parent == superclassName) {
    return true;
  }
  return _isOfType(nodes, nodes[className].parent, superclassName);
}