import "package:unittest/unittest.dart";

main() {
  test('this is a test', () {
    int x = 2 + 3;
    expect(x, equals(5));
  });
}