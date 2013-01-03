part of dartemis;

/**
 * The most raw entity system. It should not typically be used, but you can create your own
 * entity system handling by extending this. It is recommended that you use the other provided
 * entity system implementations.
 *
 * There is no need to ever call any other method than process on objects of this class.
 */
abstract class EntitySystem implements EntityObserver {


  int _systemBit = 0;
  World world;
  Bag<Entity> _actives;

  int _all;
  int _excluded;
  int _one;
  bool _dummy;
  bool _passive;

  EntitySystem(Aspect aspect) : _actives = new Bag<Entity>(),
                                            _all = aspect.all,
                                            _excluded = aspect.excluded,
                                            _one = aspect.one {
    _dummy = _all == 0 && _one == 0;
    _systemBit = _SystemBitManager._getBitFor(runtimeType);
  }

  get passive => _passive;

  /**
   * Called before processing of entities begins.
   */
  void begin() {}

  /**
   * This is the only method that is supposed to be called from outside the library,
   */
  void process() {
    if(checkProcessing()) {
      begin();
      processEntities(_actives);
      end();
    }
  }

  /**
   * Called after the processing of entities ends.
   */
  void end() {}

  /**
   * Any implementing entity system must implement this method and the logic
   * to process the given [entities] of the system.
   */
  void processEntities(ImmutableBag<Entity> entities);

  /**
   * Returns true if the system should be processed, false if not.
   */
  bool checkProcessing();

  /**
   * Override to implement code that gets executed when systems are initialized.
   */
  void initialize() {}

  /**
   * Called if the system has received an [entity] it is interested in, e.g. created or a component was added to it.
   */
  void inserted(Entity entity) {}

  /**
   * Called if an [entity] was removed from this system, e.g. deleted or had one of it's components removed.
   */
  void removed(Entity entity) {}

  void _check(Entity e) {
    if (_dummy) {
      return;
    }
    bool contains = _contains(e);
    bool interest = (_all & e._typeBits) == _all;
    if (_one > 0 && interest) {
      interest = (_one & e._typeBits) > 0;
    }
    if (_excluded > 0 && interest) {
      interest = (_excluded & e._typeBits) == 0;
    }

    if (interest && !contains) {
      _insertToSystem(e);
    } else if (!interest && contains) {
      _removeFromSystem(e);
    }
  }

  bool _contains(Entity e) => (_systemBit & e._systemBits) == _systemBit;

  void _insertToSystem(Entity e) {
    _actives.add(e);
    e._addSystemBit(_systemBit);
    inserted(e);
  }

  void _removeFromSystem(Entity e) {
    _actives.remove(e);
    e._removeSystemBit(_systemBit);
    removed(e);
  }

  void added(Entity e) {
    _check(e);
  }

  void changed(Entity e) {
    _check(e);
  }

  void enabled(Entity e) {
    _check(e);
  }

  void deleted(Entity e) {
    if (_contains(e)) {
      _removeFromSystem(e);
    }
  }

  void disabled(Entity e) {
    if (_contains(e)) {
      _removeFromSystem(e);
    }
  }

}