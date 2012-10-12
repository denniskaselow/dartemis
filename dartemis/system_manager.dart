part of dartemis;

class SystemManager {

  World _world;
  final _systemsByType;
  final systems;

  SystemManager(this._world) : _systemsByType = new Map<Type, EntitySystem>(),
                               systems = new Bag<EntitySystem>();

  EntitySystem setSystem(EntitySystem system) {
    system.world = _world;

    _systemsByType[system.runtimeType] = system;

    if(!systems.contains(system))
      systems.add(system);

    system._systemBit = _SystemBitManager._getBitFor(system.runtimeType);

    return system;
  }

  EntitySystem getSystem(Type type) {
    return _systemsByType[type];
  }

  /**
   * After adding all systems to the world, you must initialize them all.
   */
  void initializeAll() {
     for (int i = 0; i < systems.size; i++) {
        systems[i].initialize();
     }
  }
}
