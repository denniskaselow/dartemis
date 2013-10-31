part of dartemis;

/**
 * The primary instance for the framework. It contains all the managers.
 *
 * You must use this to create, delete and retrieve entities.
 *
 * It is also important to set the delta each game loop iteration, and initialize before game loop.
 */
class World extends core.World {
  final Symbol _symbolComponentMapper = const Symbol('dartemis.ComponentMapper');

  void initializeSystem(EntitySystem system) {
    _injectFields(system);
    super.initializeSystem(system);
  }

  void _injectFields(EntitySystem system) {
    var vmsAndTypes = reflectClass(system.runtimeType).variables.values
        .where((vm) => _isClassMirror(vm))
        .map((vm) => [vm, (vm.type as ClassMirror).reflectedType]);
    var systemInstanceMirror = reflect(system);
    _injectManager(systemInstanceMirror, vmsAndTypes);
    _injectSystem(systemInstanceMirror, vmsAndTypes);
    _injectMapper(systemInstanceMirror, vmsAndTypes);
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

  bool _isClassMirror(VariableMirror vm) => vm.type is ClassMirror;

  bool _isManager(Type type) => getManager(type) != null;

  bool _isSystem(Type type) => getSystem(type) != null;

  bool _isComponentMapper(VariableMirror vm) => (vm.type as ClassMirror).qualifiedName == _symbolComponentMapper;
}
