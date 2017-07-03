part of dartemis;

class ComponentManager extends Manager {
  Bag<Bag<Component>> _componentsByType;
  Bag<Entity> _deleted;

  ComponentManager()
      : _componentsByType = new Bag<Bag<Component>>(),
        _deleted = new EntityBag();

  @override
  void initialize() {}

  void _removeComponentsOfEntity(Entity entity) {
    _forComponentsOfEntity(entity, (components, typeId) {
      components[entity.id]._removed();
      components[entity.id] = null;
    });
    entity._typeBits = 0;
  }

  void _addComponent(Entity entity, ComponentType type, Component component) {
    final int index = type.id;
    _componentsByType._ensureCapacity(index);

    Bag<Component> components = _componentsByType[index];
    if (components == null) {
      components = new Bag<Component>();
      _componentsByType[index] = components;
    }

    components[entity.id] = component;

    entity._addTypeBit(type.bit);
  }

  void _removeComponent(Entity entity, ComponentType type) {
    if ((entity._typeBits & type.bit) != 0) {
      final int typeId = type.id;
      _componentsByType[typeId][entity.id]._removed();
      _componentsByType[typeId][entity.id] = null;
      entity._removeTypeBit(type.bit);
    }
  }

  Bag<Component> getComponentsByType(ComponentType type) {
    final int index = type.id;
    _componentsByType._ensureCapacity(index);

    Bag<Component> components = _componentsByType[index];
    if (components == null) {
      components = new Bag<Component>();
      _componentsByType[index] = components;
    }
    return components;
  }

  Component _getComponent(Entity entity, ComponentType type) {
    final int index = type.id;
    final Bag<Component> components = _componentsByType[index];
    if (components != null && components.isIndexWithinBounds(entity.id)) {
      return components[entity.id];
    }
    return null;
  }

  Bag<Component> getComponentsFor(Entity entity, Bag<Component> fillBag) {
    _forComponentsOfEntity(entity, (components, _) => fillBag.add(components[entity.id]));

    return fillBag;
  }

  void _forComponentsOfEntity(
      Entity entity, void f(Bag<Component> components, int index)) {
    int componentBits = entity._typeBits;
    int index = 0;
    while (componentBits > 0) {
      if ((componentBits & 1) == 1) {
        f(_componentsByType[index], index);
      }
      index++;
      componentBits = componentBits >> 1;
    }
  }

  @override
  void deleted(Entity entity) => _deleted.add(entity);

  void clean() {
    _deleted
      ..forEach(_removeComponentsOfEntity)
      ..clear();
  }
}
