library component_type_test;

import "package:test/test.dart";

import "package:dartemis/dartemis.dart";
import "components_setup.dart";

void main() {
  group('ComponentType', () {
    setUp(setUpComponents);
    test('returns correct bit', () {
      expect(ComponentTypeManager.getBit(ComponentA), componentABit);
      expect(ComponentTypeManager.getBit(ComponentB), componentBBit);
      expect(ComponentTypeManager.getBit(PooledComponentC), componentCBit);
    });
  });
}
