part of dartemis;

/**
 * High performance component retrieval from entities. Use this wherever you
 * need to retrieve components from entities often and fast.
 */
class Mapper<A extends Component> extends ComponentMapper<A> {
  Mapper(Type componentType, World world) : super(componentType, world);
}

/// Use [Mapper] instead.
@deprecated
class ComponentMapper<A extends Component> {
  ComponentType _type;
  Bag<Component> _components;

  ComponentMapper(Type componentType, World world) {
    this._type = ComponentTypeManager.getTypeFor(componentType);
    _components = world.componentManager.getComponentsByType(this._type);
  }

  /// Use bracket operator instead.
  @deprecated
  A get(Entity entity) => _components[entity.id];

  /**
   * Fast but unsafe retrieval of a component for this entity.
   * No bounding checks, so this could throw an ArrayIndexOutOfBoundsExeption,
   * however in most scenarios you already know the entity possesses this
   * component.
   */
  A operator [](Entity entity) => _components[entity.id];

  /**
   * Fast and safe retrieval of a component for this entity.
   * If the entity does not have this component then null is returned.
   */
  A getSafe(Entity entity) {
    if (_components.isIndexWithinBounds(entity.id)) {
      return _components[entity.id];
    }
    return null;
  }

  /**
   * Checks if the entity has this type of component.
   */
  bool has(Entity entity) => getSafe(entity) != null;
}
