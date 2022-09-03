part of dartemis;

/// The primary instance for the framework. It contains all the managers.
///
/// You must use this to create, delete and retrieve entities.
///
/// It is also important to set the delta each game loop iteration, and
/// initialize before game loop.
class World {
  final EntityManager _entityManager;
  final ComponentManager _componentManager;

  final Map<Type, EntitySystem> _systems = <Type, EntitySystem>{};
  final List<EntitySystem> _systemsList = <EntitySystem>[];

  final Map<Type, Manager> _managers = <Type, Manager>{};
  final Bag<Manager> _managersBag = Bag<Manager>();

  // -1 for triggering deleteEntities when calling process() without processing
  // any systems, for testing purposes
  final Map<int, int> _frame = {0: 0, -1: 0};
  final Map<int, double> _time = {0: 0.0, -1: 0.0};

  final Set<int> _entitiesMarkedForDeletion = <int>{};

  /// The time that passed since the last time [process] was called.
  double delta = 0;

  /// World-related properties that can be written and read by the user.
  final Map<String, Object> properties = <String, Object>{};

  /// Create the [World] with the default [EntityManager] and
  /// [ComponentManager].
  World({EntityManager? entityManager, ComponentManager? componentManager})
      : _entityManager = entityManager ?? EntityManager._internal(),
        _componentManager = componentManager ?? ComponentManager._internal() {
    addManager(_entityManager);
    addManager(_componentManager);
  }

  /// Returns the current frame/how often the systems in [group] have been processed.
  int frame([int group = 0]) => _frame[group]!;

  /// Returns the time that has elapsed for the systems in the [group] since
  /// the game has started (sum of all deltas).
  double time([int group = 0]) => _time[group]!;

  /// Makes sure all managers systems are initialized in the order they were
  /// added.
  void initialize() {
    _managersBag.forEach(_initializeManager);
    _systemsList.forEach(_initializeSystem);
  }

  void _initializeManager(Manager manager) => manager.initialize();

  void _initializeSystem(EntitySystem system) => system.initialize();

  /// Returns a manager that takes care of all the entities in the world.
  /// entities of this world.
  EntityManager get entityManager => _entityManager;

  /// Returns a manager that takes care of all the components in the world.
  ComponentManager get componentManager => _componentManager;

  /// Add a manager into this world. It can be retrieved later. World will
  /// notify this manager of changes to entity.
  void addManager(Manager manager) {
    if (_managers.containsKey(manager.runtimeType)) {
      throw ArgumentError.value(
          manager,
          'manager',
          'A manager of type "${manager.runtimeType}" has already been added '
              'to the world.');
    }
    _managers[manager.runtimeType] = manager;
    _managersBag.add(manager);
    manager._world = this;
  }

  /// Returns a [Manager] of the specified type [T].
  T getManager<T extends Manager>() => _managers[T] as T;

  /// Deletes the manager from this world.
  void deleteManager(Manager manager) {
    _managers.remove(manager.runtimeType);
    _managersBag.remove(manager);
  }

  /// Create and return a new or reused [int] instance, optionally with
  /// [components].
  int createEntity<T extends Component>([List<T> components = const []]) {
    final e = _entityManager._createEntityInstance();
    for (final component in components) {
      addComponent(e, component);
    }
    addEntity(e);
    return e;
  }

  /// Adds a [component] to the [entity].
  void addComponent<T extends Component>(int entity, T component) =>
      componentManager._addComponent(
          entity, ComponentType.getTypeFor(component.runtimeType), component);

  /// Adds [components] to the [entity].
  void addComponents<T extends Component>(int entity, List<T> components) {
    for (final component in components) {
      addComponent(entity, component);
    }
  }

  /// removes a [Component] of type [T] from the [entity].
  void removeComponent<T extends Component>(int entity) =>
      componentManager._removeComponent(entity, ComponentType.getTypeFor(T));

