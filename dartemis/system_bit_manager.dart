class SystemBitManager {

  static int _POS = 0;
  static var _systemBits = new Map<Type, int>();

  static int _getBitFor(Type esType) {
    var bit = _systemBits[esType];

    if(bit == null){
      bit = 1 << _POS;
      _POS++;
      _systemBits[esType] = bit;
    }

    return bit;
  }
}
