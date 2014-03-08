part of dartemis;

/**
 * Using these function will save you some time if you are doing A LOT of
 * calculation.
 */
class FastMath {

  static const double PI = Math.PI;
  static const double SQUARED_PI = PI * PI;
  static const double HALF_PI = 0.5 * PI;
  static const double TWO_PI = 2.0 * PI;
  static const double THREE_PI_HALVES = TWO_PI - HALF_PI;

  static const double _sin_a = -4 / SQUARED_PI;
  static const double _sin_b = 4 / PI;
  static const double _sin_p = 9 / 40;

  static const double _asin_a = -0.0481295276831013447;
  static const double _asin_b = -0.343835993947915197;
  static const double _asin_c = 0.962761848425913169;
  static const double _asin_d = 1.00138940860107040;

  static const double _atan_a = 0.280872;

  static double cos(final num x) => _TrigUtil.cos(x);
  static double sin(num x) => _TrigUtil.sin(x);
  static double tan(final num x) => sin(x) / cos(x);

  static double asin(num x) {
    x = x.toDouble();
    return x * (x.abs() * (x.abs() * _asin_a + _asin_b) + _asin_c) + signum(x) *
        (_asin_d - Math.sqrt(1 - x * x));
  }

  static double acos(num x) => HALF_PI - asin(x);

  static double atan(num x) {
    x = x.toDouble();
    return (x.abs() < 1) ? x / (1 + _atan_a * x * x) : signum(x) * HALF_PI - x /
        (x * x + _atan_a);
  }

  static int signum(num x) => (x < 0) ? -1 : (x > 0) ? 1 : 0;

}
