library asset_wrapper_test;

import 'package:unittest/unittest.dart';
import 'package:dartemis/transformer.dart';

void main() {
  group('AssetWrapper', () {
    AssetWrapper wrapper;
    setUp(() {
      wrapper = new AssetWrapper(null, null, 'abcdef');
    });
    test('handles simple insertion', () {
      wrapper.insert(3, '-');

      expect(wrapper.content, equals('abc-def'));
    });
    test('moves insertions point on subsequent insertions', () {
      wrapper.insert(3, '-');
      wrapper.insert(3, '+');

      expect(wrapper.content, equals('abc-+def'));
    });
    test('inserts at correct position between two previous insertions', () {
      wrapper.insert(2, '-');
      wrapper.insert(4, '-');
      wrapper.insert(3, '+');

      expect(wrapper.content, equals('ab-c+d-ef'));
    });
    test('handles simeple replacement', () {
      wrapper.replace('cd', 'c-d', 2);

      expect(wrapper.content, equals('abc-def'));
    });
  });
}