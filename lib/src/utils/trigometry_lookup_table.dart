part of dartemis;

/**
 * Math.sin() is slow. Using a lookup table for sin/cos is roughly 50x faster.
 * The loss of accuracy is minimal, maximum error is roughly 0,001.
 * You can probably get away with it.
 *
 * Thanks to [Riven](http://riven8192.blogspot.com/2009/08/fastmath-sincos-lookup-tables.html "FastMath :: sin/cos lookup")
 */
class TrigUtil {
  static double sin(num rad) {
    return _sin((rad * _radToIndex).toInt() & _SIN_MASK);
  }

  static double cos(num rad) {
    return _cos((rad * _radToIndex).toInt() & _SIN_MASK);
  }

  static double sinDeg(num deg) {
    return _sin((deg * _degToIndex).toInt() & _SIN_MASK);
  }

  static double cosDeg(num deg) {
    return _cos((deg * _degToIndex).toInt() & _SIN_MASK);
  }

  static final _RAD = Math.PI / 180.0;
  static final _DEG = 180.0 / Math.PI;
  static final _SIN_BITS = 12;
  static final _SIN_MASK = 4095; // ~(-1 << _SIN_BITS);
  static final _SIN_COUNT = _SIN_MASK + 1;
  static final _radFull = Math.PI * 2.0;
  static final _radToIndex = _SIN_COUNT / _radFull;
  static final _degFull = 360.0;
  static final _degToIndex = _SIN_COUNT / _degFull;
  static var _sinLookUpTable; // = _createLookUpTable(Math.sin);
  static var _cosLookUpTable; // = _createLookUpTable(Math.cos);


  // lazy initialization because of: "initializer must be a compile time constant"
  static double _sin(index) {
    if (null == _sinLookUpTable) {
      _sinLookUpTable = _createLookUpTable(sin);
    }
    return _sinLookUpTable[index];
  }

  static double _cos(index) {
    if (null == _cosLookUpTable) {
      _cosLookUpTable = _createLookUpTable(cos);
    }
    return _cosLookUpTable[index];
  }

  static _createLookUpTable(Function function) {
    var lookUpTable = new List<double>(_SIN_COUNT);
    for (int i = 0; i < _SIN_COUNT; i++) {
      lookUpTable[i] = function((i + 0.5) / _SIN_COUNT * _radFull);
    }
    return lookUpTable;
  }
}