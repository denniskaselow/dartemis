part of dartemis;

/**
 * The primary instance for the framework. It contains all the managers.
 *
 * You must use this to create, delete and retrieve entities.
 *
 * It is also important to set the delta each game loop iteration, and initialize before game loop.
 */
class World {
  final Symbol _symbolComponentMapper = const Symbol('dartemis.ComponentMapper');
  final Symbol _symbolEntitySystem = const Symbol('dartemis.EntitySystem');
  final Symbol _symbolManager = const Symbol('dartemis.Manager');

  final EntityManager _entityManager = new EntityManager();
  final ComponentManager _componentManager = new ComponentManager();

  final Bag<Entity> _added = new Bag<Entity>();
  final Bag<Entity> _changed = new Bag<Entity>();
  final Bag<Entity> _deleted = new Bag<Entity>();
  final Bag<Entity> _enable = new Bag<Entity>();
  final Bag<Entity> _disable = new Bag<Entity>();

  final Map<Symbol, EntitySystem> _systems = new Map<Symbol, EntitySystem>();
  final List<EntitySystem> _systemsList= new List<EntitySystem>();

  final Map<Symbol, Manager> _managers = new Map<Symbol, Manager>();
  final Bag<Manager> _managersBag = new Bag<Manager>();

  num delta = 0;
  int _frame = 0;
  double _time = 0.0;

  /// Returns the current frame.
  int get frame => _frame;
  /// Returns the time that has elapsed since the game has started (sum of all
  /// deltas).
  double get time => _time;

  World() {
    addManager(_entityManager);
    addManager(_componentManager);
  }

  /**
   * Makes sure all managers systems are initialized in the order they were
   * added.
   */
  void initialize() {
    _managersBag.forEach((manager) => manager.initialize());

    _systemsList.forEach((system) {
      _injectFields(system);
      system.initialize();
    });
  }

  void _injectFields(EntitySystem system) {
    var variableMirrors = reflectClass(system.runtimeType).variables.values.where((vm) => _isClassMirror(vm));
    var systemInstanceMirror = reflect(system);
    _injectManager(systemInstanceMirror, variableMirrors);
    _injectSystem(systemInstanceMirror, variableMirrors);
    _injectMapper(systemInstanceMirror, variableMirrors);
  }  

  void _injectManager(InstanceMirror system, Iterable<VariableMirror> vms) {
    vms.where((vm) => _isManager(vm)).forEach((vm) {
      system.setField(vm.simpleName, _managers[vm.type.qualifiedName]);
    });
  }
  
  void _injectSystem(InstanceMirror system, Iterable<VariableMirror> vms) {
    vms.where((vm) => _isSystem(vm)).forEach((vm) {
      system.setField(vm.simpleName, _systems[vm.type.qualifiedName]);
    });
  }

  void _injectMapper(InstanceMirror system, Iterable<VariableMirror> vms) {
    vms.where((vm) => _isComponentMapper(vm)).forEach((vm) {
      ClassMirror tacm = (vm.type as ClassMirror).typeArguments.values.first as ClassMirror;
      system.setField(vm.simpleName, new ComponentMapper._byMirror(tacm, this));
    });
  }
  
  bool _isClassMirror(VariableMirror vm) => vm.type is ClassMirror; 

  bool _isManager(VariableMirror vm) => _isSuperclassSymbol((vm.type as ClassMirror).superclass, _symbolManager);
  
  bool _isSystem(VariableMirror vm) => _isSuperclassSymbol((vm.type as ClassMirror).superclass, _symbolEntitySystem);
  
  bool _isSuperclassSymbol(ClassMirror cm, Symbol target) {
    if (null == cm) return false;
    if (cm.qualifiedName == target) return true;
    return _isSuperclassSymbol(cm.superclass, target);
  }
  
  bool _isComponentMapper(VariableMirror vm) => vm.type.qualifiedName == _symbolComponentMapper;

  /**
   * Returns a manager that takes care of all the entities in the world.
   * entities of this world.
   */
  EntityManager get entityManager => _entityManager;

  /**
   * Returns a manager that takes care of all the components in the world.
   */
  ComponentManager get componentManager => _componentManager;

