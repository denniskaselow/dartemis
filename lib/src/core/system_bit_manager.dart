part of dartemis;

class _SystemBitManager {
  static int _pos = 0;
  static var _systemBits;

  static BigInt _getBitFor(Type esType) {
    _systemBits ??= <Type, BigInt>{};
    var bit = _systemBits[esType];

    if (bit == null) {
      bit = BigInt.one << _pos;
      _pos++;
      _systemBits[esType] = bit;
    }

    return bit;
  }
}