  /// Gives you all the systems in this world for possible iteration.
  Iterable<EntitySystem> get systems => _systemsList;

  /// Adds a [system] to this world that will be processed by [process()].
  /// If [passive] is set to true the [system] will not be processed by the
  /// world.
  /// If a [group] is set, this [system] will only be processed when calling
  /// [process()] with the same [group].
  void addSystem(EntitySystem system, {bool passive = false, int group = 0}) {
    if (_systems.containsKey(system.runtimeType)) {
      throw ArgumentError.value(
          system,
          'system',
          'A system of type "${system.runtimeType}" has already been added to '
              'the world.');
    }
    system
      .._world = this
      .._passive = passive
      .._group = group;

    _systems[system.runtimeType] = system;
    _systemsList.add(system);
    _time.putIfAbsent(group, () => 0.0);
    _frame.putIfAbsent(group, () => 0);
    componentManager._registerSystem(system);
  }

  /// Removed the specified system from the world.
  void deleteSystem(EntitySystem system) {
    _systems.remove(system.runtimeType);
    _systemsList.remove(system);
    componentManager._unregisterSystem(system);
  }

  /// Retrieve a system for specified system type.
  T getSystem<T extends EntitySystem>() => _systems[T] as T;

  /// Processes all changes to entities and executes all non-passive systems.
  void process([int group = 0]) {
    // delete entites that have been deleted outside of a system
    _deleteEntities();
    _frame[group] = _frame[group]! + 1;
    _time[group] = _time[group]! + delta;

    for (final system in _systemsList
        .where((system) => !system.passive && system.group == group)) {
      _updateSystem(system);
      system.process();

      _deleteEntities();
    }
  }

  /// Actually delete the entities in the world that have been marked for
  /// deletion.
  void _deleteEntities() {
    _entitiesMarkedForDeletion
      ..forEach(_deleteEntity)
      ..clear();
  }

  /// Delete an entity.
  void _deleteEntity(int entity) {
    for (final manager in _managers.values) {
      manager.deleted(entity);
    }
    componentManager._removeComponentsOfEntity(entity);
    entityManager._delete(entity);
  }

  void _updateSystem(EntitySystem system) {
    if (componentManager.isUpdateNeededForSystem(system)) {
      system._actives = componentManager._getEntitiesForSystem(
          system, entityManager._entities.length);
      componentManager._systemUpdated(system);
    }
  }

  /// Removes all entities from the world.
  ///
  /// Every entity and component has to be created anew. Make sure not to reuse
  /// [Component]s that were added to an [int] and referenced in you code
  /// because they will be added to a free list and might be overwritten once a
  /// new [Component] of that type is created.
  void deleteAllEntities() {
    entityManager._entities
        .toIntValues()
        .forEach(_entitiesMarkedForDeletion.add);
    _deleteEntities();
  }

  /// Adds a [int entity] to this world.
  void addEntity(int entity) {
    entityManager._add(entity);
    for (final manager in _managers.values) {
      manager.added(entity);
    }
  }

  /// Mark an [entity] for deletion from the world. Will be deleted after the
  /// current system finished running.
  void deleteEntity(int entity) {
    _entitiesMarkedForDeletion.add(entity);
  }

  /// Returns the value for [key] from [properties].
  Object? operator [](String key) => properties[key];

  /// Set the [value] of [key] in [properties].
  void operator []=(String key, Object value) {
    properties[key] = value;
  }

  /// Destroy the [World] by destroying all [EntitySystem]s and [Manager]s.
  void destroy() {
    for (final system in _systemsList) {
      system.destroy();
    }
    for (final manager in _managersBag) {
      manager.destroy();
    }
  }

  /// Get all components belonging to this entity.
  List<Component> getComponents(int entity) =>
      _componentManager.getComponentsFor(entity);
}

