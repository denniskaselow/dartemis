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
            return new AssetWrapper(asset, analyze(content), content);
          });
        })).then((List<AssetWrapper> assets) {
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

  void processContent(AggregateTransform transform, AssetWrapper asset) {
    var mapperInitializer = new FieldInitializingAstVisitor(_nodes, asset);
    asset.unit.visitChildren(mapperInitializer);
    if (mapperInitializer._modified) {
      transform.addOutput(new Asset.fromString(asset.asset.id, asset.content));
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

class AssetWrapper {
  Asset asset;
  CompilationUnit unit;
  String content;
  int _offset = 0;
  AssetWrapper(this.asset, this.unit, this.content);

  void insert(int pos, String toInsert) {
    content = content.substring(0, pos + _offset) + toInsert + content.substring(pos + _offset);
    _offset += toInsert.length;
  }

  void insertAtCursor(String toInsert) {
    content = content.replaceFirst(_cursor, toInsert);
    _offset += toInsert.length - _cursor.length;
  }

  void replace(String from, String to, int pos) {
    content = content.replaceFirst(from, to, pos + _offset);
    _offset += to.length - from.length;
  }
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

class FieldInitializingAstVisitor extends SimpleAstVisitor<AstNode> {

  Map<String, ClassHierarchyNode> _nodes;
  AssetWrapper _assetWrapper;
  var _modified = false;

  FieldInitializingAstVisitor(this._nodes, this._assetWrapper);

  @override
  ClassDeclaration visitClassDeclaration(ClassDeclaration node) {
    var className = node.name.name;
    if (_isOfType(_nodes, className, 'EntitySystem') || _isOfType(_nodes, className, 'Manager')) {
      var fieldCollector = new FieldCollectingAstVisitor(_nodes);
      var callSuperInitialize = false;
      node.visitChildren(fieldCollector);
      if (fieldCollector.mappers.length > 0 ||
          fieldCollector.managers.length > 0 ||
          fieldCollector.systems.length > 0 ) {
        var initializeMethodDeclaration = node.getMethod('initialize');
        if (null == initializeMethodDeclaration) {
          _assetWrapper.insert(node.endToken.offset, _initializeTemplate);
          _modified = true;
          callSuperInitialize = true;
        } else {
          var posOfOpeningBrace = initializeMethodDeclaration.body.beginToken.offset;
          _assetWrapper.insert(posOfOpeningBrace + 1, _cursor);
        }
        fieldCollector.mappers.forEach((mapper) {
          var mapperName = mapper.fields.variables[0].name.name;
          var mapperType = mapper.fields.type.typeArguments.arguments[0].name.name;
          _assetWrapper.insertAtCursor(_mapperInitializer(mapperName, mapperType));
          _modified = true;
        });
        var initField = (FieldDeclaration node, String initializer(String name, String type)) {
          var name = node.fields.variables[0].name.name;
          var type = node.fields.type.name.name;
          _assetWrapper.insertAtCursor(initializer(name, type));
          _modified = true;
        };
        fieldCollector.managers.forEach((manager) => initField(manager, (String name, String type) => _managerInitializer(name, type)));
        fieldCollector.systems.forEach((system) => initField(system, (String name, String type) => _systemInitializer(name, type)));
        _assetWrapper.insertAtCursor('\n  ');
      }
    } else if (_isOfType(_nodes, className, 'Component')) {
      _assetWrapper.replace('Component', 'PooledComponent', node.extendsClause.superclass.offset);
      _assetWrapper.insert(node.leftBracket.offset + 1, _pooledComponentTemplate(className));
      _assetWrapper.insertAtCursor('\n  ');
      _modified = true;
    }
    return node;
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

const String _cursor = '|-dartemisTransformerCursor-|';
const String _initializeTemplate = '''
  @override
  void initialize() {
    super.initialize();$_cursor}
''';
String _pooledComponentTemplate(String className) => '''

  ${className}._();
  factory ${className}() {
    ${className} pooledComponent = new Pooled.of(${className}, _ctor);
    return pooledComponent;
  }
  static ${className} _constructor() => new ${className}._();
''';

String _mapperInitializer(String name, String type) => '\n    $name = new Mapper<$type>($type, world);$_cursor';
String _managerInitializer(String name, String type) => '\n    $name = world.getManager($type);$_cursor';
String _systemInitializer(String name, String type) => '\n    $name = world.getSystem($type);$_cursor';
