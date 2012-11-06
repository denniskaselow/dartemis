part of dartemis;

class Utils {

  static num cubicInterpolation(num v0, num v1, num v2, num v3, num t) {
    num t2 = t * t;
    num a0 = v3 - v2 - v0 + v1;
    num a1 = v0 - v1 - a0;
    num a2 = v2 - v0;
    num a3 = v1;

    return (a0 * (t * t2)) + (a1 * t2) + (a2 * t) + a3;
  }

  static num quadraticBezierInterpolation(num a, num b, num c, num t) {
    return (((1.0 - t) * (1.0 - t)) * a) + (((2.0 * t) * (1.0 - t)) * b) + ((t * t) * c);
  }

  static num lengthOfQuadraticBezierCurve(num x0, num y0, num x1, num y1, num x2, num y2) {
    if ((x0 == x1 && y0 == y1) || (x1 == x2 && y1 == y2)) {
      return distance(x0, y0, x2, y2);
    }

    num ax, ay, bx, by;
    ax = x0 - 2 * x1 + x2;
    ay = y0 - 2 * y1 + y2;
    bx = 2 * x1 - 2 * x0;
    by = 2 * y1 - 2 * y0;
    num A = 4 * (ax * ax + ay * ay);
    num B = 4 * (ax * bx + ay * by);
    num C = bx * bx + by * by;

    num Sabc = 2.0 * Math.sqrt(A + B + C);
    num A_2 = Math.sqrt(A);
    num A_32 = 2.0 * A * A_2;
    num C_2 = 2.0 * Math.sqrt(C);
    num BA = B / A_2;

    return (A_32 * Sabc + A_2 * B * (Sabc - C_2) + (4.0 * C * A - B * B) * Math.log((2 * A_2 + BA + Sabc) / (BA + C_2))) / (4 * A_32);
  }

  static num lerp(num a, num b, num t) {
    if (t < 0) {
      return a;
    }
    return a + t * (b - a);
  }

  static num distance(num x1, num y1, num x2, num y2) {
    return euclideanDistance(x1, y1, x2, y2);
  }

  static bool doCirclesCollide(num x1, num y1, num radius1, num x2, num y2, num radius2) {
    num dx = x2 - x1;
    num dy = y2 - y1;
    num d = radius1 + radius2;
    return (dx * dx + dy * dy) < (d * d);
  }

  static num euclideanDistanceSq2D(num x1, num y1, num x2, num y2) {
    num dx = x1 - x2;
    num dy = y1 - y2;
    return dx * dx + dy * dy;
  }

  static num manhattanDistance(num x1, num y1, num x2, num y2) {
    return (x1 - x2).abs() + (y1 - y2).abs();
  }

  static num euclideanDistance(num x1, num y1, num x2, num y2) {
    num a = x1 - x2;
    num b = y1 - y2;

    return FastMath.sqrt(a * a + b * b);
  }

  static num angleInDegreesWithOwnerRotation(num ownerRotation, num x1, num y1, num x2, num y2) {
    return (ownerRotation - angleInDegrees(x1, y1, x2, y2)).abs() % 360;
  }

  static num angleInDegrees(num originX, num originY, num targetX, num targetY) {
    return toDegrees(Math.atan2(targetY - originY, targetX - originX));
  }

  static num toDegrees(num rad) => rad * 180.0 / Math.PI;

  static num angleInRadians(num originX, num originY, num targetX, num targetY) {
    return Math.atan2(targetY - originY, targetX - originX);
  }

  static bool shouldRotateCounterClockwise(num angleFrom, num angleTo) {
    num diff = (angleFrom - angleTo) % 360;
    return diff > 0 ? diff < 180 : diff < -180;
  }

  static num getRotatedX(num currentX, num currentY, num pivotX, num pivotY, num angleDegrees) {
    num x = currentX - pivotX;
    num y = currentY - pivotY;
    num xr = (x * TrigUtil.cosDeg(angleDegrees)) - (y * TrigUtil.sinDeg(angleDegrees));
    return xr + pivotX;
  }

  static num getRotatedY(num currentX, num currentY, num pivotX, num pivotY, num angleDegrees) {
    num x = currentX - pivotX;
    num y = currentY - pivotY;
    num yr = (x * TrigUtil.sinDeg(angleDegrees)) + (y * TrigUtil.cosDeg(angleDegrees));
    return yr + pivotY;
  }

  static num getXAtEndOfRotatedLineByOrigin(num x, num lineLength, num angleDegrees) {
    return x + TrigUtil.cosDeg(angleDegrees) * lineLength;
  }

  static num getYAtEndOfRotatedLineByOrigin(num y, num lineLength, num angleDegrees) {
    return y + TrigUtil.sinDeg(angleDegrees) * lineLength;
  }

  static bool collides(num x1, num y1, num radius1, num x2, num y2, num radius2) {
    num d = distance(x1, y1, x2, y2);

    d -= radius1 + radius2;

    return d < 0;
  }

}
