part of dartemis;

class ComponentType {
  static var _nextBit = 1;
  static var _nextId = 0;

  var _bit = 0;
  var _id = 0;

  ComponentType() {
    _init();
  }

  _init() {
    _bit = _nextBit;
    _nextBit = _nextBit << 1;
    _id = _nextId++;
  }

  int get bit => _bit;

  int get id => _id;
}
