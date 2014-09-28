part of transformer;

/// This transformer will create/assign [Mapper], [EntitySystem] and [Manager]
/// instances in the [initialize] methods of your [Manager]s and [EntitySystem]s.
///
/// If you are importing other libraries with [Manager]s or [EntitySystem]s which you
/// are using in your own code, you have to inform the transformer about them by passing
/// a list of those libraries to the transformer:
///
///     transformers:
///     - dartemis
///         additionalLibraries:
///         - otherLib/otherLib.dart
///         - moreLibs/moreLibs.dart
///
/// If those libraries need to be transformed, you have to add the transformer to
/// their `pubspec.yaml`.
class DartemisTransformer extends AggregateTransformer implements DeclaringAggregateTransformer {

  Map<String, ClassHierarchyNode> _nodes = {'DelayedEntityProcessingSystem': new ClassHierarchyNode('DelayedEntityProcessingSystem', 'EntitySystem'),
                                            'EntityProcessingSystem': new ClassHierarchyNode('EntityProcessingSystem', 'EntitySystem'),
                                            'IntervalEntityProcessingSystem': new ClassHierarchyNode('IntervalEntityProcessingSystem', 'EntitySystem'),
                                            'IntervalEntitySystem': new ClassHierarchyNode('IntervalEntitySystem', 'EntitySystem'),
                                            'VoidEntitySystem': new ClassHierarchyNode('VoidEntitySystem', 'EntitySystem'),
                                            'GroupManager': new ClassHierarchyNode('GroupManager', 'Manager'),
                                            'PlayerManager': new ClassHierarchyNode('PlayerManager', 'Manager'),
                                            'TagManager': new ClassHierarchyNode('TagManager', 'Manager'),
                                            'TeamManager': new ClassHierarchyNode('TeamManager', 'Manager'),
                                            };
  final BarbackSettings _settings;

  DartemisTransformer.asPlugin(this._settings);

  @override
  apply(AggregateTransform transform) {
    List<String> additionalLibraris = [];
    if (null != _settings.configuration && null != _settings.configuration['additionalLibraries']) {
      additionalLibraris.addAll(_settings.configuration['additionalLibraries']);
    }
    return Future.forEach(additionalLibraris, (String additionalLibrary) {
      var assetId = new AssetId.parse(additionalLibrary.replaceFirst('/', '|lib/'));
      return transform.getInput(assetId).then((asset) {
        return asset.readAsString().then((content) {
          var partPaths = [assetId.path];
          partPaths.addAll(collectPartsContent(content));
          return Future.forEach(partPaths, (partPath) {
            return transform.getInput(new AssetId(assetId.package, partPath)).then((partAsset) {
              return partAsset.readAsString().then((partContent) {
                analyze(partContent);
              });
            });
          });
        });
      });
    }).then((_) {
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
    });
  }

  List<String> collectPartsContent(String content) {
    var libUnit = parseCompilationUnit(content);
    var partFinder = new PartFindingVisitor();
    libUnit.visitChildren(partFinder);
    return partFinder.partPaths;
  }

  CompilationUnit analyze(String content) {
    var unit = parseCompilationUnit(content);
    var builder = new ClassHierarchyBuildingVisitor();
    unit.visitChildren(builder);
    _nodes.addAll(builder.nodes);
    return unit;
  }

