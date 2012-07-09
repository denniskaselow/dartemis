class SystemManager {
// TODO class related
  World _world;
//  Map<Class<?>, EntitySystem> _systems;
  Bag<EntitySystem> _bagged;

  SystemManager(this._world) {
//    systems = new Map<Class<?>, EntitySystem>();
    _bagged = new Bag<EntitySystem>();
  }

  EntitySystem setSystem(EntitySystem system) {
    system._world = _world;

//    systems.put(system.getClass(), system);

    if(!_bagged.contains(system))
      _bagged.add(system);

//    system.setSystemBit(SystemBitManager.getBitFor(system.getClass()));

    return system;
  }

//  public <T extends EntitySystem> T getSystem(Class<T> type) {
//    return type.cast(systems.get(type));
//  }

  Bag<EntitySystem> getSystems() {
    return _bagged;
  }

  /**
   * After adding all systems to the world, you must initialize them all.
   */
  void initializeAll() {
     for (int i = 0; i < _bagged.size; i++) {
        _bagged[i]._initialize();
     }
  }
}
