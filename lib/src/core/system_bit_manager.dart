part of '../../dartemis.dart';

class _SystemBitManager {
  static int _pos = 0;
  static final Map<Type, int?> _systemBitIndices = <Type, int>{};

  static int _getBitIndexFor(Type esType) {
    var bitIndex = _systemBitIndices[esType];

    if (bitIndex == null) {
      bitIndex = _pos++;
      _systemBitIndices[esType] = bitIndex;
    }

    return bitIndex;
  }
}
