library component_manager_test;

import 'package:test/test.dart';

import 'package:dartemis/dartemis.dart';
import 'components_setup.dart';

const int defaultBagSize = 16;

void main() {
  group('integration tests for ComponentManager', () {
    World world;
    setUp(() {
      world = World();
    });
    test('ComponentManager correctly associates entity and components', () {
      final entity = world.createEntity();
      final componentA = ComponentA();
      final componentC = PooledComponentC();
      entity..addComponent(componentA)..addComponent(componentC);

      final fillBag = entity.getComponents();

      expect(fillBag[0], equals(componentA));
      expect(fillBag[1], equals(componentC));
      expect(fillBag.size, equals(2));
    });
    test('ComponentManager correctly associates multiple entity and components',
        () {
      final entity1 = world.createEntity();
      final component1A = ComponentA();
      final component1C = PooledComponentC();
      entity1..addComponent(component1A)..addComponent(component1C);

      final entity2 = world.createEntity();
      final component2A = ComponentA();
      final component2B = ComponentB();
      final component2C = PooledComponentC();
      entity2
        ..addComponent(component2A)
        ..addComponent(component2B)
        ..addComponent(component2C);

      final fillBag1 = entity1.getComponents();
      final fillBag2 = entity2.getComponents();

      expect(fillBag1, containsAll([component1A, component1C]));
      expect(fillBag1.size, equals(2));

      expect(fillBag2, containsAll([component2A, component2B, component2C]));
      expect(fillBag2.size, equals(3));
    });
    test('ComponentManager removes Components of deleted Entity', () {
      final entity = world.createEntity();
      final componentA = ComponentA();
      final componentC = PooledComponentC();
      entity..addComponent(componentA)..addComponent(componentC);
      world
        ..addEntity(entity)
        ..initialize()
        ..process()
        ..deleteEntity(entity)
        ..process();

      final fillBag = entity.getComponents();
      expect(fillBag.size, equals(0));
    });
    test('ComponentManager can be created for unused Component', () {
      var type = ComponentType();
      for (var i = 0; i < defaultBagSize; i++) {
        type = ComponentType();
      }
      final componentsByType = world.componentManager.getComponentsByType(type);
      expect(componentsByType.size, equals(0));
    });
  });
}
