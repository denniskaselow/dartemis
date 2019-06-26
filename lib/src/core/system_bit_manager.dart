part of dartemis;

class _SystemBitManager {
  static int _pos = 0;
  static Map<Type, int> _systemBitIndices;

  static int _getBitIndexFor(Type esType) {
    _systemBitIndices ??= <Type, int>{};
    var bitIndex = _systemBitIndices[esType];

    if (bitIndex == null) {
      bitIndex = _pos++;
      _systemBitIndices[esType] = bitIndex;
    }

    return bitIndex;
  }
}
