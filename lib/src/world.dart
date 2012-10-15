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
      for(int i = 0; _refreshed.size > i; i++) {
        _entityManager._refresh(_refreshed[i]);
      }
      _refreshed.clear();
    }

    if(!_deleted.isEmpty()) {
      for(int i = 0; _deleted.size > i; i++) {
        Entity e = _deleted[i];
        _groupManager.remove(e);
        _entityManager._remove(e);
        _tagManager.remove(e);
      }
      _deleted.clear();
    }
  }


  EntitySystem addSystem(EntitySystem system) {
    _systemsBag.add(system);
    return system;
  }

  void initialize() {
    for (int i = 0; i < _managerBag.size; i++) {
      _managerBag[i].initialize();
    }
    for (int i = 0; i < _systemsBag.size; i++) {
      _systemsBag[i].initialize();
    }
  }

  void process() {
    for (int i = 0; i < _managerBag.size; i++) {
      _managerBag[i].process();
    }
    for (int i = 0; i < _systemsBag.size; i++) {
      _systemsBag[i].process();
    }
  }
}
