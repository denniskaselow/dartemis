part of dartemis;

/// The [ComponentType] handles the internal id and bitmask of a [Component].
class ComponentType {
  static BigInt _nextBit = BigInt.one;
  static int _nextId = 0;

  final BigInt _bit;
  final int _id;

  /// Creates a [ComponentType]. There should be no reason for you to call this
  /// constructor.
  ComponentType()
      : _bit = _nextBit,
        _id = _nextId++ {
    _nextBit = _nextBit << 1;
  }
}
