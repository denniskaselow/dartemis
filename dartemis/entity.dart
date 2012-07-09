class Entity {
  int _id = 0;
  int _uniqueId = 0;
  int _typeBits = 0;
  int _systemBits = 0;

  World _world;
  EntityManager _entityManager;

  Entity(this._world, this._id) {
    _entityManager = _world.entityManager;
  }

  /**
   * The internal id for this entity within the framework. No other entity will have the same ID, but
   * ID's are however reused so another entity may acquire this ID if the previous entity was deleted.
   *
   * @return id of the entity.
   */
  int get id() => _id;

  /**
   * Get the unique ID of this entity. Because entity instances are reused internally use this to identify between different instances.
   * @return the unique id of this entity.
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

  String toString() => "Entity[$_id]";

  /**
   * Add a component to this entity.
   * @param component to add to this entity
   */
  void addComponent(Component component){
    _entityManager._addComponent(this, component);
  }

  /**
   * Removes the component from this entity.
   * @param component to remove from this entity.
   */
  void removeComponent(Component component){
    _entityManager._removeComponent(this, component);
  }

  /**
   * Faster removal of components from a entity.
   * @param component to remove from this entity.
   */
  void removeComponentByType(ComponentType type){
    _entityManager._removeComponentByType(this, type);
  }

  /**
   * Checks if the entity has been deleted from somewhere.
   * @return if it's active.
   */
  bool get active()=> _entityManager.isActive(_id);

  /**
   * This is the preferred method to use when retrieving a component from a entity. It will provide good performance.
   *
   * @param type in order to retrieve the component fast you must provide a ComponentType instance for the expected component.
   * @return
   */
  Component getComponent(ComponentType type) {
    return _entityManager._getComponent(this, type);
  }

  /**
   * Slower retrieval of components from this entity. Minimize usage of this, but is fine to use e.g. when creating new entities
   * and setting data in components.
   * @param <T> the expected return component type.
   * @param type the expected return component type.
   * @return component that matches, or null if none is found.
   */
   Component getComponentByClass(Type typeOfClass) {
     return getComponent(ComponentTypeManager.getTypeFor(typeOfClass));
   }

  /**
   * Get all components belonging to this entity.
   * WARNING. Use only for debugging purposes, it is dead slow.
   * WARNING. The returned bag is only valid until this method is called again, then it is overwritten.
   * @return all components of this entity.
   */
  ImmutableBag<Component> getComponents() {
    return _entityManager._getComponents(this);
  }

  /**
   * Refresh all changes to components for this entity. After adding or removing components, you must call
   * this method. It will update all relevant systems.
   * It is typical to call this after adding components to a newly created entity.
   */
  void refresh() {
    _world.refreshEntity(this);
  }

  /**
   * Delete this entity from the world.
   */
  void delete() {
    _world.deleteEntity(this);
  }

  /**
   * Set the group of the entity. Same as World.setGroup().
   * @param group of the entity.
   */
  void setGroup(String group) {
    _world.groupManager.addEntityToGroup(group, this);
  }

  /**
   * Assign a tag to this entity. Same as World.setTag().
   * @param tag of the entity.
   */
  void setTag(String tag) {
    _world.tagManager.register(tag, this);
  }
}
