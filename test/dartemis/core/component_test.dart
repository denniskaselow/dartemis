library component_test;

import "package:test/test.dart";

import "package:dartemis/dartemis.dart";
import "components_setup.dart";

void main() {
  group('Component tests', () {
    World world;
    setUp(() {
      world = World();
    });
    test('creating a new Component creates a new instance', () {
      final entity = world.createEntity();
      final c = ComponentA();
      entity
        ..addComponent(c)
        ..removeComponent<ComponentA>();

      expect(ComponentA(), isNot(same(c)));
    });
    test('creating a new FreeListComponent reuses a removed instance', () {
      final entity = world.createEntity();
      final c = PooledComponentC();
      entity.addComponent(c);

      expect(PooledComponentC(), isNot(same(c)));
      entity.removeComponent<PooledComponentC>();
      expect(PooledComponentC(), same(c));
    });
  });
}
