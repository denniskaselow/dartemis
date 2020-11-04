part of dartemis;

/// The [ComponentType] handles the internal id and bitmask of a [Component].
class ComponentType {
  static final _componentTypes = <Type, ComponentType>{};
  static int _nextBitIndex = 0;
  final int _bitIndex;

  /// Creates a [ComponentType]. There should be no reason for you to call this
  /// constructor.
  ComponentType() : _bitIndex = _nextBitIndex++;

  /// Returns the [ComponentType] for the runtimeType of a [Component].
  factory ComponentType.getTypeFor(Type typeOfComponent) =>
      _componentTypes.putIfAbsent(typeOfComponent, () => ComponentType());

  /// Returns the index of the bit of the [componentType].
  static int getBitIndex(Type componentType) =>
      ComponentType.getTypeFor(componentType)._bitIndex;
}
