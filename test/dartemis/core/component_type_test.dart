library component_type_test;

import 'package:test/test.dart';

import 'package:dartemis/dartemis.dart';
import 'components_setup.dart';

void main() {
  group('ComponentType', () {
    test('returns correct bit', () {
      expect(ComponentTypeManager.getBitIndex(ComponentA), componentABit);
      expect(ComponentTypeManager.getBitIndex(ComponentB), componentBBit);
      expect(ComponentTypeManager.getBitIndex(PooledComponentC), componentCBit);
    });
  });
}
