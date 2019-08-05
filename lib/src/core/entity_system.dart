part of dartemis;

/// The most raw entity system. It should not typically be used, but you can
/// create your own entity system handling by extending this. It is recommended
/// that you use the other provided entity system implementations.
///
/// There is no need to ever call any other method than process on objects of
/// this class.
abstract class EntitySystem {
  int _systemBitIndex;
  World _world;
  List<int> _actives;
  List<int> _interestingComponentsIndices;
  List<int> _componentIndicesAll;
  List<int> _componentIndicesOne;
  List<int> _componentIndicesExcluded;

  final BitSet _all;
  final BitSet _excluded;
  final BitSet _one;

  bool _passive;
  int _group;

  /// Creates an [EntitySystem] with [aspect].
  EntitySystem(Aspect aspect)
      : _actives = <int>[],
        _all = aspect._all,
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

  /// Returns how often the system in this [group] have been processed.
  int get frame => world._frame[_group];

  /// Returns the time that has elapsed for the systems in this [group] since
  /// the game has started (sum of all deltas).
  double get time => world._time[_group];

  /// Called before processing of entities begins.
  void begin() {}

  /// This is the only method that is supposed to be called from outside the
  /// library,
  void process() {
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
  void processEntities(Iterable<int> entities);

  /// Returns true if the system should be processed, false if not.
  bool checkProcessing();

  /// Override to implement code that gets executed when systems are
  /// initialized.
  void initialize() {}

  /// Gets called if the world gets destroyed. Override if there is cleanup to
  /// do.
  void destroy() {}

  /// Add a [component] to an [entity].
  void addComponent<T extends Component>(int entity, T component) =>
      world.addComponent(entity, component);

  /// Remove the component with type [T] from an [entity].
  void removeComponent<T extends Component>(int entity) =>
      world.removeComponent<T>(entity);

  /// Delete [entity] from the world.
  void deleteFromWorld(int entity) => world.deleteEntity(entity);
}
