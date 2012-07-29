
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
class EntitySystem {

  int _systemBit = 0;
  int _typeFlags = 0;
  World _world;
  Bag<Entity> _actives;

  EntitySystem([List<Type> types]) {
    _actives = new Bag<Entity>();

    for (Type type in types) {
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
   * to process the given entities of the system.
   *
   * @param entities the entities this system contains.
   */
  abstract void processEntities(ImmutableBag<Entity> entities);

  /**
   *
   * @return true if the system should be processed, false if not.
   */
  abstract bool checkProcessing();

  /**
   * Override to implement code that gets executed when systems are initialized.
   */
  void initialize() {}

  /**
   * Called if the system has received a entity it is interested in, e.g. created or a component was added to it.
   * @param e the entity that was added to this system.
   */
  void added(Entity e) {}

  /**
   * Called if a entity was removed from this system, e.g. deleted or had one of it's components removed.
   * @param e the entity that was removed from this system.
   */
  void removed(Entity e) {}

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
   * Merge together a required type and a array of other types. Used in derived systems.
   * @param requiredType
   * @param otherTypes
   * @return
   */
  static List<Type> getMergedTypes(Type requiredType, [List<Type> otherTypes]) {
    var otherTypesLength = null == otherTypes ? 0 : otherTypes.length;
    var types = new List<Type>(1+otherTypesLength);
    types[0] = requiredType;
    for(int i = 0; otherTypesLength > i; i++) {
      types[i+1] = otherTypes[i];
    }
    return types;
  }

  Type get type() => const Type('EntitySystem');
}
