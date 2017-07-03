library component_manager_test;

import "package:test/test.dart";

import "package:dartemis/dartemis.dart";
import "components_setup.dart";

const int defaultBagSize = 16;

void main() {
  group('integration tests for ComponentManager', () {
    World world;
    setUp(() {
      // for predictable component indices
      setUpComponents();
      world = new World();
    });
    test('ComponentManager correctly associates entity and components', () {
      Entity entity = world.createEntity();
      Component componentA = new ComponentA();
      Component componentC = new PooledComponentC();
      entity..addComponent(componentA)..addComponent(componentC);

      Bag<Component> fillBag = entity.getComponents();

      expect(fillBag[0], equals(componentA));
      expect(fillBag[1], equals(componentC));
      expect(fillBag.size, equals(2));
    });
    test('ComponentManager correctly associates multiple entity and components',
        () {
      Entity entity1 = world.createEntity();
      Component component1A = new ComponentA();
      Component component1C = new PooledComponentC();
      entity1..addComponent(component1A)..addComponent(component1C);

      Entity entity2 = world.createEntity();
      Component component2A = new ComponentA();
      Component component2B = new ComponentB();
      Component component2C = new PooledComponentC();
      entity2
        ..addComponent(component2A)
        ..addComponent(component2B)
        ..addComponent(component2C);

      Bag<Component> fillBag1 = entity1.getComponents();
      Bag<Component> fillBag2 = entity2.getComponents();

      expect(fillBag1[0], equals(component1A));
      expect(fillBag1[1], equals(component1C));
      expect(fillBag1.size, equals(2));

      expect(fillBag2[0], equals(component2A));
      expect(fillBag2[1], equals(component2B));
      expect(fillBag2[2], equals(component2C));
      expect(fillBag2.size, equals(3));
    });
    test('ComponentManager removes Components of deleted Entity', () {
      Entity entity = world.createEntity();
      Component componentA = new ComponentA();
      Component componentC = new PooledComponentC();
      entity..addComponent(componentA)..addComponent(componentC);
      world
        ..addEntity(entity)
        ..initialize()
        ..process()
        ..deleteEntity(entity)
        ..process();

      Bag<Component> fillBag = entity.getComponents();
      expect(fillBag.size, equals(0));
    });
    test('ComponentManager can be created for unused Component', () {
      ComponentType type = new ComponentType();
      for (int i = 0; i < defaultBagSize; i++) {
        type = new ComponentType();
      }
      Bag<Component> componentsByType =
          world.componentManager.getComponentsByType(type);
      expect(componentsByType.size, equals(0));
    });
  });
}
