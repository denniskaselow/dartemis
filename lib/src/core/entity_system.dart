part of dartemis;

/// The most raw entity system. It should not typically be used, but you can
/// create your own entity system handling by extending this. It is recommended
/// that you use the other provided entity system implementations.
///
/// There is no need to ever call any other method than process on objects of
/// this class.
abstract class EntitySystem implements EntityObserver {
  int _systemBit = 0;
  World _world;
  Bag<Entity> _actives;

  int _all;
  int _excluded;
  int _one;
  bool _dummy;

  bool _passive;
  int _group;

  EntitySystem(Aspect aspect)
      : _actives = EntityBag(),
        _all = aspect.all,
        _excluded = aspect.excluded,
        _one = aspect.one {
    _dummy = _all == 0 && _one == 0;
    _systemBit = _SystemBitManager._getBitFor(runtimeType);
  }

  bool get passive => _passive;
  int get group => _group;
  World get world => _world;

  /// Returns how often the system in this [group] have been processed.
  int get frame => world._frame[_group];

  /// Returns the time that has elapsed for the systems in this [group] since the game has
  /// started (sum of all deltas).
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

  /// Override to implement code that gets executed when systems are initialized.
  void initialize() {}

  /// Called if the system has received an [entity] it is interested in, e.g.
  /// created or a component was added to it.
  void inserted(Entity entity) {}

  /// Called if an [entity] was removed from this system, e.g. deleted or had one
  /// of it's components removed.
  void removed(Entity entity) {}

  void _check(Entity entity) {
    if (_dummy) {
      return;
    }
    final bool contains = _contains(entity);
    bool interest = (_all & entity._typeBits) == _all;
    if (_one > 0 && interest) {
      interest = (_one & entity._typeBits) > 0;
    }
    if (_excluded > 0 && interest) {
      interest = (_excluded & entity._typeBits) == 0;
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

  void destroy() {}
}
