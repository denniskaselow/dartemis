part of dartemis;

/// Manages als components of all entities.
class ComponentManager extends Manager {
  Bag<Bag<Component>> _componentsByType;
  Bag<Entity> _deleted;

  ComponentManager._internal()
      : _componentsByType = Bag<Bag<Component>>(),
        _deleted = EntityBag();

  @override
  void initialize() {}

  void _removeComponentsOfEntity(Entity entity) {
    _forComponentsOfEntity(entity, (components, typeId) {
      components[entity.id]._removed();
      components[entity.id] = null;
    });
    entity._typeBits = BigInt.zero;
  }

  void _addComponent<T extends Component>(
      Entity entity, ComponentType type, T component) {
    final index = type._id;
    _componentsByType._ensureCapacity(index);

    var components = _componentsByType[index];
    if (components == null) {
      components = Bag<T>();
      _componentsByType[index] = components;
    }

    components[entity.id] = component;

    entity._addTypeBit(type._bit);
  }

  void _removeComponent(Entity entity, ComponentType type) {
    if ((entity._typeBits & type._bit) != BigInt.zero) {
      final typeId = type._id;
      _componentsByType[typeId][entity.id]._removed();
      _componentsByType[typeId][entity.id] = null;
      entity._removeTypeBit(type._bit);
    }
  }

  /// Returns all components of [ComponentType type].
  Bag<T> getComponentsByType<T extends Component>(ComponentType type) {
    final index = type._id;
    _componentsByType._ensureCapacity(index);

    final components = _componentsByType[index];
    if (components is Bag<T>) {
      return components;
    }
    final emptyComponents = Bag<T>();
    _componentsByType[index] = emptyComponents;
    return emptyComponents;
  }

  T _getComponent<T extends Component>(Entity entity, ComponentType type) {
    final index = type._id;
    final components = _componentsByType[index];
    if (components != null && components.isIndexWithinBounds(entity.id)) {
      return components[entity.id] as T;
    }
    return null;
  }

  /// Returns the provided [fillBag] with all components of [entity].
  Bag<Component> getComponentsFor(Entity entity, Bag<Component> fillBag) {
    _forComponentsOfEntity(
        entity, (components, _) => fillBag.add(components[entity.id]));

    return fillBag;
  }

  void _forComponentsOfEntity(
      Entity entity, void Function(Bag<Component> components, int index) f) {
    var componentBits = entity._typeBits;
    var index = 0;
    while (componentBits > BigInt.zero) {
      if ((componentBits & BigInt.one) == BigInt.one) {
        f(_componentsByType[index], index);
      }
      index++;
      componentBits = componentBits >> 1;
    }
  }

  @override
  void deleted(Entity entity) => _deleted.add(entity);

  void _clean() {
    _deleted
      ..forEach(_removeComponentsOfEntity)
      ..clear();
  }
}