/// A [World] which measures performance by measureing elapsed time between
/// calls.
@experimental
class PerformanceMeasureWorld extends World {
  final int _framesToMeasure;
  final Map<Type, ListQueue<int>> _systemTimes = <Type, ListQueue<int>>{};
  final Map<Type, ListQueue<int>> _processEntityChangesTimes =
      <Type, ListQueue<int>>{};

  /// Create the world and define how many frames should be included when
  /// calculating the [PerformanceStats].
  PerformanceMeasureWorld(this._framesToMeasure) {
    _systemTimes[runtimeType] = ListQueue<int>(_framesToMeasure);
  }

  @override
  void process([int group = 0]) {
    _frame[group] = _frame[group]! + 1;
    _time[group] = _time[group]! + delta;
    final stopwatch = Stopwatch()..start();
    var lastStop = stopwatch.elapsedMicroseconds;
    for (final system in _systemsList
        .where((system) => !system.passive && system.group == group)) {
      _updateSystem(system);
      final afterProcessEntityChanges = stopwatch.elapsedMicroseconds;
      system.process();
      final afterSystem = stopwatch.elapsedMicroseconds;
      _storeTime(_systemTimes, system, afterSystem, afterProcessEntityChanges);
      _storeTime(_processEntityChangesTimes, system, afterProcessEntityChanges,
          lastStop);
      lastStop = stopwatch.elapsedMicroseconds;
    }
    final now = stopwatch.elapsedMicroseconds;
    final times = _systemTimes[runtimeType]!;
    if (times.length >= _framesToMeasure) {
      times.removeFirst();
    }
    times.add(now);
  }

  void _storeTime(Map<Type, ListQueue<int>> measuredTimes, EntitySystem system,
      int afterSystem, int lastStop) {
    final times = measuredTimes[system.runtimeType]!;
    if (times.length >= _framesToMeasure) {
      times.removeFirst();
    }
    times.add(afterSystem - lastStop);
  }

  @override
  void addSystem(EntitySystem system, {bool passive = false, int group = 0}) {
    super.addSystem(system, passive: passive, group: group);
    _systemTimes[system.runtimeType] = ListQueue<int>(_framesToMeasure);
    _processEntityChangesTimes[system.runtimeType] =
        ListQueue<int>(_framesToMeasure);
  }

  /// Returns the [PerformanceStats] for every system and and the
  /// [PerformanceStats] for changes to [int]s that require updates to other
  /// [EntitySystem]s and [Manager]s.
  List<PerformanceStats> getPerformanceStats() {
    final result = <PerformanceStats>[];
    _createPerformanceStats(_systemTimes, result);
    _createPerformanceStats(_processEntityChangesTimes, result);
    return result;
  }

  void _createPerformanceStats(
      Map<Type, ListQueue<int>> measuredTimes, List<PerformanceStats> result) {
    for (final entry in measuredTimes.entries) {
      final measurements = entry.value.length;
      final sorted = List<int>.from(entry.value)..sort();
      final meanTime = sorted[measurements ~/ 2];
      final averageTime =
          sorted.fold<double>(0, (sum, item) => sum + item) / measurements;
      final minTime = sorted.first;
      final maxTime = sorted.last;
      result.add(PerformanceStats._internal(
          entry.key, measurements, minTime, maxTime, averageTime, meanTime));
    }
  }
}

/// Performance statistics for all systems.
@experimental
class PerformanceStats {
  /// The [Type] of the system.
  Type system;

  /// The number of measurements.
  int measurements;

  /// The fastest ([minTime]) and the slowest ([maxTime]) time in microseconds.
  int minTime, maxTime;

  /// The mean time in microseconds.
  int meanTime;

  /// The avaerage time in microseconds.
  double averageTime;

  PerformanceStats._internal(this.system, this.measurements, this.minTime,
      this.maxTime, this.averageTime, this.meanTime);

  @override
  String toString() => '''
PerformanceStats{system: $system, measurements: $measurements, minTime: $minTime, maxTime: $maxTime, meanTime: $meanTime, averageTime: $averageTime}''';
}
