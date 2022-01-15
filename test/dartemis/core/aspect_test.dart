library aspect_test;

import 'package:dartemis/dartemis.dart';
import 'package:dartemis/src/core/utils/bit_set.dart';
import 'package:test/test.dart';

import 'components_setup.dart';

void main() {
  group('Aspect Tests', () {
    test('getAspectForAll with one component', () {
      final aspect = Aspect.forAllOf([PooledComponent2]);
      expect(aspect.all, createBitSet([componentBit2]));
      expect(aspect.excluded, BitSet(64));
      expect(aspect.one, BitSet(64));
    });
    test('getAspectForAll with all components', () {
      final aspect =
          Aspect.forAllOf([Component0, Component1, PooledComponent2]);
      expect(aspect.all,
          createBitSet([componentBit0, componentBit1, componentBit2]));
      expect(aspect.excluded, BitSet(64));
      expect(aspect.one, BitSet(64));
    });
    test('getAspectForAll with one component, excluding another one', () {
      final aspect = Aspect.forAllOf([PooledComponent2])..exclude([Component0]);
      expect(aspect.all, createBitSet([componentBit2]));
      expect(aspect.excluded, createBitSet([componentBit0]));
      expect(aspect.one, BitSet(64));
    });
    test('getAspectForAll with one component, excluding another two', () {
      final aspect = Aspect.forAllOf([PooledComponent2])
        ..exclude([Component0, Component1]);
      expect(aspect.all, createBitSet([componentBit2]));
      expect(aspect.excluded, createBitSet([componentBit0, componentBit1]));
      expect(aspect.one, BitSet(64));
    });
    test('getAspectForAll with one component, and one of two', () {
      final aspect = Aspect.forAllOf([PooledComponent2])
        ..oneOf([Component0, Component1]);
      expect(aspect.all, createBitSet([componentBit2]));
      expect(aspect.excluded, BitSet(64));
      expect(aspect.one, createBitSet([componentBit0, componentBit1]));
    });
    test('getAspectForOne with all components', () {
      final aspect =
          Aspect.forOneOf([Component0, Component1, PooledComponent2]);
      expect(aspect.all, BitSet(64));
      expect(aspect.excluded, BitSet(64));
      expect(aspect.one,
          createBitSet([componentBit0, componentBit1, componentBit2]));
    });
    test('getAspectForOne with chaining each component', () {
      final aspect = Aspect.forOneOf([Component0])
        ..oneOf([Component1])
        ..oneOf([PooledComponent2]);
      expect(aspect.all, BitSet(64));
      expect(aspect.excluded, BitSet(64));
      expect(aspect.one,
          createBitSet([componentBit0, componentBit1, componentBit2]));
    });
    test('getEmpty()', () {
      final aspect = Aspect.empty();
      expect(aspect.all, BitSet(64));
      expect(aspect.excluded, BitSet(64));
      expect(aspect.one, BitSet(64));
    });
  });
}

BitSet createBitSet(List<int> trueIndices) {
  final result = BitSet(64);
  for (final index in trueIndices) {
    result[index] = true;
  }
  return result;
}
