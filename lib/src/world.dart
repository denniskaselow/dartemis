part of dartemis;

class World {


  final Bag<Entity> _added;
  final Bag<Entity> _changed;
  final Bag<Entity> _deleted;
  final Bag<Entity> _enable;
  final Bag<Entity> _disable;
  final Map<Type, Manager> _managers;

  EntityManager _entityManager;
  TagManager _tagManager;
  GroupManager _groupManager;
  Bag<EntitySystem> _systemsBag;
  Bag<Manager> _managerBag;

  int delta;

  World() : _added = new Bag<Entity>(),
            _changed = new Bag<Entity>(),
            _deleted = new Bag<Entity>(),
            _enable = new Bag<Entity>(),
            _disable = new Bag<Entity>(),
            _managers = new Map<Type, Manager>(),
            _systemsBag = new Bag<EntitySystem>(),
            _managerBag = new Bag<Manager>(){
    _entityManager = new EntityManager(this);
    _tagManager = new TagManager(this);
    _groupManager = new GroupManager(this);
  }

  GroupManager get groupManager() => _groupManager;
  EntityManager get entityManager() => _entityManager;
  TagManager get tagManager() => _tagManager;

  /**
   * Allows for setting a custom [manager].
   */
  void addManager(Manager manager) {
    _managerBag.add(manager);
    _managers[manager.runtimeType] = manager;
  }

  /**
   * Returns a [Manager] of the specified [managerType].
   */
  Manager getManager(Type managerType) {
    return _managers[managerType];
  }

  /**
   * Create and return a new or reused [Entity] instance.
   */
  Entity createEntity() {
    return _entityManager._create();
  }

  /**
   * Get an [Entity] having the specified [entityId].
   */
  Entity getEntity(int entityId) {
    return _entityManager._getEntity(entityId);
  }

  EntitySystem addSystem(EntitySystem system, [bool passive = false]) {
    system._passive = passive;
    _systemsBag.add(system);
    return system;
  }

  void initialize() {
    _managerBag.forEach((manager) => manager.initialize());
    _systemsBag.forEach((system) => system.initialize());
  }

  void _check(Bag<Entity> entities, void perform(EntityObserver, Entity)) {
    entities.forEach((entity) {
      _managerBag.forEach((manager) => perform(manager, entity));
      _systemsBag.forEach((system) => perform(system, entity));
    });
    entities.clear();
  }

  void process() {
    _check(_added, (observer, entity) => observer.added(entity));
    _check(_changed, (observer, entity) => observer.changed(entity));
    _check(_disable, (observer, entity) => observer.disabled(entity));
    _check(_enable, (observer, entity) => observer.enabled(entity));
    _check(_deleted, (observer, entity) => observer.deleted(entity));

    _systemsBag.forEach((system) {
      if (!system.passive) {
        system.process();
      }
    });
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
