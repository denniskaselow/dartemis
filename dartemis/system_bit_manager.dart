class SystemBitManager {

  static int _POS = 0;
  static var _systemBits = new Map<String, int>();

  static int _getBitFor(Type esType) {
    var bit = _systemBits[esType.descriptor()];

    if(bit == null){
      bit = 1 << _POS;
      _POS++;
      _systemBits[esType.descriptor()] = bit;
    }

    return bit;
  }
}
