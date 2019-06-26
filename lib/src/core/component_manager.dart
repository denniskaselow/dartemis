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
    entity._typeBits.clearAll();
  }

  void _addComponent<T extends Component>(
      Entity entity, ComponentType type, T component) {
    final index = type._bitIndex;
    _componentsByType._ensureCapacity(index);

    var components = _componentsByType[index];
    if (components == null) {
      components = Bag<T>();
      _componentsByType[index] = components;
    }

    components[entity.id] = component;

    entity._addTypeBit(type._bitIndex);
  }

  void _removeComponent(Entity entity, ComponentType type) {
    if (entity._typeBits[type._bitIndex]) {
      final typeId = type._bitIndex;
      _componentsByType[typeId][entity.id]._removed();
      _componentsByType[typeId][entity.id] = null;
      entity._removeTypeBit(type._bitIndex);
    }
  }

  /// Returns all components of [ComponentType type].
  Bag<T> getComponentsByType<T extends Component>(ComponentType type) {
    final index = type._bitIndex;
    _componentsByType._ensureCapacity(index);

    var components = _componentsByType[index];
    if (components == null) {
      components = Bag<T>();
      _componentsByType[index] = components;
    } else if (components is! Bag<T>) {
      // when components get added to an entity as part of a list containing
      // multiple different components, the type is infered as Component
      // instead of the actual type of the component. So if _addComponent was
      // called first a Bag<Component> would have been created and this fixes
      // the type
      _componentsByType[index] = components.cast<T>();
      components = _componentsByType[index];
    }

    return components as Bag<T>;
  }

  T _getComponent<T extends Component>(Entity entity, ComponentType type) {
    final index = type._bitIndex;
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
    final componentBits = entity._typeBits;
    for (var index = 0; index < ComponentType._nextBitIndex; index++) {
      if (componentBits[index]) {
        f(_componentsByType[index], index);
      }
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
