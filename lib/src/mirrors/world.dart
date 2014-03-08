part of dartemis_mirrors;

/**
 * The primary instance for the framework. It contains all the managers.
 *
 * You must use this to create, delete and retrieve entities.
 *
 * It is also important to set the delta each game loop iteration, and
 * initialize before game loop.
 */
class World extends core.World {

  static const Symbol QN_ENTITY_SYSTEM = #dartemis.EntitySystem;
  static const Symbol QN_MANAGER = #dartemis.Manager;

  void initializeManager(Manager manager) {
    _injectFields(manager, QN_MANAGER);
    super.initializeManager(manager);
  }

  void initializeSystem(EntitySystem system) {
    _injectFields(system, QN_ENTITY_SYSTEM);
    super.initializeSystem(system);
  }

  void _injectFields(dynamic instance, Symbol qnBaseClass, [ClassMirror cm]) {
    if (null == cm) cm = reflectClass(instance.runtimeType);
    if (cm.superclass.qualifiedName != qnBaseClass) {
      _injectFields(instance, qnBaseClass, cm.superclass);
    }
    var vmsAndTypes = cm.declarations.values.where((m) => m is VariableMirror)
        .where((m) => canAccessType(m))
        .where((m) => m.type is ClassMirror)
        .map((m) => [m, (m.type as ClassMirror).reflectedType])
        .toList(growable: false);
    var instanceMirror = reflect(instance);
    _injectManager(instanceMirror, vmsAndTypes);
    _injectSystem(instanceMirror, vmsAndTypes);
    _injectMapper(instanceMirror, vmsAndTypes);
  }

  bool canAccessType(VariableMirror vm) {
    try {
      // has to be done for http://www.dartbug.com/16070
      vm.type;
      return true;
    } catch (e) {
      // should never happen for injectable variables, so it's okay to skip
      print(
          '''
skipping ${vm.qualifiedName} for injection because type cannot be accessed
'''
          );
      return false;
    }
  }

  void _injectManager(InstanceMirror system, Iterable<List> vmsAndTypes) {
    vmsAndTypes.where((vmAndType) => _isManager(vmAndType[1]))
        .forEach((vmAndType) {
          system.setField(vmAndType[0].simpleName, getManager(vmAndType[1]));
    });
  }

  void _injectSystem(InstanceMirror system, Iterable<List> vmsAndTypes) {
    vmsAndTypes.where((vmAndType) => _isSystem(vmAndType[1]))
        .forEach((vmAndType) {
          system.setField(vmAndType[0].simpleName, getSystem(vmAndType[1]));
    });
  }

  void _injectMapper(InstanceMirror system, Iterable<List> vmsAndTypes) {
    vmsAndTypes.where((vmAndType) => _isComponentMapper(vmAndType[0]))
        .forEach((vmAndType) {
          ClassMirror tacm = (vmAndType[0].type as ClassMirror).typeArguments
              .first as ClassMirror;
          system.setField(vmAndType[0].simpleName,
              new ComponentMapper(tacm.reflectedType, this));
    });
  }

  bool _isManager(Type type) => getManager(type) != null;

  bool _isSystem(Type type) => getSystem(type) != null;

  bool _isComponentMapper(VariableMirror vm) => (vm.type as
      ClassMirror).qualifiedName == #dartemis.ComponentMapper;
}
