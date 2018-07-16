library aspect_test;

import "package:test/test.dart";

import "package:dartemis/dartemis.dart";
import "components_setup.dart";

void main() {
  group('Aspect Tests', () {
    setUp(setUpComponents);
    test('getAspectForAll with one component', () {
      final aspect = Aspect.forAllOf([componentC]);
      expect(aspect.all, componentCBit);
      expect(aspect.excluded, 0);
      expect(aspect.one, 0);
    });
    test('getAspectForAll with all components', () {
      final aspect = Aspect.forAllOf([componentA, componentB, componentC]);
      expect(aspect.all, componentABit | componentBBit | componentCBit);
      expect(aspect.excluded, 0);
      expect(aspect.one, 0);
    });
    test('getAspectForAll with one component, excluding another one', () {
      final aspect = Aspect.forAllOf([componentC])..exclude([componentA]);
      expect(aspect.all, componentCBit);
      expect(aspect.excluded, componentABit);
      expect(aspect.one, 0);
    });
    test('getAspectForAll with one component, excluding another two', () {
      final aspect = Aspect.forAllOf([componentC])
        ..exclude([componentA, componentB]);
      expect(aspect.all, componentCBit);
      expect(aspect.excluded, componentABit | componentBBit);
      expect(aspect.one, 0);
    });
    test('getAspectForAll with one component, and one of two', () {
      final aspect = Aspect.forAllOf([componentC])
        ..oneOf([componentA, componentB]);
      expect(aspect.all, componentCBit);
      expect(aspect.excluded, 0);
      expect(aspect.one, componentABit | componentBBit);
    });
    test('getAspectForOne with all components', () {
      final aspect = Aspect.forOneOf([componentA, componentB, componentC]);
      expect(aspect.all, 0);
      expect(aspect.excluded, 0);
      expect(aspect.one, componentABit | componentBBit | componentCBit);
    });
    test('getAspectForOne with chaining each component', () {
      final aspect = Aspect.forOneOf([componentA])
        ..oneOf([componentB])
        ..oneOf([componentC]);
      expect(aspect.all, 0);
      expect(aspect.excluded, 0);
      expect(aspect.one, componentABit | componentBBit | componentCBit);
    });
    test('getEmpty()', () {
      final aspect = Aspect.empty();
      expect(aspect.all, 0);
      expect(aspect.excluded, 0);
      expect(aspect.one, 0);
    });
  });
}
