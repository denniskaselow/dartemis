part of dartemis;

/// The most raw entity system. It should not typically be used, but you can
/// create your own entity system handling by extending this. It is recommended
/// that you use the other provided entity system implementations.
///
/// There is no need to ever call any other method than process on objects of
/// this class.
abstract class EntitySystem implements EntityObserver {
  BigInt _systemBit = BigInt.zero;
  World _world;
  Bag<Entity> _actives;

  BigInt _all;
  BigInt _excluded;
  BigInt _one;
  bool _dummy;

  bool _passive;
  int _group;

  /// Creates an [EntitySystem] with [aspect].
  EntitySystem(Aspect aspect)
      : _actives = EntityBag(),
        _all = aspect._all,
        _excluded = aspect._excluded,
        _one = aspect._one {
    _dummy = _all == BigInt.zero && _one == BigInt.zero;
    _systemBit = _SystemBitManager._getBitFor(runtimeType);
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
  void processEntities(Iterable<Entity> entities);

  /// Returns true if the system should be processed, false if not.
  bool checkProcessing();

  /// Override to implement code that gets executed when systems are
  /// initialized.
  void initialize() {}

  /// Called if the system has received an [entity] it is interested in, e.g.
  /// created or a component was added to it.
  void inserted(Entity entity) {}

  /// Called if an [entity] was removed from this system, e.g. deleted or had
  /// one of it's components removed.
  void removed(Entity entity) {}

  void _check(Entity entity) {
    if (_dummy) {
      return;
    }
    final contains = _contains(entity);
    var interest = (_all & entity._typeBits) == _all;
    if (_one > BigInt.zero && interest) {
      interest = (_one & entity._typeBits) > BigInt.zero;
    }
    if (_excluded > BigInt.zero && interest) {
      interest = (_excluded & entity._typeBits) == BigInt.zero;
    }

    if (interest && !contains) {
      _insertToSystem(entity);
    } else {
      if (!interest && contains) {
        _removeFromSystem(entity);
      }
    }
  }

  bool _contains(Entity entity) =>
      (_systemBit & entity._systemBits) == _systemBit;

  void _insertToSystem(Entity entity) {
    _actives.add(entity);
    entity._addSystemBit(_systemBit);
    inserted(entity);
  }

  void _removeFromSystem(Entity entity) {
    _actives.remove(entity);
    entity._removeSystemBit(_systemBit);
    removed(entity);
  }

  @override
  void added(Entity entity) => _check(entity);
  @override
  void changed(Entity entity) => _check(entity);
  @override
  void enabled(Entity entity) => _check(entity);

  @override
  void deleted(Entity entity) {
    if (_contains(entity)) {
      _removeFromSystem(entity);
    }
  }

  @override
  void disabled(Entity entity) {
    if (_contains(entity)) {
      _removeFromSystem(entity);
    }
  }

  /// Gets called if the world gets destroyed. Override if there is cleanup to
  /// do.
  void destroy() {}
}
