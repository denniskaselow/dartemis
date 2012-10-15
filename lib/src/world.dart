part of dartemis;

class World {

  final Bag<Entity> _refreshed;
  final Bag<Entity> _deleted;
  final Map<Type, Manager> _managers;

  EntityManager _entityManager;
  TagManager _tagManager;
  GroupManager _groupManager;
  Bag<EntitySystem> _systemsBag;
  Bag<Manager> _managerBag;

  int delta;

  World() : _refreshed = new Bag<Entity>(),
            _deleted = new Bag<Entity>(),
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
   * Delete the provided [entity] from the world.
   */
  void deleteEntity(Entity entity) {
    if(!_deleted.contains(entity)) {
      _deleted.add(entity);
    }
  }

  /**
   * Ensure all systems are notified of changes to this [entity].
   */
  void refreshEntity(Entity entity) {
    _refreshed.add(entity);
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

  /**
   * Let framework take care of internal business.
   */
  void loopStart() {
    if(!_refreshed.isEmpty()) {
      _refreshed.forEach((entity) => _entityManager._refresh(entity));
      _refreshed.clear();
    }

    if(!_deleted.isEmpty()) {
      _deleted.forEach((entity) {
        _groupManager.remove(entity);
        _entityManager._remove(entity);
        _tagManager.remove(entity);
      });
      _deleted.clear();
    }
  }


  EntitySystem addSystem(EntitySystem system, [bool passive = false]) {
    _systemsBag.add(system);
    return system;
  }

  void initialize() {
    _managerBag.forEach((manager) => manager.initialize());
    _systemsBag.forEach((system) => system.initialize());
  }

  void process() {
    _managerBag.forEach((manager) => manager.process());
    _systemsBag.forEach((system) => system.process());
  }
}
