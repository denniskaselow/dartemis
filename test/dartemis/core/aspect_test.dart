library aspect_test;

import "package:unittest/unittest.dart";

import "package:dartemis/dartemis.dart";
import "components_setup.dart";


void main() {
  group('Aspect Tests', () {
    setUp(() => setUpComponents());
    test('getAspectForAll with one component', () {
      Aspect aspect = Aspect.getAspectForAllOf([COMPONENT_C]);
      expect(aspect.all, COMPONENT_C_BIT);
      expect(aspect.excluded, 0);
      expect(aspect.one, 0);
    });
    test('getAspectForAll with all components', () {
      Aspect aspect = Aspect.getAspectForAllOf([COMPONENT_A, COMPONENT_B, COMPONENT_C]);
      expect(aspect.all, COMPONENT_A_BIT | COMPONENT_B_BIT | COMPONENT_C_BIT);
      expect(aspect.excluded, 0);
      expect(aspect.one, 0);
    });
    test('getAspectForAll with one component, excluding another one', () {
      Aspect aspect = Aspect.getAspectForAllOf([COMPONENT_C]).exclude([COMPONENT_A]);
      expect(aspect.all, COMPONENT_C_BIT);
      expect(aspect.excluded, COMPONENT_A_BIT);
      expect(aspect.one, 0);
    });
    test('getAspectForAll with one component, excluding another two', () {
      Aspect aspect = Aspect.getAspectForAllOf([COMPONENT_C]).exclude([COMPONENT_A, COMPONENT_B]);
      expect(aspect.all, COMPONENT_C_BIT);
      expect(aspect.excluded, COMPONENT_A_BIT | COMPONENT_B_BIT);
      expect(aspect.one, 0);
    });
    test('getAspectForAll with one component, and one of two', () {
      Aspect aspect = Aspect.getAspectForAllOf([COMPONENT_C]).oneOf([COMPONENT_A, COMPONENT_B]);
      expect(aspect.all, COMPONENT_C_BIT);
      expect(aspect.excluded, 0);
      expect(aspect.one, COMPONENT_A_BIT | COMPONENT_B_BIT);
    });
    test('getAspectForOne with all components', () {
      Aspect aspect = Aspect.getAspectForOneOf([COMPONENT_A, COMPONENT_B, COMPONENT_C]);
      expect(aspect.all, 0);
      expect(aspect.excluded, 0);
      expect(aspect.one, COMPONENT_A_BIT | COMPONENT_B_BIT | COMPONENT_C_BIT);
    });
    test('getAspectForOne with chaining each component', () {
      Aspect aspect = Aspect.getAspectForOneOf([COMPONENT_A]).oneOf([COMPONENT_B]).oneOf([COMPONENT_C]);
      expect(aspect.all, 0);
      expect(aspect.excluded, 0);
      expect(aspect.one, COMPONENT_A_BIT | COMPONENT_B_BIT | COMPONENT_C_BIT);
    });
    test('getEmpty()', () {
      Aspect aspect = Aspect.getEmpty();
      expect(aspect.all, 0);
      expect(aspect.excluded, 0);
      expect(aspect.one, 0);
    });
  });
}