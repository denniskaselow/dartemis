library aspect_test;

import 'package:test/test.dart';

import 'package:dartemis/dartemis.dart';
import 'components_setup.dart';

void main() {
  group('Aspect Tests', () {
    setUp(setUpComponents);
    test('getAspectForAll with one component', () {
      final aspect = Aspect.forAllOf([PooledComponentC]);
      expect(aspect.all, componentCBit);
      expect(aspect.excluded, BigInt.zero);
      expect(aspect.one, BigInt.zero);
    });
    test('getAspectForAll with all components', () {
      final aspect =
          Aspect.forAllOf([ComponentA, ComponentB, PooledComponentC]);
      expect(aspect.all, componentABit | componentBBit | componentCBit);
      expect(aspect.excluded, BigInt.zero);
      expect(aspect.one, BigInt.zero);
    });
    test('getAspectForAll with one component, excluding another one', () {
      final aspect = Aspect.forAllOf([PooledComponentC])..exclude([ComponentA]);
      expect(aspect.all, componentCBit);
      expect(aspect.excluded, componentABit);
      expect(aspect.one, BigInt.zero);
    });
    test('getAspectForAll with one component, excluding another two', () {
      final aspect = Aspect.forAllOf([PooledComponentC])
        ..exclude([ComponentA, ComponentB]);
      expect(aspect.all, componentCBit);
      expect(aspect.excluded, componentABit | componentBBit);
      expect(aspect.one, BigInt.zero);
    });
    test('getAspectForAll with one component, and one of two', () {
      final aspect = Aspect.forAllOf([PooledComponentC])
        ..oneOf([ComponentA, ComponentB]);
      expect(aspect.all, componentCBit);
      expect(aspect.excluded, BigInt.zero);
      expect(aspect.one, componentABit | componentBBit);
    });
    test('getAspectForOne with all components', () {
      final aspect =
          Aspect.forOneOf([ComponentA, ComponentB, PooledComponentC]);
      expect(aspect.all, BigInt.zero);
      expect(aspect.excluded, BigInt.zero);
      expect(aspect.one, componentABit | componentBBit | componentCBit);
    });
    test('getAspectForOne with chaining each component', () {
      final aspect = Aspect.forOneOf([ComponentA])
        ..oneOf([ComponentB])
        ..oneOf([PooledComponentC]);
      expect(aspect.all, BigInt.zero);
      expect(aspect.excluded, BigInt.zero);
      expect(aspect.one, componentABit | componentBBit | componentCBit);
    });
    test('getEmpty()', () {
      final aspect = Aspect.empty();
      expect(aspect.all, BigInt.zero);
      expect(aspect.excluded, BigInt.zero);
      expect(aspect.one, BigInt.zero);
    });
  });
}
