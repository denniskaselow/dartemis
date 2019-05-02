part of dartemis;

/// The primary instance for the framework. It contains all the managers.
///
/// You must use this to create, delete and retrieve entities.
///
/// It is also important to set the delta each game loop iteration, and
/// initialize before game loop.
class World {
  final EntityManager _entityManager = EntityManager._internal();
  final ComponentManager _componentManager = ComponentManager._internal();

  final Bag<Entity> _added = EntityBag();
  final Bag<Entity> _changed = EntityBag();
  final Bag<Entity> _deleted = EntityBag();
  final Bag<Entity> _enable = EntityBag();
  final Bag<Entity> _disable = EntityBag();

  final Map<Type, EntitySystem> _systems = <Type, EntitySystem>{};
  final List<EntitySystem> _systemsList = <EntitySystem>[];

  final Map<Type, Manager> _managers = <Type, Manager>{};
  final Bag<Manager> _managersBag = Bag<Manager>();

  final Map<int, int> _frame = {0: 0};
  final Map<int, double> _time = {0: 0.0};

  /// The time that passed since the last time [process] was called.
  double delta = 0;

  /// World-related properties that can be written and read by the user.
  final Map<String, Object> properties = <String, Object>{};

  /// Create the [World] with the default [EntityManager] and
  /// [ComponentManager].
  World() {
    addManager(_entityManager);
    addManager(_componentManager);
  }

  /// Returns the current frame/how often the systems in [group] have been processed.
  int frame([int group = 0]) => _frame[group];

  /// Returns the time that has elapsed for the systems in the [group] since
  /// the game has started (sum of all deltas).
  double time([int group = 0]) => _time[group];

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

  /// Create and return a new or reused [Entity] instance, optionally with
  /// [components].
  Entity createEntity<T extends Component>([List<T> components = const []]) {
    final e = _entityManager._createEntityInstance();
    components.forEach(e.addComponent);
    return e;
  }

  /// Creates an [Entity] with [components], adds it to the world and returns
  /// it.
  ///
  /// You don't have to call [Entity.addToWorld()] if you use this.
  Entity createAndAddEntity<T extends Component>(
      [List<T> components = const []]) {
    final e = createEntity(components);
    addEntity(e);
    return e;
  }

  /// Get an [Entity] having the specified [entityId].
  Entity getEntity(int entityId) => _entityManager._getEntity(entityId);

  /// Gives you all the systems in this world for possible iteration.
  Iterable<EntitySystem> get systems => _systemsList;

  /// Adds a [system] to this world that will be processed by [process()].
  /// If [passive] is set to true the [system] will not be processed by the
  /// world.
  /// If a [group] is set, this [system] will only be processed when calling
  /// [process()] with the same [group].
  void addSystem(EntitySystem system, {bool passive = false, int group = 0}) {
    system
      .._world = this
      .._passive = passive
      .._group = group;

    _systems[system.runtimeType] = system;
    _systemsList.add(system);
    _time.putIfAbsent(group, () => 0.0);
    _frame.putIfAbsent(group, () => 0);
  }

  /// Removed the specified system from the world.
  void deleteSystem(EntitySystem system) {
    _systems.remove(system.runtimeType);
    _systemsList.remove(system);
  }

  /// Retrieve a system for specified system type.
  T getSystem<T extends EntitySystem>() => _systems[T] as T;

  /// Performs an action on each entity.
  void _check(Bag<Entity> entities,
      void Function(EntityObserver entityObserver, Entity entity) perform) {
    for (final entity in entities) {
      for (final manager in _managersBag) {
        perform(manager, entity);
      }
      for (final system in _systemsList) {
        perform(system, entity);
      }
    }
    entities.clear();
  }

  /// Processes all changes to entities and executes all non-passive systems.
  void process([int group = 0]) {
    _frame[group]++;
    _time[group] += delta;
    _processEntityChanges();

    for (final system in _systemsList
        .where((system) => !system.passive && system.group == group)) {
      system.process();
      _processEntityChanges();
    }
  }

  /// Processes all changes to entities.
  void _processEntityChanges() {
    _check(_changed, (observer, entity) => observer.changed(entity));
    _check(_disable, (observer, entity) => observer.disabled(entity));
    _check(_enable, (observer, entity) => observer.enabled(entity));
    _check(_deleted, (observer, entity) => observer.deleted(entity));
    _deleted.forEach(_added.remove);
    _componentManager._clean();
    _check(_added, (observer, entity) => observer.added(entity));
  }

  /// Removes all entities from the world.
  ///
  /// Every entity and component has to be created anew. Make sure not to reuse
  /// [Component]s that were added to an [Entity] and referenced in you code
  /// because they will be added to a free list and might be overwritten once a
  /// new [Component] of that type is created.
  void deleteAllEntities() {
    entityManager._entities
        .where((entity) => entity != null)
        .forEach(deleteEntity);
    _processEntityChanges();
  }

  /// Adds a [Entity entity] to this world.
  void addEntity(Entity entity) => _added.add(entity);

  /// Ensure all systems are notified of changes to this [Entity entity]. If
  /// you're adding a [Component] to an [Entity] after it's been added to the
  /// world, then you need to invoke this method.
  void changedEntity(Entity entity) => _changed.add(entity);

  /// Delete the [Entity entity] from the world.
  void deleteEntity(Entity entity) => _deleted.add(entity);

  /// (Re)enable the [Entity entity] in the world, after it having being
  /// disabled.
  /// Won't do anything unless it was already disabled.
  void enable(Entity entity) => _enable.add(entity);

  /// Disable the [Entity entity] from being processed. Won't delete it, it will
  /// continue to exist but won't get processed.
  void disable(Entity entity) => _disable.add(entity);

  /// Returns the value for [key] from [properties].
  Object operator [](String key) => properties[key];

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
}

/// A [World] which measures performance by measureing elapsed time between
/// calls.
class PerformanceMeasureWorld extends World {
  int _framesToMeasure;
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
    _frame[group]++;
    _time[group] += delta;
    _processEntityChanges();
    final stopwatch = Stopwatch()..start();
    var lastStop = stopwatch.elapsedMicroseconds;
    for (final system in _systemsList
        .where((system) => !system.passive && system.group == group)) {
      system.process();
      final afterSystem = stopwatch.elapsedMicroseconds;
      _processEntityChanges();
      final afterProcessEntityChanges = stopwatch.elapsedMicroseconds;
      _storeTime(_systemTimes, system, afterSystem, lastStop);
      _storeTime(_processEntityChangesTimes, system, afterProcessEntityChanges,
          afterSystem);
      lastStop = stopwatch.elapsedMicroseconds;
    }
    final now = stopwatch.elapsedMicroseconds;
    final times = _systemTimes[runtimeType];
    if (times.length >= _framesToMeasure) {
      times.removeFirst();
    }
    times.add(now);
  }

  void _storeTime(Map<Type, ListQueue<int>> measuredTimes, EntitySystem system,
      int afterSystem, int lastStop) {
    final times = measuredTimes[system.runtimeType];
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
  /// [PerformanceStats] for changes to [Entity]s that require updates to other
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
