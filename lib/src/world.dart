part of dartemis;

/**
 * The primary instance for the framework. It contains all the managers.
 *
 * You must use this to create, delete and retrieve entities.
 *
 * It is also important to set the delta each game loop iteration, and initialize before game loop.
 */
class World {
  final EntityManager _entityManager = new EntityManager();
  final ComponentManager _componentManager = new ComponentManager();

  final Bag<Entity> _added = new Bag<Entity>();
  final Bag<Entity> _changed = new Bag<Entity>();
  final Bag<Entity> _deleted = new Bag<Entity>();
  final Bag<Entity> _enable = new Bag<Entity>();
  final Bag<Entity> _disable = new Bag<Entity>();

  final Map<Type, EntitySystem> _systems = new Map<Type, EntitySystem>();
  final Bag<EntitySystem> _systemsBag= new Bag<EntitySystem>();

  final Map<Type, Manager> _managers = new Map<Type, Manager>();
  final Bag<Manager> _managersBag = new Bag<Manager>();

  num delta;

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
    _systemsBag.forEach((system) => system.initialize());
  }

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
    _managers[manager.runtimeType] = manager;
    _managersBag.add(manager);
    manager._world = this;
  }

  /**
   * Returns a [Manager] of the specified [managerType].
   */
  Manager getManager(Type managerType) {
    return _managers[managerType];
  }

  /**
   * Deletes the manager from this world.
   */
  void deleteManager(Manager manager) {
    _managers.remove(manager.runtimeType);
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
  ImmutableBag<EntitySystem> get systems => _systemsBag;

  /**
   * Adds a system to this world that will be processed by World.process().
   * If [passive] is set to true the system will not be processed by the world.
   */
  EntitySystem addSystem(EntitySystem system, {bool passive : false}) {
    system.world = this;
    system._passive = passive;

    _systems[system.runtimeType] = system;
    _systemsBag.add(system);

    return system;
  }

  /**
   * Removed the specified system from the world.
   */
  void deleteSystem(EntitySystem system) {
    _systems.remove(system.runtimeType);
    _systemsBag.remove(system);
  }

  /**
   * Retrieve a system for specified system type.
   */
  EntitySystem getSystem(Type type) {
    return _systems[type];
  }

  /**
   * Performs an action on each entity.
   */
  void _check(Bag<Entity> entities, void perform(EntityObserver, Entity)) {
    entities.forEach((entity) {
      _managersBag.forEach((manager) => perform(manager, entity));
      _systemsBag.forEach((system) => perform(system, entity));
    });
    entities.clear();
  }

  /**
   * Process all non-passive systems.
   */
  void process() {
    processEntityChanges();

    _componentManager.clean();

    _systemsBag.forEach((system) {
      if (!system.passive) {
        system.process();
      }
    });
  }

  void processEntityChanges() {
    _check(_added, (observer, entity) => observer.added(entity));
    _check(_changed, (observer, entity) => observer.changed(entity));
    _check(_disable, (observer, entity) => observer.disabled(entity));
    _check(_enable, (observer, entity) => observer.enabled(entity));
    _check(_deleted, (observer, entity) => observer.deleted(entity));
  }

  /**
   * Adds a [Entity e] to this world.
   */
  void addEntity(Entity e) {
    _added.add(e);
  }

  /**
   * Ensure all systems are notified of changes to this [Entity e]. If you're
   * adding a [Component] to an [Entity] after it's been added to the world, then
   * you need to invoke this method.
   */
  void changedEntity(Entity e) {
    _changed.add(e);
  }

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
  void enable(Entity e) {
    _enable.add(e);
  }

  /**
   * Disable the [Entity e] from being processed. Won't delete it, it will
   * continue to exist but won't get processed.
   */
  void disable(Entity e) {
    _disable.add(e);
  }


}
