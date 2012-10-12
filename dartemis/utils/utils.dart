part of dartemis;

class Utils {

  static double cubicInterpolation(double v0, double v1, double v2, double v3, double t) {
    double t2 = t * t;
    double a0 = v3 - v2 - v0 + v1;
    double a1 = v0 - v1 - a0;
    double a2 = v2 - v0;
    double a3 = v1;

    return (a0 * (t * t2)) + (a1 * t2) + (a2 * t) + a3;
  }

  static double quadraticBezierInterpolation(double a, double b, double c, double t) {
    return (((1.0 - t) * (1.0 - t)) * a) + (((2.0 * t) * (1.0 - t)) * b) + ((t * t) * c);
  }

  static double lengthOfQuadraticBezierCurve(double x0, double y0, double x1, double y1, double x2, double y2) {
    if ((x0 == x1 && y0 == y1) || (x1 == x2 && y1 == y2)) {
      return distance(x0, y0, x2, y2);
    }

    double ax, ay, bx, by;
    ax = x0 - 2 * x1 + x2;
    ay = y0 - 2 * y1 + y2;
    bx = 2 * x1 - 2 * x0;
    by = 2 * y1 - 2 * y0;
    double A = 4 * (ax * ax + ay * ay);
    double B = 4 * (ax * bx + ay * by);
    double C = bx * bx + by * by;

    double Sabc = 2.0 * sqrt(A + B + C);
    double A_2 = sqrt(A);
    double A_32 = 2.0 * A * A_2;
    double C_2 = 2.0 * sqrt(C);
    double BA = B / A_2;

    return (A_32 * Sabc + A_2 * B * (Sabc - C_2) + (4.0 * C * A - B * B) * log((2 * A_2 + BA + Sabc) / (BA + C_2))) / (4 * A_32);
  }

  static double lerp(double a, double b, double t) {
    if (t < 0)
      return a;
    return a + t * (b - a);
  }

  static double distance(double x1, double y1, double x2, double y2) {
    return euclideanDistance(x1, y1, x2, y2);
  }

  static bool doCirclesCollide(double x1, double y1, double radius1, double x2, double y2, double radius2) {
    double dx = x2 - x1;
    double dy = y2 - y1;
    double d = radius1 + radius2;
    return (dx * dx + dy * dy) < (d * d);
  }

  static double euclideanDistanceSq2D(double x1, double y1, double x2, double y2) {
    double dx = x1 - x2;
    double dy = y1 - y2;
    return dx * dx + dy * dy;
  }

  static double manhattanDistance(double x1, double y1, double x2, double y2) {
    return (x1 - x2).abs() + (y1 - y2).abs();
  }

  static double euclideanDistance(double x1, double y1, double x2, double y2) {
    double a = x1 - x2;
    double b = y1 - y2;

    return FastMath.sqrt(a * a + b * b);
  }

  static double angleInDegreesWithOwnerRotation(double ownerRotation, double x1, double y1, double x2, double y2) {
    return (ownerRotation - angleInDegrees(x1, y1, x2, y2)).abs() % 360;
  }

  static double angleInDegrees(double originX, double originY, double targetX, double targetY) {
    return toDegrees(atan2(targetY - originY, targetX - originX));
  }

  static double toDegrees(num rad) => rad * 180.0 / PI;

  static double angleInRadians(double originX, double originY, double targetX, double targetY) {
    return atan2(targetY - originY, targetX - originX);
  }

  static bool shouldRotateCounterClockwise(double angleFrom, double angleTo) {
    double diff = (angleFrom - angleTo) % 360;
    return diff > 0 ? diff < 180 : diff < -180;
  }

  static double getRotatedX(double currentX, double currentY, double pivotX, double pivotY, double angleDegrees) {
    double x = currentX - pivotX;
    double y = currentY - pivotY;
    double xr = (x * TrigUtil.cosDeg(angleDegrees)) - (y * TrigUtil.sinDeg(angleDegrees));
    return xr + pivotX;
  }

  static double getRotatedY(double currentX, double currentY, double pivotX, double pivotY, double angleDegrees) {
    double x = currentX - pivotX;
    double y = currentY - pivotY;
    double yr = (x * TrigUtil.sinDeg(angleDegrees)) + (y * TrigUtil.cosDeg(angleDegrees));
    return yr + pivotY;
  }

  static double getXAtEndOfRotatedLineByOrigin(double x, double lineLength, double angleDegrees) {
    return x + TrigUtil.cosDeg(angleDegrees) * lineLength;
  }

  static double getYAtEndOfRotatedLineByOrigin(double y, double lineLength, double angleDegrees) {
    return y + TrigUtil.sinDeg(angleDegrees) * lineLength;
  }

  static bool collides(double x1, double y1, double radius1, double x2, double y2, double radius2) {
    double d = distance(x1, y1, x2, y2);

    d -= radius1 + radius2;

    return d < 0;
  }

  // TODO check dart:io
//  static String readFileContents(String file) {
//    InputStream is = Utils.class.getClassLoader().getResourceAsStream(file);
//    String contents = "";
//    try {
//      if (is != null) {
//        Writer writer = new StringWriter();
//
//        char[] buffer = new char[1024];
//        Reader reader = new BufferedReader(new InputStreamReader(is, "UTF-8"));
//        int n;
//        while ((n = reader.read(buffer)) != -1) {
//          writer.write(buffer, 0, n);
//        }
//
//        contents = writer.toString();
//      }
//    } catch (Exception e) {
//      e.printStackTrace();
//    } finally {
//      try {
//        is.close();
//      } catch (IOException e) {
//        e.printStackTrace();
//      }
//    }
//
//    return contents;
//  }
}
