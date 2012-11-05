part of dartemis;

class _SystemBitManager {

  static int _POS = 0;
  static var _systemBits;

  static int _getBitFor(Type esType) {
    if (null == _systemBits) {
      _systemBits = new Map<Type, int>();
    }
    var bit = _systemBits[esType];

    if(bit == null){
      bit = 1 << _POS;
      _POS++;
      _systemBits[esType] = bit;
    }

    return bit;
  }
}
