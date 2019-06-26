part of dartemis;

/// The [ComponentType] handles the internal id and bitmask of a [Component].
class ComponentType {
  static int _nextBitIndex = 0;

  final int _bitIndex;

  /// Creates a [ComponentType]. There should be no reason for you to call this
  /// constructor.
  ComponentType() : _bitIndex = _nextBitIndex++;
}
