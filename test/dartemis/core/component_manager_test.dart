library component_manager_test;

import 'package:test/test.dart';

import 'package:dartemis/dartemis.dart';
import 'components_setup.dart';

const int defaultBagSize = 16;

void main() {
  group('integration tests for ComponentManager', () {
    late World world;
    setUp(() {
      world = World();
    });
    test('ComponentManager correctly associates entity and components', () {
      final entity = world.createEntity();
      final componentA = ComponentA();
      final componentC = PooledComponentC();
      world.addComponents(entity, [componentA, componentC]);

      final fillBag = world.getComponents(entity);

      expect(fillBag[0], equals(componentA));
      expect(fillBag[1], equals(componentC));
      expect(fillBag.size, equals(2));
    });
    test('ComponentManager correctly associates multiple entity and components',
        () {
      final entity1 = world.createEntity();
      final component1A = ComponentA();
      final component1C = PooledComponentC();
      world
        ..addComponent(entity1, component1A)
        ..addComponent(entity1, component1C);

      final entity2 = world.createEntity();
      final component2A = ComponentA();
      final component2B = ComponentB();
      final component2C = PooledComponentC();
      world.addComponents(entity2, [component2A, component2B, component2C]);

      final fillBag1 = world.getComponents(entity1);
      final fillBag2 = world.getComponents(entity2);

      expect(fillBag1, containsAll([component1A, component1C]));
      expect(fillBag1.size, equals(2));

      expect(fillBag2, containsAll([component2A, component2B, component2C]));
      expect(fillBag2.size, equals(3));
    });
    test('ComponentManager removes Components of deleted entity', () {
      final entity = world.createEntity();
      final componentA = ComponentA();
      final componentC = PooledComponentC();
      world
        ..addComponents(entity, [componentA, componentC])
        ..addEntity(entity)
        ..initialize()
        ..process()
        ..deleteEntity(entity)
        ..process();

      final fillBag = world.getComponents(entity);
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
