library component_manager_test;

import 'package:dartemis/dartemis.dart';
import 'package:test/test.dart';

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
      var type = ComponentType();
      for (var i = 0; i < defaultBagSize; i++) {
        type = ComponentType();
      }
      final componentsByType = world.componentManager.getComponentsByType(type);
      expect(componentsByType.length, equals(0));
    });
    test('ComponentManager returns specific component for specific entity', () {
      final componentA = Component0();
      final entity = world.createEntity([componentA]);

      expect(
        world.componentManager.getComponent<Component0>(
          entity,
          ComponentType.getTypeFor(Component0),
        ),
        equals(componentA),
      );
    });
    test(
        'ComponentManager returns null if component for specific entity '
        'has not been registered', () {
      final entity = world.createEntity([Component0()]);

      expect(
        world.componentManager.getComponent<Component1>(
          entity,
          ComponentType.getTypeFor(Component1),
        ),
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
        world.componentManager.getComponent<Component1>(
          entity,
          ComponentType.getTypeFor(Component1),
        ),
        isNull,
      );
    });
    test(
        'ComponentManager returns null if no component for high index entity '
        'exist', () {
      final componentA = Component0();
      world.createEntity([componentA]);

      expect(
        world.componentManager.getComponent<Component0>(
          1000,
          ComponentType.getTypeFor(Component0),
        ),
        isNull,
      );
    });

    test('ComponentManager getComponent of components that were not added', () {
      final entity0 = world.createEntity();

      // Try to access more than 32 components
      world.componentManager.getComponent<Component0>(
        entity0,
        ComponentType.getTypeFor(Component0),
      );
      world.componentManager.getComponent<Component1>(
        entity0,
        ComponentType.getTypeFor(Component1),
      );
      world.componentManager.getComponent<PooledComponent2>(
        entity0,
        ComponentType.getTypeFor(PooledComponent2),
      );
      world.componentManager.getComponent<Component3>(
        entity0,
        ComponentType.getTypeFor(Component3),
      );
      world.componentManager.getComponent<Component4>(
        entity0,
        ComponentType.getTypeFor(Component4),
      );
      world.componentManager.getComponent<Component5>(
        entity0,
        ComponentType.getTypeFor(Component5),
      );
      world.componentManager.getComponent<Component6>(
        entity0,
        ComponentType.getTypeFor(Component6),
      );
      world.componentManager.getComponent<Component7>(
        entity0,
        ComponentType.getTypeFor(Component7),
      );
      world.componentManager.getComponent<Component8>(
        entity0,
        ComponentType.getTypeFor(Component8),
      );
      world.componentManager.getComponent<Component9>(
        entity0,
        ComponentType.getTypeFor(Component9),
      );
      world.componentManager.getComponent<Component10>(
        entity0,
        ComponentType.getTypeFor(Component10),
      );
      world.componentManager.getComponent<Component11>(
        entity0,
        ComponentType.getTypeFor(Component11),
      );
      world.componentManager.getComponent<Component12>(
        entity0,
        ComponentType.getTypeFor(Component12),
      );
      world.componentManager.getComponent<Component13>(
        entity0,
        ComponentType.getTypeFor(Component13),
      );
      world.componentManager.getComponent<Component14>(
        entity0,
        ComponentType.getTypeFor(Component14),
      );
      world.componentManager.getComponent<Component15>(
        entity0,
        ComponentType.getTypeFor(Component15),
      );
      world.componentManager.getComponent<Component16>(
        entity0,
        ComponentType.getTypeFor(Component16),
      );
      world.componentManager.getComponent<Component17>(
        entity0,
        ComponentType.getTypeFor(Component17),
      );
      world.componentManager.getComponent<Component18>(
        entity0,
        ComponentType.getTypeFor(Component18),
      );
      world.componentManager.getComponent<Component19>(
        entity0,
        ComponentType.getTypeFor(Component19),
      );
      world.componentManager.getComponent<Component20>(
        entity0,
        ComponentType.getTypeFor(Component20),
      );
      world.componentManager.getComponent<Component21>(
        entity0,
        ComponentType.getTypeFor(Component21),
      );
      world.componentManager.getComponent<Component22>(
        entity0,
        ComponentType.getTypeFor(Component22),
      );
      world.componentManager.getComponent<Component23>(
        entity0,
        ComponentType.getTypeFor(Component23),
      );
      world.componentManager.getComponent<Component24>(
        entity0,
        ComponentType.getTypeFor(Component24),
      );
      world.componentManager.getComponent<Component25>(
        entity0,
        ComponentType.getTypeFor(Component25),
      );
      world.componentManager.getComponent<Component26>(
        entity0,
        ComponentType.getTypeFor(Component26),
      );
      world.componentManager.getComponent<Component27>(
        entity0,
        ComponentType.getTypeFor(Component27),
      );
      world.componentManager.getComponent<Component28>(
        entity0,
        ComponentType.getTypeFor(Component28),
      );
      world.componentManager.getComponent<Component29>(
        entity0,
        ComponentType.getTypeFor(Component29),
      );
      world.componentManager.getComponent<Component30>(
        entity0,
        ComponentType.getTypeFor(Component30),
      );
      world.componentManager.getComponent<Component31>(
        entity0,
        ComponentType.getTypeFor(Component31),
      );
      final component32 = world.componentManager.getComponent<Component32>(
        entity0,
        ComponentType.getTypeFor(Component32),
      );
      expect(component32, isNull);

      // Try to remove an out of bound components info
      world.removeComponent<Component32>(entity0);

      // Try to list components where ComponentType._nextBitIndex >= 32
      expect(world.componentManager.getComponentsFor(entity0), isEmpty);

      // Trying to get components that were not added should not register them
      expect(
        world.componentManager.getComponentsByType<Component32>(
          ComponentType.getTypeFor(Component32),
        ),
        isEmpty,
      );
    });
  });
}
