part of dartemis;

typedef Component ComponentConstructor();

class ComponentManager extends Manager {
  Bag<Bag<Component>> _componentsByType;
  Bag<Entity> _deleted;
  Bag<Bag<Component>> _freeLists;

  ComponentManager() : _componentsByType = new Bag<Bag<Component>>(),
                       _deleted = new Bag<Entity>(),
                       _freeLists = new Bag<Bag<Component>>();

  void initialize() {}

  void _removeComponentsOfEntity(Entity e) {
    _forComponentsOfEntity(e, (components) {
      Component component = components[e.id];
      int typeId = ComponentTypeManager.getId(component.runtimeType);
      _addToFreeList(typeId, component);
      components[e.id] = null;
    });
    e._typeBits = 0;
  }

  void _addComponent(Entity e, ComponentType type, Component component) {
    int index = type.id;
    _componentsByType._ensureCapacity(index);

    Bag<Component> components = _componentsByType[index];
    if(components == null) {
      components = new Bag<Component>();
      _componentsByType[index] = components;
    }

    components[e.id] = component;

    e._addTypeBit(type.bit);
  }

  void _removeComponent(Entity e, ComponentType type) {
    if((e._typeBits & type.bit) != 0) {
      int typeId = type.id;
      Component component = _componentsByType[typeId][e.id];
      _addToFreeList(typeId, component);
      _componentsByType[typeId][e.id] = null;
      e._removeTypeBit(type.bit);
    }
  }

  void _addToFreeList(int typeId, Component component) {
    _freeLists[typeId].add(component);
  }

  Bag<Component> getComponentsByType(ComponentType type) {
    int index = type.id;
    _componentsByType._ensureCapacity(index);

    Bag<Component> components = _componentsByType[index];
    if(components == null) {
      components = new Bag<Component>();
      _componentsByType[index] = components;
    }
    return components;
  }

  Component _getComponent(Entity e, ComponentType type) {
    int index = type.id;
    Bag<Component> components = _componentsByType[index];
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

  void deleted(Entity e) {
    _deleted.add(e);
  }

  void clean() {
    _deleted.forEach((entity) => _removeComponentsOfEntity(entity));
    _deleted.clear();
  }

  Component _createComponentInstance(ComponentType componentType, ComponentConstructor componentConstructor) {
    var index = componentType.id;
    _freeLists._ensureCapacity(index);
    var freeList = _freeLists[index];
    if (null == freeList) {
      freeList = new Bag();
      _freeLists[index] = freeList;
    }
    var component = freeList.removeLast();
    if (null == component) {
      component = componentConstructor();
    }
    return component;
  }
}

