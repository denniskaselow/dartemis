part of dartemis;

/// High performance component retrieval from entities. Use this wherever you
/// need to retrieve components from entities often and fast.
class Mapper<A extends Component> {
  ComponentType _type;
  Bag<Component> _components;

  Mapper(World world) {
    _type = ComponentTypeManager.getTypeFor(A);
    _components = world.componentManager.getComponentsByType(_type);
  }

  /// Use bracket operator instead.
  @deprecated
  A get(Entity entity) => _components[entity.id];

  /// Fast but unsafe retrieval of a component for this entity.
  /// No bounding checks, so this could throw an ArrayIndexOutOfBoundsExeption,
  /// however in most scenarios you already know the entity possesses this
  /// component.
  A operator [](Entity entity) => _components[entity.id];

  /// Fast and safe retrieval of a component for this entity.
  /// If the entity does not have this component then null is returned.
  A getSafe(Entity entity) {
    if (_components.isIndexWithinBounds(entity.id)) {
      return _components[entity.id];
    }
    return null;
  }

  /// Checks if the entity has this type of component.
  bool has(Entity entity) => getSafe(entity) != null;
}
