import 'package:dartemis/dartemis.dart';
import 'package:test/test.dart';

import 'components_setup.dart';

void main() {
  group('integration tests for ComponentManager', () {
    late World world;
    setUp(() {
      world = World();
    });
    test('returns correct bit', () {
      final componentManager = world.getManager<ComponentManager>();
      expect(componentManager.getBitIndex(Component0), 0);
      expect(componentManager.getBitIndex(Component1), 1);
      expect(componentManager.getBitIndex(PooledComponent2), 2);
    });
    test('ComponentManager correctly associates entity and components', () {
      final entity = world.createEntity();
      final componentA = Component0();
      final componentC = PooledComponent2();
      world.addComponents(entity, [componentA, componentC]);

      final components = world.getComponents(entity);

      expect(components, containsAll([componentA, componentC]));
      expect(components.length, equals(2));
    });
    test('ComponentManager correctly associates multiple entity and components',
        () {
      final entity1 = world.createEntity();
      final component1A = Component0();
      final component1C = PooledComponent2();
      world
        ..addComponent(entity1, component1A)
        ..addComponent(entity1, component1C);

      final entity2 = world.createEntity();
      final component2A = Component0();
      final component2B = Component1();
      final component2C = PooledComponent2();
      world.addComponents(entity2, [component2A, component2B, component2C]);

      final components1 = world.getComponents(entity1);
      final components2 = world.getComponents(entity2);

      expect(components1, containsAll([component1A, component1C]));
      expect(components1.length, equals(2));

      expect(components2, containsAll([component2A, component2B, component2C]));
      expect(components2.length, equals(3));
    });
    test('ComponentManager removes Components of deleted entity', () {
      final entity = world.createEntity();
      final componentA = Component0();
      final componentC = PooledComponent2();
      world
        ..addComponents(entity, [componentA, componentC])
        ..addEntity(entity)
        ..initialize()
        ..process()
        ..deleteEntity(entity)
        ..process();

      final fillBag = world.getComponents(entity);
      expect(fillBag.length, equals(0));
    });
    test('ComponentManager can be created for unused Component', () {
      final componentsByType =
          world.componentManager.getComponentsByType<UnusedComponent>();
      expect(componentsByType.length, equals(0));
    });
    test('ComponentManager returns specific component for specific entity', () {
      final componentA = Component0();
      final entity = world.createEntity([componentA]);

      expect(
        world.componentManager.getComponent<Component0>(entity),
        equals(componentA),
      );
    });
    test(
        'ComponentManager returns null if component for specific entity '
        'has not been registered', () {
      final entity = world.createEntity([Component0()]);

      expect(
        world.componentManager.getComponent<Component1>(entity),
        isNull,
      );
    });
    test(
        'ComponentManager returns null if component for specific entity does '
        'not exist', () {
      final entity = world.createEntity([Component0()]);
      // create an entity with the component we want to access so it gets
      // registered with the ComponentManager and a _ComponentInfo to access
      // is created
      world.createEntity([Component1()]);

      expect(
        world.componentManager.getComponent<Component1>(entity),
        isNull,
      );
    });
    test(
        'ComponentManager returns null if no component for high index entity '
        'exist', () {
      final componentA = Component0();
      world.createEntity([componentA]);
      for (var i = 0; i < 1000; i++) {
        world.createEntity<Component>([]);
      }
      final highIdEntity = world.createEntity<Component>([]);

      expect(
        world.componentManager.getComponent<Component0>(highIdEntity),
        isNull,
      );
    });
  });
}
