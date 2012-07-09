class SystemManager {

  World _world;
  Map<String, EntitySystem> _systems;
  Bag<EntitySystem> _bagged;

  SystemManager(this._world) {
    _systems = new Map<String, EntitySystem>();
    _bagged = new Bag<EntitySystem>();
  }

  EntitySystem setSystem(EntitySystem system) {
    system._world = _world;

    _systems[system.type.toString()] = system;

    if(!_bagged.contains(system))
      _bagged.add(system);

    system._systemBit = SystemBitManager._getBitFor(system.type);

    return system;
  }

  EntitySystem getSystem(Type type) {
    return _systems[type.toString()];
  }

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
