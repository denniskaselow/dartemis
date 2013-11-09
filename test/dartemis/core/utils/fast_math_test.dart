library fast_math_test;

import "dart:math" as Math;

import "package:unittest/unittest.dart";

import "package:dartemis/dartemis.dart";

void main() {
  group('FastMath tests', () {
    compareFunctions(double mathFunc(num arg), double fastMathFunc(num arg1)) {
      double diff;
      for (double angle = -4 * Math.PI; angle < 4.01 * Math.PI; angle += Math.PI / 4) {
        diff = mathFunc(angle) - fastMathFunc(angle);
        expect(diff.abs(), lessThan(0.0025), reason: "for angle: $angle");
      }
    }
    compareArcFunctions(double mathFunc(num arg), double fastMathFunc(num arg1)) {
      double diff;
      for (double value = -1.0; value <= 1.0; value += 0.25) {
        diff = mathFunc(value) - fastMathFunc(value);
        expect(diff.abs(), lessThan(0.0025), reason: "for value: $value");
      }
    }
    test('FastMath.sin is close to Math.sin', () {
      compareFunctions(Math.sin, FastMath.sin);
    });
    test('FastMath.cos is close to Math.cos', () {
      compareFunctions(Math.cos, FastMath.cos);
    });
    test('FastMath.asin is close to Math.asin', () {
      compareArcFunctions(Math.asin, FastMath.asin);
    });
    test('FastMath.acos is close to Math.acos', () {
      compareArcFunctions(Math.acos, FastMath.acos);
    });
  });
}