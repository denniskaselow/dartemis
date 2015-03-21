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
  final DartFormatter formatter = new DartFormatter();

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
            return new AssetWrapper(asset, analyze(content));
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
    var mapperInitializer = new ClassModifyingAstVisitor(_nodes);
    asset.unit.visitChildren(mapperInitializer);
    if (mapperInitializer._modified) {
      transform.addOutput(new Asset.fromString(asset.asset.id, formatter.format(asset.unit.toSource())));
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

class ClassModifyingAstVisitor extends SimpleAstVisitor<AstNode> {

  Map<String, ClassHierarchyNode> _nodes;
  var _modified = false;
  InitializeMethodConverter initializeMethodConverter;
  var componentToPooledComponentConverter = new ComponentToPooledComponentConverter();

  ClassModifyingAstVisitor(this._nodes) {
    initializeMethodConverter = new InitializeMethodConverter(_nodes);
  }

  @override
  ClassDeclaration visitClassDeclaration(ClassDeclaration node) {
    var className = node.name.name;
    if (_isOfType(_nodes, className, 'EntitySystem') || _isOfType(_nodes, className, 'Manager')) {
      _modified = initializeMethodConverter.convert(node) || _modified;
    } else if (_isOfType(_nodes, className, 'Component')
        && !_isOfType(_nodes, className, 'PooledComponent')
        && className != 'PooledComponent') {
      _modified = componentToPooledComponentConverter.convert(node) || _modified;
    }
    return node;
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