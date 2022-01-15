library component_test;

import 'package:dartemis/dartemis.dart';
import 'package:test/test.dart';

import 'components_setup.dart';

void main() {
  group('Component tests', () {
    late World world;
    setUp(() {
      world = World();
    });
    test('creating a new Component creates a new instance', () {
      final entity = world.createEntity();
      final c = Component0();
      world
        ..addComponent(entity, c)
        ..removeComponent<Component0>(entity);

      expect(Component0(), isNot(same(c)));
    });
    test('creating a new FreeListComponent reuses a removed instance', () {
      final entity = world.createEntity();
      final c = PooledComponent2();
      world.addComponent(entity, c);

      expect(PooledComponent2(), isNot(same(c)));
      world.removeComponent<PooledComponent2>(entity);
      expect(PooledComponent2(), same(c));
    });
  });
}
