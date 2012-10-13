import "package:unittest/unittest.dart";
import "package:dartemis/dartemis.dart";

final String COMPONENT_A = "ComponentA";
final String COMPONENT_B = "ComponentB";
final String COMPONENT_C = "ComponentC";

final int COMPONENT_A_BIT = 0x0001;
final int COMPONENT_B_BIT = 0x0002;
final int COMPONENT_C_BIT = 0x0004;

main() {
  test('ComponentType Test', () {
    expect(ComponentTypeManager.getBit(COMPONENT_A), COMPONENT_A_BIT);
    expect(ComponentTypeManager.getBit(COMPONENT_B), COMPONENT_B_BIT);
    expect(ComponentTypeManager.getBit(COMPONENT_C), COMPONENT_C_BIT);
  });
  group('Aspect Tests', () {
    test('getAspectForAll with one component', () {
      Aspect aspect = Aspect.getAspectForAllOf(COMPONENT_C);
      expect(aspect.all, COMPONENT_C_BIT);
      expect(aspect.excluded, 0);
      expect(aspect.one, 0);
    });
    test('getAspectForAll with all components', () {
      Aspect aspect = Aspect.getAspectForAllOf(COMPONENT_A, [COMPONENT_B, COMPONENT_C]);
      expect(aspect.all, COMPONENT_A_BIT | COMPONENT_B_BIT | COMPONENT_C_BIT);
      expect(aspect.excluded, 0);
      expect(aspect.one, 0);
    });
    test('getAspectForAll with one component, excluding another one', () {
      Aspect aspect = Aspect.getAspectForAllOf(COMPONENT_C).exclude(COMPONENT_A);
      expect(aspect.all, COMPONENT_C_BIT);
      expect(aspect.excluded, COMPONENT_A_BIT);
      expect(aspect.one, 0);
    });
    test('getAspectForAll with one component, excluding another two', () {
      Aspect aspect = Aspect.getAspectForAllOf(COMPONENT_C).exclude(COMPONENT_A, [COMPONENT_B]);
      expect(aspect.all, COMPONENT_C_BIT);
      expect(aspect.excluded, COMPONENT_A_BIT | COMPONENT_B_BIT);
      expect(aspect.one, 0);
    });
    test('getAspectForAll with one component, and one of two', () {
      Aspect aspect = Aspect.getAspectForAllOf(COMPONENT_C).oneOf(COMPONENT_A, [COMPONENT_B]);
      expect(aspect.all, COMPONENT_C_BIT);
      expect(aspect.excluded, 0);
      expect(aspect.one, COMPONENT_A_BIT | COMPONENT_B_BIT);
    });
    test('getAspectForOne with all components', () {
      Aspect aspect = Aspect.getAspectForOneOf(COMPONENT_A, [COMPONENT_B, COMPONENT_C]);
      expect(aspect.all, 0);
      expect(aspect.excluded, 0);
      expect(aspect.one, COMPONENT_A_BIT | COMPONENT_B_BIT | COMPONENT_C_BIT);
    });
    test('getAspectForOne with chaining each component', () {
      Aspect aspect = Aspect.getAspectForOneOf(COMPONENT_A).oneOf(COMPONENT_B).oneOf(COMPONENT_C);
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