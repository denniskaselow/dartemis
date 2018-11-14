part of dartemis;

class ComponentType {
  static BigInt _nextBit = BigInt.one;
  static int _nextId = 0;

  var _bit = BigInt.zero;
  var _id = 0;

  ComponentType() {
    _bit = _nextBit;
    _nextBit = _nextBit << 1;
    _id = _nextId++;
  }

  BigInt get bit => _bit;
  int get id => _id;
}
