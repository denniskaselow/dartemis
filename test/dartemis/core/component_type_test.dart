library component_type_test;

import "package:test/test.dart";

import "package:dartemis/dartemis.dart";
import "components_setup.dart";

void main() {
  group('ComponentType', () {
    setUp(setUpComponents);
    test('returns correct bit', () {
      expect(ComponentTypeManager.getBit(COMPONENT_A), COMPONENT_A_BIT);
      expect(ComponentTypeManager.getBit(COMPONENT_B), COMPONENT_B_BIT);
      expect(ComponentTypeManager.getBit(COMPONENT_C), COMPONENT_C_BIT);
    });
  });
}