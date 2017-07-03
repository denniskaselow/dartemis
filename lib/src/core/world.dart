part of dartemis;

/// The primary instance for the framework. It contains all the managers.
///
/// You must use this to create, delete and retrieve entities.
///
/// It is also important to set the delta each game loop iteration, and
/// initialize before game loop.
class World {
  final EntityManager _entityManager = new EntityManager();
  final ComponentManager _componentManager = new ComponentManager();

  final Bag<Entity> _added = new EntityBag();
  final Bag<Entity> _changed = new EntityBag();
  final Bag<Entity> _deleted = new EntityBag();
  final Bag<Entity> _enable = new EntityBag();
  final Bag<Entity> _disable = new EntityBag();

  final Map<Type, EntitySystem> _systems = <Type, EntitySystem>{};
  final List<EntitySystem> _systemsList = <EntitySystem>[];

  final Map<Type, Manager> _managers = <Type, Manager>{};
  final Bag<Manager> _managersBag = new Bag<Manager>();

  final Map<int, int> _frame = {0: 0};
  final Map<int, double> _time = {0: 0.0};
  num delta = 0;

  /// World-related properties that can be written and read by the user.
  final Map<String, Object> properties = <String, Object>{};

  World() {
    addManager(_entityManager);
    addManager(_componentManager);
  }

  /// Returns the current frame/how often the systems in [group] have been processed.
  int frame([int group = 0]) => _frame[group];

  /// Returns the time that has elapsed for the systems in the [group] since the game has
  /// started (sum of all deltas).
  double time([int group = 0]) => _time[group];

  /// Makes sure all managers systems are initialized in the order they were
  /// added.
  void initialize() {
    _managersBag.forEach(initializeManager);
    _systemsList.forEach(initializeSystem);
  }

  void initializeManager(Manager manager) => manager.initialize();

  void initializeSystem(EntitySystem system) => system.initialize();

  /// Returns a manager that takes care of all the entities in the world.
  /// entities of this world.
  EntityManager get entityManager => _entityManager;

  /// Returns a manager that takes care of all the components in the world.
  ComponentManager get componentManager => _componentManager;

  /// Add a manager into this world. It can be retrieved later. World will
  /// notify this manager of changes to entity.
  void addManager(Manager manager) {
    _managers[manager.runtimeType] = manager;
    _managersBag.add(manager);
    manager._world = this;
  }

  /// Returns a [Manager] of the specified [managerType].
  Manager getManager(Type managerType) => _managers[managerType];

  /// Deletes the manager from this world.
  void deleteManager(Manager manager) {
    _managers.remove(manager.runtimeType);
    _managersBag.remove(manager);
  }

  /// Create and return a new or reused [Entity] instance, optionally with
  /// [components].
  Entity createEntity([List<Component> components = const []]) {
    final e = _entityManager._createEntityInstance();
    components.forEach(e.addComponent);
    return e;
  }

  /// Creates an [Entity] with [components], adds it to the world and returns
  /// it.
  ///
  /// You don't have to call [Entity.addToWorld()] if you use this.
  Entity createAndAddEntity([List<Component> components = const []]) {
    final e = createEntity(components);
    addEntity(e);
    return e;
  }

  /// Get an [Entity] having the specified [entityId].
  Entity getEntity(int entityId) => _entityManager._getEntity(entityId);

  /// Gives you all the systems in this world for possible iteration.
  Iterable<EntitySystem> get systems => _systemsList;

  /// Adds a [system] to this world that will be processed by [process()].
  /// If [passive] is set to true the [system] will not be processed by the world.
  /// If a [group] is set, this [system] will only be processed when calling [process()] with the same [group].
  EntitySystem addSystem(EntitySystem system,
      {bool passive: false, int group: 0}) {
    system
      .._world = this
      .._passive = passive
      .._group = group;

    _systems[system.runtimeType] = system;
    _systemsList.add(system);
    _time.putIfAbsent(group, () => 0.0);
    _frame.putIfAbsent(group, () => 0);

    return system;
  }

  /// Removed the specified system from the world.
  void deleteSystem(EntitySystem system) {
    _systems.remove(system.runtimeType);
    _systemsList.remove(system);
  }

  /// Retrieve a system for specified system type.
  EntitySystem getSystem(Type type) => _systems[type];

  /// Performs an action on each entity.
  void _check(Bag<Entity> entities, void perform(entityObserver, entity)) {
    entities
      ..forEach((entity) {
        _managersBag.forEach((manager) => perform(manager, entity));
        _systemsList.forEach((system) => perform(system, entity));
      })
      ..clear();
  }

  /// Processes all changes to entities and executes all non-passive systems.
  void process([int group = 0]) {
    _frame[group]++;
    _time[group] += delta;
    processEntityChanges();

    _systemsList
        .where((system) => !system.passive && system.group == group)
        .forEach((system) {
      system.process();
    });
  }

  /// Processes all changes to entities.
  void processEntityChanges() {
    _check(_added, (observer, entity) => observer.added(entity));
    _check(_changed, (observer, entity) => observer.changed(entity));
    _check(_disable, (observer, entity) => observer.disabled(entity));
    _check(_enable, (observer, entity) => observer.enabled(entity));
    _check(_deleted, (observer, entity) => observer.deleted(entity));

    _componentManager.clean();
  }

  /// Removes all entities from the world.
  ///
  /// Every entity and component has to be created anew. Make sure not to reuse
  /// [Component]s that were added to an [Entity] and referenced in you code
  /// because they will be added to a free list and might be overwritten once a
  /// new [Component] of that type is created.
  void deleteAllEntities() {
    entityManager._entities.forEach((entity) {
      if (null != entity) {
        deleteEntity(entity);
      }
    });
    processEntityChanges();
  }

  /// Adds a [Entity entity] to this world.
  void addEntity(Entity entity) => _added.add(entity);

  /// Ensure all systems are notified of changes to this [Entity entity]. If you're
  /// adding a [Component] to an [Entity] after it's been added to the world,
  /// then you need to invoke this method.
  void changedEntity(Entity entity) => _changed.add(entity);

  /// Delete the [Entity entity] from the world.
  void deleteEntity(Entity entity) => _deleted.add(entity);

  /// (Re)enable the [Entity entity] in the world, after it having being disabled.
  /// Won't do anything unless it was already disabled.
  void enable(Entity entity) => _enable.add(entity);

  /// Disable the [Entity entity] from being processed. Won't delete it, it will
  /// continue to exist but won't get processed.
  void disable(Entity entity) => _disable.add(entity);

  /// Returns the value for [key] from [properties].
  Object operator [](String key) => properties[key];

  /// Set the [value] of [key] in [properties].
  void operator []=(String key, Object value) {
    properties[key] = value;
  }

  /// Destroy the [World] by destroying all [EntitySystem]s and [Manager]s.
  void destroy() {
    _systemsList.forEach((system) => system.destroy());
    _managersBag.forEach((manager) => manager.destroy());
  }
}
