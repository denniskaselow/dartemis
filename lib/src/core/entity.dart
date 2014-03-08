part of dartemis;

/**
 * The entity class. Cannot be instantiated outside the framework, you must
 * create new entities using World.
 */
class Entity {
  /**
   * The internal id for this entity within the framework. No other entity will
   * have the same ID, but ID's are however reused so another entity may acquire
   * this ID if the previous entity was deleted.
   */
  final int id;

  int _uniqueId = 0;
  int _typeBits = 0;
  int _systemBits = 0;

  World _world;
  EntityManager _entityManager;
  ComponentManager _componentManager;

  Entity._(this._world, this.id) {
    _entityManager = _world.entityManager;
    _componentManager = _world.componentManager;
  }

  /**
   * Get the unique ID of this entity. Because entity instances are reused
   * internally use this to identify between different instances.
   */
  int get uniqueId => _uniqueId;

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
  void addComponent(Component component) {
    _componentManager._addComponent(this, ComponentTypeManager.getTypeFor(
        component.runtimeType), component);
  }

  /**
   * Removes the [Component] of [Type] [componentType] from this entity.
   */
  void removeComponent(Type componentType) {
    _componentManager._removeComponent(this, ComponentTypeManager.getTypeFor(
        componentType));
  }

  /**
   * Faster removal of components by [type] from a entity.
   */
  void removeComponentByType(ComponentType type) {
    _componentManager._removeComponent(this, type);
  }

  /**
   * Checks if the entity has been deleted from somewhere.
   * Returns [:true:] if it's active.
   */
  bool get active => _entityManager.isActive(id);

  /**
   * This is the preferred method to use when retrieving a [Component] from an
   * entity. It will provide good performance. The recommended way to retrieve
   * components from an entity is using the [ComponentMapper].
   *
   * In order to retrieve the component fast you must provide a [ComponentType]
   * instance for the expected component.
   *
   * Returns the [Component].
   */
  Component getComponent(ComponentType type) {
    return _componentManager._getComponent(this, type);
  }

  /**
   * Slower retrieval of a [Component] from this entity. Minimize usage of this,
   * but is fine to use e.g. when creating new entities and setting data in
   * components.
   *
   * Returns [:null:] if none is found.
   */
  Component getComponentByClass(Type componentType) {
    return getComponent(ComponentTypeManager.getTypeFor(componentType));
  }

  /**
   * Get all components belonging to this entity.
   */
  Bag<Component> getComponents([Bag<Component> fillBag]) {
    if (null == fillBag) {
      fillBag = new Bag<Component>();
    }
    return _componentManager.getComponentsFor(this, fillBag);
  }

  /**
   * Adds this entity to the world.
   */
  void addToWorld() => _world.addEntity(this);
  /**
   * Deletes this entity from the world.
   *
   * The entity will be removed once world.process or world.processEntityChanges
   * has been called.
   */
  void deleteFromWorld() => _world.deleteEntity(this);
  /**
   * Disables this entity in the world.
   */
  void disable() => _world.disable(this);
  /**
   * Notifies the world that this entity has changed.
   */
  void changedInWorld() => _world.changedEntity(this);
  /**
   * Enables this entity in the world.
   */
  void enable() => _world.enable(this);
}
