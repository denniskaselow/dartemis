part of '../../dartemis.dart';

/// The most raw entity system. It should not typically be used, but you can
/// create your own entity system handling by extending this. It is recommended
/// that you use the other provided entity system implementations.
///
/// There is no need to ever call any other method than process on objects of
/// this class.
abstract class EntitySystem {
  late final World _world;

  List<Entity> _actives = [];

  final List<int> _interestingComponentsIndices = [];
  final List<int> _componentIndicesAll = [];
  final List<int> _componentIndicesOne = [];
  final List<int> _componentIndicesExcluded = [];

  final Aspect _aspect;
  final BitSet _all = BitSet(64);
  final BitSet _excluded = BitSet(64);
  final BitSet _one = BitSet(64);

  double _time = 0;
  double _delta = 0;
  int _frame = 0;

  /// If [passive] is set to true the [EntitySystem] will not be processed by
  /// the world.
  bool passive;

  /// This [EntitySystem] will only be processed when calling [World.process()]
  /// with the same [group].
  final int group;

  /// Creates an [EntitySystem] with [aspect].
  ///
  /// If [passive] is set to [`true`] the system will not be processed as long
  /// as it stays passive.
  ///
  /// If [group] is set, [World.process] needs to be called with this group
  /// to be processed. For example the group can be used to handle systems
  /// for physics and rendering separately and with different deltas.
  EntitySystem(Aspect aspect, {this.passive = false, this.group = 0})
      : _aspect = aspect;

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
  @visibleForOverriding
  void begin() {}

  /// This is the only method that is supposed to be called from outside the
  /// library,
  @visibleForOverriding
  void process() {
    _frame = world._frame[group]!;
    _time = world._time[group]!;
    _delta = world.delta;
    if (checkProcessing()) {
      begin();
      processEntities(_actives);
      end();
    }
  }

  /// Called after the processing of entities ends.
  @visibleForOverriding
  void end() {}

  /// Any implementing entity system must implement this method and the logic
  /// to process the given [entities] of the system.
  @visibleForOverriding
  void processEntities(Iterable<Entity> entities);

  /// Returns true if the system should be processed, false if not.
  @visibleForOverriding
  bool checkProcessing() => true;

  /// Override to implement code that gets executed when systems are
  /// initialized.
  @mustCallSuper
  @visibleForOverriding
  void initialize(World world) {
    _world = world;

    _updateBitMask(_all, _aspect.all);
    _updateBitMask(_one, _aspect.one);
    _updateBitMask(_excluded, _aspect.excluded);

    _componentIndicesAll.addAll(_all.toIntValues());
    _componentIndicesOne.addAll(_one.toIntValues());
    _componentIndicesExcluded.addAll(_excluded.toIntValues());
    _interestingComponentsIndices.addAll(
      _componentIndicesAll
          .followedBy(_componentIndicesOne)
          .followedBy(_componentIndicesExcluded)
          .toList(),
    );
  }

  void _updateBitMask(BitSet mask, Iterable<Type> componentTypes) {
    final componentManager = world.getManager<ComponentManager>();
    for (final componentType in componentTypes) {
      mask[componentManager.getBitIndex(componentType)] = true;
    }
  }

  /// Gets called if the world gets destroyed. Override if there is cleanup to
  /// do.
  @visibleForOverriding
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
