library aspect_test;

import "package:test/test.dart";

import "package:dartemis/dartemis.dart";
import "components_setup.dart";


void main() {
  group('Aspect Tests', () {
    setUp(setUpComponents);
    test('getAspectForAll with one component', () {
      Aspect aspect = Aspect.getAspectForAllOf([componentC]);
      expect(aspect.all, componentCBit);
      expect(aspect.excluded, 0);
      expect(aspect.one, 0);
    });
    test('getAspectForAll with all components', () {
      Aspect aspect = Aspect.getAspectForAllOf([componentA, componentB, componentC]);
      expect(aspect.all, componentABit | componentBBit | componentCBit);
      expect(aspect.excluded, 0);
      expect(aspect.one, 0);
    });
    test('getAspectForAll with one component, excluding another one', () {
      Aspect aspect = Aspect.getAspectForAllOf([componentC]).exclude([componentA]);
      expect(aspect.all, componentCBit);
      expect(aspect.excluded, componentABit);
      expect(aspect.one, 0);
    });
    test('getAspectForAll with one component, excluding another two', () {
      Aspect aspect = Aspect.getAspectForAllOf([componentC]).exclude([componentA, componentB]);
      expect(aspect.all, componentCBit);
      expect(aspect.excluded, componentABit | componentBBit);
      expect(aspect.one, 0);
    });
    test('getAspectForAll with one component, and one of two', () {
      Aspect aspect = Aspect.getAspectForAllOf([componentC]).oneOf([componentA, componentB]);
      expect(aspect.all, componentCBit);
      expect(aspect.excluded, 0);
      expect(aspect.one, componentABit | componentBBit);
    });
    test('getAspectForOne with all components', () {
      Aspect aspect = Aspect.getAspectForOneOf([componentA, componentB, componentC]);
      expect(aspect.all, 0);
      expect(aspect.excluded, 0);
      expect(aspect.one, componentABit | componentBBit | componentCBit);
    });
    test('getAspectForOne with chaining each component', () {
      Aspect aspect = Aspect.getAspectForOneOf([componentA]).oneOf([componentB]).oneOf([componentC]);
      expect(aspect.all, 0);
      expect(aspect.excluded, 0);
      expect(aspect.one, componentABit | componentBBit | componentCBit);
    });
    test('getEmpty()', () {
      Aspect aspect = Aspect.getEmpty();
      expect(aspect.all, 0);
      expect(aspect.excluded, 0);
      expect(aspect.one, 0);
    });
  });
}