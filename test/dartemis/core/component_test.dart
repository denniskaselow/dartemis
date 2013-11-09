library component_test;

import "package:unittest/unittest.dart";

import "package:dartemis/dartemis.dart";
import "components_setup.dart";

void main() {
  group('Component tests', () {
    World world;
    setUp(() {
      world = new World();
    });
    test('creating a new Component creates a new instance', () {
      Entity e = world.createEntity();
      Component c = new ComponentA();
      e.addComponent(c);
      e.removeComponent(ComponentA);

      expect(new ComponentA(), isNot(same(c)));
    });
    test('creating a new FreeListComponent reuses a removed instance', () {
      Entity e = world.createEntity();
      Component c = new ComponentPoolableC();
      e.addComponent(c);

      expect(new ComponentPoolableC(), isNot(same(c)));
      e.removeComponent(ComponentPoolableC);
      expect(new ComponentPoolableC(), same(c));
    });
  });
}