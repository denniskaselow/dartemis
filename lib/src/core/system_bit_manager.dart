part of dartemis;

class _SystemBitManager {
  static int _pos = 0;
  static var _systemBits;

  static int _getBitFor(Type esType) {
    _systemBits ??= <Type, int>{};
    var bit = _systemBits[esType];

    if (bit == null) {
      bit = 1 << _pos;
      _pos++;
      _systemBits[esType] = bit;
    }

    return bit;
  }
}
