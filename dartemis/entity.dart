class Entity {
  /**
   * The internal id for this entity within the framework. No other entity will have the same ID, but
   * ID's are however reused so another entity may acquire this ID if the previous entity was deleted.
   */
  final int id;
  
  int _uniqueId = 0;
  int _typeBits = 0;
  int _systemBits = 0;

  World _world;
  EntityManager _entityManager;

  Entity(this._world, this.id) {
    _entityManager = _world.entityManager;
  }

  /**
   * Get the unique ID of this entity. Because entity instances are reused internally use this to identify between different instances.
   */
  int get uniqueId() => _uniqueId;

  void _addTypeBit(int bit) {
    _typeBits |= bit;
  }

  void _removeTypeBit(int bit) {
    _typeBits &= ~bit;
  }

  void _addSystemBit(int bit) {
    _systemBits |= bit;
  }

  void _removeSystemBit(int bit) {
    _systemBits &= ~bit;
  }

  void _reset() {
    _systemBits = 0;
    _typeBits = 0;
  }

  String toString() => "Entity[$id]";

  /**
   * Add a [component] to this entity.
   */
  void addComponent(Component component){
    _entityManager._addComponent(this, component);
  }

  /**
   * Removes the [component] from this entity.
   */
  void removeComponent(Component component){
    _entityManager._removeComponent(this, component);
  }

  /**
   * Faster removal of components by [type] from a entity.
   */
  void removeComponentByType(ComponentType type){
    _entityManager._removeComponentByType(this, type);
  }

  /**
   * Checks if the entity has been deleted from somewhere.
   * Returns [:true:] if it's active.
   */
  bool get active()=> _entityManager.isActive(id);

  /**
   * This is the preferred method to use when retrieving a [Component] from an entity. It will provide good performance.
   *
   * In order to retrieve the component fast you must provide a [ComponentType] instance for the expected component.
   * 
   * Returns the [Component].
   */
  Component getComponent(ComponentType type) {
    return _entityManager._getComponent(this, type);
  }

  /**
   * Slower retrieval of a [Component] from this entity. Minimize usage of this, but is fine to use e.g. when creating new entities
   * and setting data in components.
   * 
   * Returns [:null:] if none is found.
   */
   Component getComponentByClass(Type typeOfClass) {
     return getComponent(ComponentTypeManager.getTypeFor(typeOfClass));
   }

  /**
   * Get all components belonging to this entity.
   * 
   * **WARNING:** 
   * 
   * Use only for debugging purposes, it is dead slow.
   * 
   * The returned bag is only valid until this method is called again, then it is overwritten.
   */
  ImmutableBag<Component> getComponents() {
    return _entityManager._getComponents(this);
  }

  /**
   * Refresh all changes to [Component]s for this entity. After adding or removing [Component]s, you must call
   * this method. It will update all relevant [EntitySystem]s.
   * It is typical to call this after adding [Component]s to a newly created entity.
   */
  void refresh() {
    _world.refreshEntity(this);
  }

  /**
   * Delete this entity from the [World].
   */
  void delete() {
    _world.deleteEntity(this);
  }

  /**
   * Set the [group] of the entity.
   */
  void setGroup(String group) {
    _world.groupManager.addEntityToGroup(group, this);
  }

  /**
   * Assign a [tag] to this entity.
   */
  void setTag(String tag) {
    _world.tagManager.register(tag, this);
  }
}
