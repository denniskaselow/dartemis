library component_test;

import 'package:test/test.dart';

import 'package:dartemis/dartemis.dart';
import 'components_setup.dart';

void main() {
  group('Component tests', () {
    World world;
    setUp(() {
      world = World();
    });
    test('creating a new Component creates a new instance', () {
      final entity = world.createEntity();
      final c = ComponentA();
      world
        ..addComponent(entity, c)
        ..removeComponent<ComponentA>(entity);

      expect(ComponentA(), isNot(same(c)));
    });
    test('creating a new FreeListComponent reuses a removed instance', () {
      final entity = world.createEntity();
      final c = PooledComponentC();
      world.addComponent(entity, c);

      expect(PooledComponentC(), isNot(same(c)));
      world.removeComponent<PooledComponentC>(entity);
      expect(PooledComponentC(), same(c));
    });
  });
}