  /**
   * Add a manager into this world. It can be retrieved later. World will
   * notify this manager of changes to entity.
   */
  void addManager(Manager manager) {
    _managers[reflect(manager).type.qualifiedName] = manager;
    _managersBag.add(manager);
    manager._world = this;
  }

  /**
   * Returns a [Manager] of the specified [managerType].
   */
  Manager getManager(Type managerType) {
    return _managers[reflectClass(managerType).qualifiedName];
  }

  /**
   * Deletes the manager from this world.
   */
  void deleteManager(Manager manager) {
    _managers.remove(reflect(manager).type.qualifiedName);
    _managersBag.remove(manager);
  }

  /**
   * Create and return a new or reused [Entity] instance.
   */
  Entity createEntity() {
    return _entityManager._createEntityInstance();
  }

  /**
   * Get an [Entity] having the specified [entityId].
   */
  Entity getEntity(int entityId) {
    return _entityManager._getEntity(entityId);
  }

  /**
   * Gives you all the systems in this world for possible iteration.
   */
  ReadOnlyBag<EntitySystem> get systems => new Bag.from(_systemsList).readOnly;

  /**
   * Adds a system to this world that will be processed by World.process().
   * If [passive] is set to true the system will not be processed by the world.
   */
  EntitySystem addSystem(EntitySystem system, {bool passive : false}) {
    system.world = this;
    system._passive = passive;

    _systems[reflect(system).type.qualifiedName] = system;
    _systemsList.add(system);

    return system;
  }

  /**
   * Removed the specified system from the world.
   */
  void deleteSystem(EntitySystem system) {
    _systems.remove(reflect(system).type.qualifiedName);
    _systemsList.remove(system);
  }

  /**
   * Retrieve a system for specified system type.
   */
  EntitySystem getSystem(Type type) {
    return _systems[reflectClass(type).qualifiedName];
  }

  /**
   * Performs an action on each entity.
   */
  void _check(Bag<Entity> entities, void perform(EntityObserver, Entity)) {
    entities.forEach((entity) {
      _managersBag.forEach((manager) => perform(manager, entity));
      _systemsList.forEach((system) => perform(system, entity));
    });
    entities.clear();
  }

  /**
   * Processes all changes to entities and executes all non-passive systems.
   */
  void process() {
    _frame++;
    _time += delta;
    processEntityChanges();

    _systemsList.forEach((system) {
      if (!system.passive) {
        system.process();
      }
    });
  }

  /**
   *Processes all changes to entities.
   */
  void processEntityChanges() {
    _check(_added, (observer, entity) => observer.added(entity));
    _check(_changed, (observer, entity) => observer.changed(entity));
    _check(_disable, (observer, entity) => observer.disabled(entity));
    _check(_enable, (observer, entity) => observer.enabled(entity));
    _check(_deleted, (observer, entity) => observer.deleted(entity));

    _componentManager.clean();
  }

  /**
   * Removes all entities from the world.
   *
   * Every entity and component has to be created anew. Make sure not to reuse
   * [Component]s that were added to an [Entity] and referenced in you code
   * because they will be added to a free list and might be overwritten once a
   * new [Component] of that type is created.
   */
  void deleteAllEntities() {
    entityManager._entities.forEach((entity) {
      if (null != entity) {
        deleteEntity(entity);
      }
    });
    processEntityChanges();
  }

  /**
   * Adds a [Entity e] to this world.
   */
  void addEntity(Entity e) => _added.add(e);

  /**
   * Ensure all systems are notified of changes to this [Entity e]. If you're
   * adding a [Component] to an [Entity] after it's been added to the world, then
   * you need to invoke this method.
   */
  void changedEntity(Entity e) => _changed.add(e);

  /**
   * Delete the [Entity e] from the world.
   */
  void deleteEntity(Entity e) {
    if (!_deleted.contains(e)) {
      _deleted.add(e);
    }
  }

  /**
   * (Re)enable the [Entity e] in the world, after it having being disabled. Won't
   * do anything unless it was already disabled.
   */
  void enable(Entity e) => _enable.add(e);

  /**
   * Disable the [Entity e] from being processed. Won't delete it, it will
   * continue to exist but won't get processed.
   */
  void disable(Entity e) => _disable.add(e);
}
