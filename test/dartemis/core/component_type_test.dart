import 'package:dartemis/dartemis.dart';
import 'package:test/test.dart';

import 'components_setup.dart';

void main() {
  group('ComponentType', () {
    test('returns correct bit', () {
      expect(ComponentType.getBitIndex(Component0), componentBit0);
      expect(ComponentType.getBitIndex(Component1), componentBit1);
      expect(ComponentType.getBitIndex(PooledComponent2), componentBit2);
    });
  });
}