  void processContent(AggregateTransform transform, AssetWithCompilationUnit asset) {
    var mapperInitializer = new MapperInitializingAstVisitor(_nodes);
    asset.unit.visitChildren(mapperInitializer);
    if (mapperInitializer._modified) {
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

class PartFindingVisitor extends SimpleAstVisitor {
  List<String> partPaths = [];

  @override
  visitPartDirective(PartDirective node) {
    partPaths.add('lib/${node.uri.stringValue}');
  }
}

class ClassHierarchyBuildingVisitor extends SimpleAstVisitor {
  Map<String, ClassHierarchyNode> nodes = {};

  @override
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

  Map<String, ClassHierarchyNode> _nodes;
  var _modified = false;

  MapperInitializingAstVisitor(this._nodes);

  @override
  ClassDeclaration visitClassDeclaration(ClassDeclaration node) {
    if (_isOfType(_nodes, node.name.name, 'EntitySystem') || _isOfType(_nodes, node.name.name, 'Manager')) {
      var fieldCollector = new FieldCollectingAstVisitor(_nodes);
      var callSuperInitialize = false;
      node.visitChildren(fieldCollector);
      if (fieldCollector.mappers.length > 0 ||
          fieldCollector.managers.length > 0 ||
          fieldCollector.systems.length > 0 ) {
        var initializeMethodDeclaration = node.getMethod('initialize');
        if (null == node.getMethod('initialize')) {
          initializeMethodDeclaration = _createInitializeMethodDeclaration();
          node.members.add(initializeMethodDeclaration);
          _modified = true;
          callSuperInitialize = true;
        }
        fieldCollector.mappers.forEach((mapper) {
          var mapperName = mapper.fields.variables[0].name.name;
          var mapperType = mapper.fields.type.typeArguments.arguments[0].name.name;
          (initializeMethodDeclaration.body as BlockFunctionBody).block.statements.insert(0, _createMapperAssignment(mapperName, mapperType));
          _modified = true;
        });
        var initField = (FieldDeclaration node, ExpressionStatement createAssignment(String name, String type)) {
          var managerName = node.fields.variables[0].name.name;
          var managerType = node.fields.type.name.name;
          (initializeMethodDeclaration.body as BlockFunctionBody).block.statements.insert(0, createAssignment(managerName, managerType));
          _modified = true;
        };
        fieldCollector.managers.forEach((manager) => initField(manager, (String name, String type) => _createManagerAssignment(name, type)));
        fieldCollector.systems.forEach((system) => initField(system, (String name, String type) => _createSystemAssignment(name, type)));
        if (callSuperInitialize) {
          (initializeMethodDeclaration.body as BlockFunctionBody).block.statements.insert(0, _createSuperInitialize());
        }
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
    var leftHandSide = new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, mapperName, 0));
    var keyword = new KeywordToken(Keyword.NEW, 0);
    var arguments = [new TypeName(new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, mapperType, 0)), null)];
    var typeArguments = new TypeArgumentList(new Token(TokenType.LT, 0), arguments, new Token(TokenType.GT, 0));
    var period = null;
    var name = null;
    var constructorName = new ConstructorName(new TypeName(new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, 'Mapper', 0)), typeArguments), period, name);
    var argumentList = new ArgumentList(new BeginToken(TokenType.OPEN_PAREN, 0), [new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, mapperType, 0)), new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, 'world', 0))], new Token(TokenType.CLOSE_PAREN, 0));
    var rightHandSide = new InstanceCreationExpression(keyword, constructorName, argumentList);
    var assigmentStatement = new AssignmentExpression(leftHandSide, new Token(TokenType.EQ, 0), rightHandSide);
    return new ExpressionStatement(assigmentStatement, new Token(TokenType.SEMICOLON, 0));
  }

  ExpressionStatement _createManagerAssignment(String managerName, String managerType) =>
    _createAssignmentFromWorldMethod(managerName, managerType, 'getManager');

  ExpressionStatement _createSystemAssignment(String systemName, String systemType) =>
    _createAssignmentFromWorldMethod(systemName, systemType, 'getSystem');

  ExpressionStatement _createAssignmentFromWorldMethod(String fieldName, String fieldType, String worldMethod) {
    var leftHandSide = new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, fieldName, 0));
    var target = new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, 'world', 0));
    var period = new Token(TokenType.PERIOD, 0);
    var methodName = new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, worldMethod, 0));
    var argumentList = new ArgumentList(new BeginToken(TokenType.OPEN_PAREN, 0), [new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, fieldType, 0))], new Token(TokenType.CLOSE_PAREN, 0));
    var rightHandSide = new MethodInvocation(target, period, methodName, argumentList);
    var assigmentStatement = new AssignmentExpression(leftHandSide, new Token(TokenType.EQ, 0), rightHandSide);
    return new ExpressionStatement(assigmentStatement, new Token(TokenType.SEMICOLON, 0));
  }

  ExpressionStatement _createSuperInitialize() {
    var target = new SimpleIdentifier(new KeywordToken(Keyword.SUPER, 0));
    var period = new Token(TokenType.PERIOD, 0);
    var methodName = new SimpleIdentifier(new StringToken(TokenType.IDENTIFIER, 'initialize', 0));
    var argumentList = new ArgumentList(new BeginToken(TokenType.OPEN_PAREN, 0), [], new Token(TokenType.CLOSE_PAREN, 0));
    var expression = new MethodInvocation(target, period, methodName, argumentList);
    return new ExpressionStatement(expression, new Token(TokenType.SEMICOLON, 0));
  }
}

class FieldCollectingAstVisitor extends SimpleAstVisitor {
  List<FieldDeclaration> mappers = <FieldDeclaration>[];
  List<FieldDeclaration> managers = <FieldDeclaration>[];
  List<FieldDeclaration> systems = <FieldDeclaration>[];
  Map<String, ClassHierarchyNode> nodes;

  FieldCollectingAstVisitor(this.nodes);

  @override
  visitFieldDeclaration(FieldDeclaration node) {
    if (null != node.fields.type) {
      var typeName = node.fields.type.name.name;
      if (typeName == 'Mapper') {
        mappers.add(node);
      } else if (_isOfType(nodes, typeName, 'Manager')) {
        managers.add(node);
      } else if (_isOfType(nodes, typeName, 'EntitySystem')) {
        systems.add(node);
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