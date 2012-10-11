
/**
 * The most raw entity system. It should not typically be used, but you can create your own
 * entity system handling by extending this. It is recommended that you use the other provided
 * entity system implementations.
 *
 * There is no need to ever call any other method than process on objects of this class.
 *
 * @author Arni Arent
 *
 */
abstract class EntitySystem {

  int _systemBit = 0;
  int _typeFlags = 0;
  World world;
  Bag<Entity> _actives;

  EntitySystem([List<String> componentTypes]) {
    _actives = new Bag<Entity>();

    for (String type in componentTypes) {
      ComponentType ct = ComponentTypeManager.getTypeFor(type);
      _typeFlags |= ct.bit;
    }
  }

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
  abstract void processEntities(ImmutableBag<Entity> entities);

  /**
   * Returns true if the system should be processed, false if not.
   */
  abstract bool checkProcessing();

  /**
   * Override to implement code that gets executed when systems are initialized.
   */
  void initialize() {}

  /**
   * Called if the system has received an [entity] it is interested in, e.g. created or a component was added to it.
   */
  void added(Entity entity) {}

  /**
   * Called if an [entity] was removed from this system, e.g. deleted or had one of it's components removed.
   */
  void removed(Entity entity) {}

  void _change(Entity e) {
    bool contains = (_systemBit & e._systemBits) == _systemBit;
    bool interest = (_typeFlags & e._typeBits) == _typeFlags;

    if (interest && !contains && _typeFlags > 0) {
      _actives.add(e);
      e._addSystemBit(_systemBit);
      added(e);
    } else if (!interest && contains && _typeFlags > 0) {
      _remove(e);
    }
  }

  void _remove(Entity e) {
    _actives.remove(e);
    e._removeSystemBit(_systemBit);
    removed(e);
  }

  /**
   * Merge together a [requiredType] and a array of [otherTypes]. Used in derived systems.
   */
  static List<String> getMergedTypes(String requiredComponentName, [List<String> otherComponentNames]) {
    List<String> mergedList = [requiredComponentName];
    mergedList.addAll(otherComponentNames);
    return mergedList;
  }

}
