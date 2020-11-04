library component_type_test;

import 'package:test/test.dart';

import 'package:dartemis/dartemis.dart';
import 'components_setup.dart';

void main() {
  group('ComponentType', () {
    test('returns correct bit', () {
      expect(ComponentType.getBitIndex(ComponentA), componentABit);
      expect(ComponentType.getBitIndex(ComponentB), componentBBit);
      expect(ComponentType.getBitIndex(PooledComponentC), componentCBit);
    });
  });
}
