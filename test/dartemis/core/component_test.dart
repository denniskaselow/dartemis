library component_test;

import "package:test/test.dart";

import "package:dartemis/dartemis.dart";
import "components_setup.dart";

void main() {
  group('Component tests', () {
    World world;
    setUp(() {
      world = new World();
    });
    test('creating a new Component creates a new instance', () {
      Entity entity = world.createEntity();
      Component c = new ComponentA();
      entity
        ..addComponent(c)
        ..removeComponent(ComponentA);

      expect(new ComponentA(), isNot(same(c)));
    });
    test('creating a new FreeListComponent reuses a removed instance', () {
      Entity entity = world.createEntity();
      Component c = new PooledComponentC();
      entity.addComponent(c);

      expect(new PooledComponentC(), isNot(same(c)));
      entity.removeComponent(PooledComponentC);
      expect(new PooledComponentC(), same(c));
    });
  });
}
