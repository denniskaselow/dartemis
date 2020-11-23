part of dartemis;

/// High performance component retrieval from entities. Use this wherever you
/// need to retrieve components from entities often and fast.
class Mapper<T extends Component> {
  final List<T?> _components;

  /// Create a Mapper for [T] in [world].
  Mapper(World world)
      : _components = world.componentManager
            ._getComponentsByType<T>(ComponentType.getTypeFor(T));

  /// Fast but unsafe retrieval of a component for this entity.
  /// No bounding checks, so this could throw a [RangeError],
  /// however in most scenarios you already know the entity possesses this
  /// component.
  T operator [](int entity) => (_components[entity])!;

  /// Fast and safe retrieval of a component for this entity.
  /// If the entity does not have this component then null is returned.
  T? getSafe(int entity) {
    if (_components.length > entity) {
      return _components[entity];
    }
    return null;
  }

  /// Checks if the entity has this type of component.
  bool has(int entity) => getSafe(entity) != null;
}

/// Same as [Mapper], except the [[]] operator returns [T?] instead of [T] and
/// no getSafe method.
/// For use in combination with [Aspect.forOneOf].
class OptionalMapper<T extends Component> {
  final List<T?> _components;

  /// Create a Mapper for [T] in [world].
  OptionalMapper(World world)
      : _components = world.componentManager
            ._getComponentsByType<T>(ComponentType.getTypeFor(T));

  /// Fast and safe retrieval of a component for this entity.
  /// If the entity does not have this component then null is returned.
  T? operator [](int entity) {
    if (_components.length > entity) {
      return _components[entity];
    }
    return null;
  }

  /// Checks if the entity has this type of component.
  bool has(int entity) => this[entity] != null;
}
