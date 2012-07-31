class EntityManager {

  World _world;
  Bag<Entity> _activeEntities;
  Bag<Entity> _removedAndAvailable;
  var _nextAvailableId = 0;
  var _count = 0;
  var _uniqueEntityId = 0;
  var _totalCreated = 0;
  var _totalRemoved = 0;

  Bag<Bag<Component>> _componentsByType;

  Bag<Component> _entityComponents; // Added for debug support.

  EntityManager(this._world) {
    _activeEntities = new Bag<Entity>();
    _removedAndAvailable = new Bag<Entity>();

    _componentsByType = new Bag<Bag<Component>>();

    _entityComponents = new Bag<Component>();
  }

  Entity _create() {
    Entity e = _removedAndAvailable.removeLast();
    if (e == null) {
      e = new Entity(_world, _nextAvailableId++);
    } else {
      e._reset();
    }
    e._uniqueId = _uniqueEntityId++;
    _activeEntities[e.id] = e;
    _count++;
    _totalCreated++;
    return e;
  }

  void _remove(Entity e) {
    _activeEntities[e.id] = null;

    e._typeBits = 0;

    _refresh(e);

    _removeComponentsOfEntity(e);

    _count--;
    _totalRemoved++;

    _removedAndAvailable.add(e);
  }

  void _removeComponentsOfEntity(Entity e) {
    for(int a = 0; _componentsByType.size > a; a++) {
      Bag<Component> components = _componentsByType[a];
      if(components != null && e.id < components.size) {
        components[e.id] = null;
      }
    }
  }

  /**
   * Check if this entity is active, or has been deleted, within the framework.
   */
  bool isActive(int entityId) {
    return _activeEntities[entityId] != null;
  }

  void _addComponent(Entity e, Component component) {
    ComponentType type = ComponentTypeManager.getTypeFor(component.type);

    if(type.id >= _componentsByType.capacity) {
      _componentsByType[type.id] = null;
    }

    Bag<Component> components = _componentsByType[type.id];
    if(components == null) {
      components = new Bag<Component>();
      _componentsByType[type.id] = components;
    }

    components[e.id] = component;

    e._addTypeBit(type.bit);
  }

  void _refresh(Entity e) {
    SystemManager systemManager = _world.systemManager;
    Bag<EntitySystem> systems = systemManager.getSystems();
    for(int i = 0, s=systems.size; s > i; i++) {
      systems[i]._change(e);
    }
  }

  void _removeComponent(Entity e, Component component) {
    ComponentType type = ComponentTypeManager.getTypeFor(component.type);
    _removeComponentByType(e, type);
  }

  void _removeComponentByType(Entity e, ComponentType type) {
    Bag<Component> components = _componentsByType[type.id];
    components[e.id] = null;
    e._removeTypeBit(type.bit);
  }

  Component _getComponent(Entity e, ComponentType type) {
    Bag<Component> bag = _componentsByType[type.id];
    if(bag != null && e.id < bag.capacity)
      return bag[e.id];
    return null;
  }

  Entity _getEntity(int entityId) {
    return _activeEntities[entityId];
  }

  /**
   * Returns how many entities are currently active.
   */
  int get entityCount() => _count;

  /**
   * Returns how many entities have been created since start.
   */
  int get totalCreated() => _totalCreated;

  /**
   * Returns how many entities have been removed since start.
   */
  int get totalRemoved() => _totalRemoved;



  ImmutableBag<Component> _getComponents(Entity e) {
    _entityComponents.clear();
    for(int a = 0; _componentsByType.size > a; a++) {
      Bag<Component> components = _componentsByType[a];
      if(components != null && e.id < components.size) {
        Component component = components[e.id];
        if(component != null) {
          _entityComponents.add(component);
        }
      }
    }
    return _entityComponents;
  }
}
