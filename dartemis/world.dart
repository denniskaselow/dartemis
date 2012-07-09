class World {

  SystemManager _systemManager;
  EntityManager _entityManager;
  TagManager _tagManager;
  GroupManager _groupManager;

  int delta;
  Bag<Entity> _refreshed;
  Bag<Entity> _deleted;

//  Map<Class<? extends Manager>, Manager> _managers;

  World() {
    _entityManager = new EntityManager(this);
    _systemManager = new SystemManager(this);
    _tagManager = new TagManager(this);
    _groupManager = new GroupManager(this);

    _refreshed = new Bag<Entity>();
    _deleted = new Bag<Entity>();

//    _managers = new HashMap<Class<? extends Manager>, Manager>();
  }

  GroupManager get groupManager() => _groupManager;
  SystemManager get systemManager() => _systemManager;
  EntityManager get entityManager() => _entityManager;
  TagManager get tagManager() => _tagManager;

  /**
   * Allows for setting a custom manager.
   * @param manager to be added
   */
//  void set manager(Manager manager) {
//    _managers.put(manager.getClass(), manager);
//  }

  /**
   * Returns a manager of the specified type.
   *
   * @param <T>
   * @param managerType class type of the manager
   * @return the manager
   */
//  <T extends Manager> T getManager(Class<T> managerType) {
//    return managerType.cast(_managers.get(managerType));
//  }

  /**
   * Delete the provided entity from the world.
   * @param e entity
   */
  void deleteEntity(Entity e) {
    if(!_deleted.contains(e)) {
      _deleted.add(e);
    }
  }

  /**
   * Ensure all systems are notified of changes to this entity.
   * @param e entity
   */
  void refreshEntity(Entity e) {
    _refreshed.add(e);
  }

  /**
   * Create and return a new or reused entity instance.
   * @return entity
   */
  Entity createEntity() {
    return _entityManager._create();
  }

  /**
   * Get a entity having the specified id.
   * @param entityId
   * @return entity
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
