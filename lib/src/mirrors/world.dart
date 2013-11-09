part of dartemis_mirrors;

/**
 * The primary instance for the framework. It contains all the managers.
 *
 * You must use this to create, delete and retrieve entities.
 *
 * It is also important to set the delta each game loop iteration, and initialize before game loop.
 */
class World extends core.World {

  void initializeSystem(EntitySystem system) {
    _injectFields(system);
    super.initializeSystem(system);
  }

  void _injectFields(EntitySystem system, [ClassMirror cm]) {
    if (null == cm) cm = reflectClass(system.runtimeType);
    var vmsAndTypes = cm.declarations.values
        .where((m) => m is VariableMirror)
        .where((m) => m.type is ClassMirror)
        .map((m) => [m, (m.type as ClassMirror).reflectedType])
        .toList(growable: false);
    var systemInstanceMirror = reflect(system);
    _injectManager(systemInstanceMirror, vmsAndTypes);
    _injectSystem(systemInstanceMirror, vmsAndTypes);
    _injectMapper(systemInstanceMirror, vmsAndTypes);
    if (cm.superclass.qualifiedName != #dartemis.EntitySystem) {
      _injectFields(system, cm.superclass);
    }
  }

  void _injectManager(InstanceMirror system, Iterable<List> vmsAndTypes) {
    vmsAndTypes.where((vmAndType) => _isManager(vmAndType[1])).forEach((vmAndType) {
      system.setField(vmAndType[0].simpleName, getManager(vmAndType[1]));
    });
  }

  void _injectSystem(InstanceMirror system, Iterable<List> vmsAndTypes) {
    vmsAndTypes.where((vmAndType) => _isSystem(vmAndType[1])).forEach((vmAndType) {
      system.setField(vmAndType[0].simpleName, getSystem(vmAndType[1]));
    });
  }

  void _injectMapper(InstanceMirror system, Iterable<List> vmsAndTypes) {
    vmsAndTypes.where((vmAndType) => _isComponentMapper(vmAndType[0])).forEach((vmAndType) {
      ClassMirror tacm = (vmAndType[0].type as ClassMirror).typeArguments.first as ClassMirror;
      system.setField(vmAndType[0].simpleName, new ComponentMapper(tacm.reflectedType, this));
    });
  }

  bool _isManager(Type type) => getManager(type) != null;

  bool _isSystem(Type type) => getSystem(type) != null;

  bool _isComponentMapper(VariableMirror vm) => (vm.type as ClassMirror).qualifiedName == #dartemis.ComponentMapper;
}
