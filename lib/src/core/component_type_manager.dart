part of dartemis;

/// The [ComponentTypeManager] maps the [Type] of all every [Component] class to
/// a [ComponentType].
class ComponentTypeManager {
  static final _componentTypes = <Type, ComponentType>{};

  /// Returns the [ComponentType] for the runtimeType of a [Component].
  static ComponentType getTypeFor(Type typeOfComponent) =>
      _componentTypes.putIfAbsent(typeOfComponent, () => ComponentType());

  /// Returns the index of the bit of the [componentType].
  static int getBitIndex(Type componentType) =>
      getTypeFor(componentType)._bitIndex;
}
