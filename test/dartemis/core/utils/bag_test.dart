library bag_test;

import 'package:test/test.dart';

import 'package:dartemis/dartemis.dart';

void main() {
  group('Bag tests', () {
    Bag<String> sut;
    setUp(() {
      sut = Bag<String>(capacity: 1)..add('A')..add('B');
    });
    test('removing an element', () {
      sut.remove('A');
      expect(sut.contains('A'), equals(false));
      expect(sut.contains('B'), equals(true));
      expect(sut.size, equals(1));
    });
    test('removing at position', () {
      sut.removeAt(0);
      expect(sut.contains('A'), equals(false));
      expect(sut.contains('B'), equals(true));
      expect(sut.size, equals(1));
    });
    test('clear', () {
      sut.clear();
      expect(sut.size, equals(0));
    });
    test('setting a value by index should not shrink the bag', () {
      sut[9] = 'A';
      sut[5] = 'B';
      expect(sut.size, equals(10));
    });
  });
}
