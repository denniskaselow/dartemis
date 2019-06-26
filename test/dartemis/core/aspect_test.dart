library aspect_test;

import 'package:dartemis/src/core/utils/bit_set.dart';
import 'package:test/test.dart';

import 'package:dartemis/dartemis.dart';
import 'components_setup.dart';

void main() {
  group('Aspect Tests', () {
    test('getAspectForAll with one component', () {
      final aspect = Aspect.forAllOf([PooledComponentC]);
      expect(aspect.all, createBitSet([componentCBit]));
      expect(aspect.excluded, BitSet(64));
      expect(aspect.one, BitSet(64));
    });
    test('getAspectForAll with all components', () {
      final aspect =
          Aspect.forAllOf([ComponentA, ComponentB, PooledComponentC]);
      expect(aspect.all,
          createBitSet([componentABit, componentBBit, componentCBit]));
      expect(aspect.excluded, BitSet(64));
      expect(aspect.one, BitSet(64));
    });
    test('getAspectForAll with one component, excluding another one', () {
      final aspect = Aspect.forAllOf([PooledComponentC])..exclude([ComponentA]);
      expect(aspect.all, createBitSet([componentCBit]));
      expect(aspect.excluded, createBitSet([componentABit]));
      expect(aspect.one, BitSet(64));
    });
    test('getAspectForAll with one component, excluding another two', () {
      final aspect = Aspect.forAllOf([PooledComponentC])
        ..exclude([ComponentA, ComponentB]);
      expect(aspect.all, createBitSet([componentCBit]));
      expect(aspect.excluded, createBitSet([componentABit, componentBBit]));
      expect(aspect.one, BitSet(64));
    });
    test('getAspectForAll with one component, and one of two', () {
      final aspect = Aspect.forAllOf([PooledComponentC])
        ..oneOf([ComponentA, ComponentB]);
      expect(aspect.all, createBitSet([componentCBit]));
      expect(aspect.excluded, BitSet(64));
      expect(aspect.one, createBitSet([componentABit, componentBBit]));
    });
    test('getAspectForOne with all components', () {
      final aspect =
          Aspect.forOneOf([ComponentA, ComponentB, PooledComponentC]);
      expect(aspect.all, BitSet(64));
      expect(aspect.excluded, BitSet(64));
      expect(aspect.one,
          createBitSet([componentABit, componentBBit, componentCBit]));
    });
    test('getAspectForOne with chaining each component', () {
      final aspect = Aspect.forOneOf([ComponentA])
        ..oneOf([ComponentB])
        ..oneOf([PooledComponentC]);
      expect(aspect.all, BitSet(64));
      expect(aspect.excluded, BitSet(64));
      expect(aspect.one,
          createBitSet([componentABit, componentBBit, componentCBit]));
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
