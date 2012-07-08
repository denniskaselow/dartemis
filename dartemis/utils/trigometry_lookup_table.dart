// Math.sin() is slow. Using a lookup table for sin/cos is roughly 50x faster.
// The loss of accuracy is minimal, maximum error is roughly 0,001.
// You can probably get away with it.
// Thanks to Riven
// From: http://riven8192.blogspot.com/2009/08/fastmath-sincos-lookup-tables.html

double sin(num rad) {
  return _sin((rad * _radToIndex).toInt() & _SIN_MASK);
}

double cos(num rad) {
  return _cos((rad * _radToIndex).toInt() & _SIN_MASK);
}

double sinDeg(num deg) {
  return _sin((deg * _degToIndex).toInt() & _SIN_MASK);
}

double cosDeg(num deg) {
  return _cos((deg * _degToIndex).toInt() & _SIN_MASK);
}

final _RAD = Math.PI / 180.0;
final _DEG = 180.0 / Math.PI;
final _SIN_BITS = 12;
final _SIN_MASK = ~(-1 << _SIN_BITS);
final _SIN_COUNT = _SIN_MASK + 1;
final _radFull = Math.PI * 2.0;
final _radToIndex = _SIN_COUNT / _radFull;
final _degFull = 360.0;
final _degToIndex = _SIN_COUNT / _degFull;
var _sinLookUpTable; // = _createLookUpTable(Math.sin);
var _cosLookUpTable; // = _createLookUpTable(Math.cos);


// lazy initialization because of: "initializer must be a compile time constant"
double _sin(index) {
  if (null == _sinLookUpTable) {
    _sinLookUpTable = _createLookUpTable(Math.sin);
  }
  return _sinLookUpTable[index];
}

double _cos(index) {
  if (null == _cosLookUpTable) {
    _cosLookUpTable = _createLookUpTable(Math.cos);
  }
  return _cosLookUpTable[index];
}

_createLookUpTable(Function function) {
  var lookUpTable = new List<double>(_SIN_COUNT);
  for (int i = 0; i < _SIN_COUNT; i++) {
    lookUpTable[i] = function((i + 0.5) / _SIN_COUNT * _radFull);
  }
  return lookUpTable;
}