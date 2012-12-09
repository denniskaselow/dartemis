part of dartemis;

class ComponentManager extends Manager {
  Bag<Bag<Component>> _componentsByType;
  Bag<Entity> _deleted;

  ComponentManager() : _componentsByType = new Bag<Bag<Component>>(),
                       _deleted = new Bag<Entity>();

  void initialize() {}

  void _removeComponentsOfEntity(Entity e) {
    _forComponentsOfEntity(e, (components) => components[e.id] = null);
    e._typeBits = 0;
  }

  void _addComponent(Entity e, ComponentType type, Component component) {
    int index = type.id;
    Bag<Component> components = _getComponents(index);
    if(components == null) {
      components = new Bag<Component>();
      _componentsByType[index] = components;
    }

    components[e.id] = component;

    e._addTypeBit(type.bit);
  }

  void _removeComponent(Entity e, ComponentType type) {
    if((e._typeBits & type.bit) != 0) {
      _componentsByType[type.id][e.id] = null;
      e._removeTypeBit(type.bit);
    }
  }

  Bag<Component> getComponentsByType(ComponentType type) {
    int index = type.id;
    Bag<Component> components = _getComponents(index);
    if(components == null) {
      components = new Bag<Component>();
      _componentsByType[index] = components;
    }
    return components;
  }

  Component _getComponent(Entity e, ComponentType type) {
    int index = type.id;
    Bag<Component> components = _getComponents(index);
    if(components != null) {
      return components[e.id];
    }
    return null;
  }

  Bag<Component> getComponentsFor(Entity e, Bag<Component> fillBag) {
    _forComponentsOfEntity(e, (components) => fillBag.add(components[e.id]));

    return fillBag;
  }

  void _forComponentsOfEntity(Entity e, void f(Bag<Component> components)) {
    int componentBits = e._typeBits;
    int index = 0;
    while (componentBits > 0) {
      if ((componentBits & 1) == 1) {
        f(_componentsByType[index]);
      }
      index++;
      componentBits = componentBits >> 1;
    }
  }

  Bag<Component> _getComponents(int index) {
    Bag<Component> components = null;
    if (index < _componentsByType.size) {
      components = _componentsByType[index];
    }
    return components;
  }

  void deleted(Entity e) {
    _deleted.add(e);
  }

  void clean() {
    _deleted.forEach((entity) => _removeComponentsOfEntity(entity));
    _deleted.clear();
  }

}

