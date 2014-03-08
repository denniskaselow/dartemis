part of dartemis;

/**
 * Math.sin() is slow. Using a lookup table for sin/cos is roughly 50x faster.
 * The loss of accuracy is minimal, maximum error is roughly 0,001.
 * You can probably get away with it.
 *
 * Thanks to [Riven](http://riven8192.blogspot.com/2009/08/fastmath-sincos-lookup-tables.html "FastMath :: sin/cos lookup")
 */
class _TrigUtil {
  static double sin(num rad) => _sin((rad * _radToIndex).toInt() & _SIN_MASK);
  static double cos(num rad) => _cos((rad * _radToIndex).toInt() & _SIN_MASK);
  static double sinDeg(num deg) => _sin((deg * _degToIndex).toInt() & _SIN_MASK
      );
  static double cosDeg(num deg) => _cos((deg * _degToIndex).toInt() & _SIN_MASK
      );

  static final double _RAD = Math.PI / 180.0;
  static final double _DEG = 180.0 / Math.PI;
  static final int _SIN_BITS = 12;
  static final int _SIN_MASK = ~(-1 << _SIN_BITS);
  static final int _SIN_COUNT = _SIN_MASK + 1;
  static final double _radFull = Math.PI * 2.0;
  static final double _radToIndex = _SIN_COUNT / _radFull;
  static final double _degFull = 360.0;
  static final double _degToIndex = _SIN_COUNT / _degFull;
  static final List<double> _sinLookUpTable = _createLookUpTable(Math.sin);
  static final List<double> _cosLookUpTable = _createLookUpTable(Math.cos);

  static double _sin(index) => _sinLookUpTable[index];
  static double _cos(index) => _cosLookUpTable[index];

  static _createLookUpTable(double f(num x)) {
    var lookUpTable = new List<double>(_SIN_COUNT);
    for (int i = 0; i < _SIN_COUNT; i++) {
      lookUpTable[i] = f((i + 0.5) / _SIN_COUNT * _radFull);
    }
    return lookUpTable;
  }
}
