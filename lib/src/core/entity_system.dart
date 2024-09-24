part of '../../dartemis.dart';

/// The most raw entity system. It should not typically be used, but you can
/// create your own entity system handling by extending this. It is recommended
/// that you use the other provided entity system implementations.
///
/// There is no need to ever call any other method than process on objects of
/// this class.
abstract class EntitySystem {
  late final int _systemBitIndex;
  late final World _world;

  List<Entity> _actives = [];
  bool _passive = true;
  late final List<int> _interestingComponentsIndices;
  late final List<int> _componentIndicesAll;
  late final List<int> _componentIndicesOne;
  late final List<int> _componentIndicesExcluded;

  final BitSet _all;
  final BitSet _excluded;
  final BitSet _one;

  late final int _group;

  double _time = 0;
  double _delta = 0;
  int _frame = 0;

  /// Creates an [EntitySystem] with [aspect].
  EntitySystem(Aspect aspect)
      : _all = aspect._all,
        _excluded = aspect._excluded,
        _one = aspect._one {
    _systemBitIndex = _SystemBitManager._getBitIndexFor(runtimeType);
    _componentIndicesAll = _all.toIntValues();
    _componentIndicesOne = _one.toIntValues();
    _componentIndicesExcluded = _excluded.toIntValues();
    _interestingComponentsIndices = _componentIndicesAll
        .followedBy(_componentIndicesOne)
        .followedBy(_componentIndicesExcluded)
        .toList();
  }

  /// Returns [:true:] if this [EntitySystem] is passive.
  bool get passive => _passive;

  /// Returns the [group] of this [EntitySystem].
  int get group => _group;

  /// Returns the [World] this [EntitySystem] belongs to.
  World get world => _world;

  /// Returns how often the systems in this [group] have been processed.
  int get frame => _frame;

  /// Returns the time that has elapsed for the systems in this [group] since
  /// the game has started (sum of all deltas).
  double get time => _time;

  /// Returns the delta that has elapsed since the last update of the world.
  double get delta => _delta;

  /// Called before processing of entities begins.
  void begin() {}

  /// This is the only method that is supposed to be called from outside the
  /// library,
  void process() {
    _frame = world._frame[_group]!;
    _time = world._time[_group]!;
    _delta = world.delta;
    if (checkProcessing()) {
      begin();
      processEntities(_actives);
      end();
    }
  }

  /// Called after the processing of entities ends.
  void end() {}

  /// Any implementing entity system must implement this method and the logic
  /// to process the given [entities] of the system.
  void processEntities(Iterable<Entity> entities);

  /// Returns true if the system should be processed, false if not.
  bool checkProcessing() => true;

  /// Override to implement code that gets executed when systems are
  /// initialized.
  void initialize() {}

  /// Gets called if the world gets destroyed. Override if there is cleanup to
  /// do.
  void destroy() {}

  /// Add a [component] to an [entity].
  void addComponent<T extends Component>(Entity entity, T component) =>
      world.addComponent(entity, component);

  /// Remove the component with type [T] from an [entity].
  void removeComponent<T extends Component>(Entity entity) =>
      world.removeComponent<T>(entity);

  /// Delete [entity] from the world.
  void deleteFromWorld(Entity entity) => world.deleteEntity(entity);
}

/// For Testing.
@visibleForTesting
mixin MockEntitySystemMixin implements EntitySystem {
  @override
  late World _world;
  @override
  late bool _passive;
  @override
  late final int _group;
}
