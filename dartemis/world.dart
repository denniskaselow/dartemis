class World {

  final Bag<Entity> _refreshed;
  final Bag<Entity> _deleted;  
  final Map<Type, Manager> _managers;
  
  SystemManager _systemManager;
  EntityManager _entityManager;
  TagManager _tagManager;
  GroupManager _groupManager;

  int delta;

  World() : _refreshed = new Bag<Entity>(),
            _deleted = new Bag<Entity>(),
            _managers = new Map<Type, Manager>() {
    _entityManager = new EntityManager(this);
    _systemManager = new SystemManager(this);
    _tagManager = new TagManager(this);
    _groupManager = new GroupManager(this);
  }

  GroupManager get groupManager() => _groupManager;
  SystemManager get systemManager() => _systemManager;
  EntityManager get entityManager() => _entityManager;
  TagManager get tagManager() => _tagManager;

  /**
   * Allows for setting a custom [manager].
   */
  void addManager(Manager manager) {
    _managers[manager.type] = manager;
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

}
