part of dartemis;

/// High performance component retrieval from entities. Use this wherever you
/// need to retrieve components from entities often and fast.
class Mapper<T extends Component> {
  final Bag<T> _components;

  /// Create a Mapper for [T] in [world].
  Mapper(World world)
      : _components = world.componentManager
            .getComponentsByType(ComponentTypeManager.getTypeFor(T));

  /// Fast but unsafe retrieval of a component for this entity.
  /// No bounding checks, so this could throw an ArrayIndexOutOfBoundsExeption,
  /// however in most scenarios you already know the entity possesses this
  /// component.
  T operator [](Entity entity) => _components[entity.id];

  /// Fast and safe retrieval of a component for this entity.
  /// If the entity does not have this component then null is returned.
  T getSafe(Entity entity) {
    if (_components.isIndexWithinBounds(entity.id)) {
      return _components[entity.id];
    }
    return null;
  }

  /// Checks if the entity has this type of component.
  bool has(Entity entity) => getSafe(entity) != null;
}
