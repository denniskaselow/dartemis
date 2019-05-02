library world_test;

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:dartemis/dartemis.dart';
import 'components_setup.dart';

void main() {
  group('World tests', () {
    World world;
    MockEntitySystem system;
    setUp(() {
      world = World();
      system = MockEntitySystem();
      when(system.passive).thenReturn(false);
      when(system.group).thenReturn(0);
    });
    test('world initializes added system', () {
      world
        ..addSystem(system)
        ..initialize();

      verify(system.initialize()).called(1);
    });
    test('world processes added system', () {
      world
        ..addSystem(system)
        ..process();

      verify(system.process()).called(1);
    });
    test('world does not process passive system', () {
      when(system.passive).thenReturn(true);

      world
        ..addSystem(system, passive: true)
        ..process();

      verifyNever(system.process());
    });
    test('world processes systems by group', () {
      final system2 = MockEntitySystem2();
      when(system2.passive).thenReturn(false);
      when(system2.group).thenReturn(1);

      world
        ..addSystem(system)
        ..addSystem(system2, group: 1)
        ..process(0);
      verify(system.process()).called(1);
      verifyNever(system2.process());

      world.process(1);
      verifyNever(system.process());
      verify(system2.process()).called(1);
    });
    test('world manages time and frames by group', () {
      final system2 = MockEntitySystem2();
      when(system2.passive).thenReturn(false);
      when(system2.group).thenReturn(1);

      world
        ..addSystem(system)
        ..addSystem(system2, group: 1)
        ..delta = 10.0
        ..process(0)
        ..delta = 20.0
        ..process(1)
        ..delta = 15.0
        ..process(0);

      expect(world.time(0), equals(25.0));
      expect(world.time(1), equals(20.0));
      expect(world.frame(0), equals(2));
      expect(world.frame(1), equals(1));
    });
    test('world initializes added managers', () {
      final manager = MockManager();
      world
        ..addManager(manager)
        ..initialize();

      verify(manager.initialize()).called(1);
    });
    test('world deletes all entites', () {
      world.initialize();
      world.createEntity().addToWorld();
      world.createEntity().addToWorld();
      world.process();

      expect(world.entityManager.activeEntityCount, equals(2));
      world.deleteAllEntities();
      expect(world.entityManager.activeEntityCount, equals(0));
    });
    test('world delete all entites should not fail if called twice', () {
      world.initialize();
      world.createEntity().addToWorld();
      world
        ..process()
        ..deleteAllEntities()
        ..deleteAllEntities();
    });
    test('world process increments frame count', () {
      world
        ..initialize()
        ..process();
      expect(world.frame(), equals(1));
      world.process();
      expect(world.frame(), equals(2));
    });
    test('world process increments time by delta', () {
      world
        ..initialize()
        ..delta = 10
        ..process();
      expect(world.time(), equals(10));
      world
        ..delta = 20
        ..process();
      expect(world.time(), equals(30));
    });
    test('world allows access to properties', () {
      world['key'] = 'value';

      expect(world['key'], equals('value'));
    });
    test('destroy calls destroy method on systems', () {
      world
        ..addSystem(system)
        ..process()
        ..destroy();

      verify(system.destroy()).called(1);
    });
    test('destroy calls destroy method on managers', () {
      final manager = MockManager();
      world
        ..addManager(manager)
        ..initialize()
        ..destroy();

      verify(manager.destroy()).called(1);
    });
  });
  group('integration tests for World.process()', () {
    World world;
    Entity entityAB;
    Entity entityAC;
    EntitySystemStarter systemStarter;
    setUp(() {
      world = World();
      entityAB = world.createAndAddEntity([ComponentA(), ComponentB()]);
      entityAC = world.createEntity()
        ..addComponent(ComponentA())
        ..addComponent(PooledComponentC())
        ..addToWorld();
      systemStarter = (es, action) {
        world
          ..addSystem(es)
          ..initialize()
          ..process();
        action();
        world.process();
      };
    });
    test('''
EntitySystem which requires one Component processes Entity with this component''',
        () {
      final expectedEntities = [entityAB, entityAC];
      final es =
          TestEntitySystem(Aspect.forAllOf([ComponentA]), expectedEntities);
      systemStarter(es, () {});
    });
    test('''
EntitySystem which required multiple Components does not process Entity with a subset of those components''',
        () {
      final expectedEntities = [entityAB];
      final es = TestEntitySystem(
          Aspect.forAllOf([ComponentA, ComponentB]), expectedEntities);
      systemStarter(es, () {});
    });
    test('''
EntitySystem which requires one of multiple components processes Entity with a subset of those components''',
        () {
      final expectedEntities = [entityAB, entityAC];
      final es = TestEntitySystem(
          Aspect.forOneOf([ComponentA, ComponentB]), expectedEntities);
      systemStarter(es, () {});
    });
    test('''
EntitySystem which excludes a component does not process Entity with one of those components''',
        () {
      final expectedEntities = [entityAB];
      final es = TestEntitySystem(
          Aspect.forAllOf([ComponentA])..exclude([PooledComponentC]),
          expectedEntities);
      systemStarter(es, () {});
    });
    test('A removed entity will not get processed', () {
      final expectedEntities = [entityAC];
      final es =
          TestEntitySystem(Aspect.forAllOf([ComponentA]), expectedEntities);
      systemStarter(es, () => entityAB.deleteFromWorld());
    });
    test('A disabled entity will not get processed', () {
      final expectedEntities = [entityAC];
      final es =
          TestEntitySystem(Aspect.forAllOf([ComponentA]), expectedEntities);
      systemStarter(es, () => entityAB.disable());
    });
    test('''
Adding a component will not get the entity processed if the world is not notified of the change''',
        () {
      final expectedEntities = [entityAC];
      final es = TestEntitySystem(
          Aspect.forAllOf([PooledComponentC]), expectedEntities);
      world
        ..addSystem(es)
        ..initialize()
        ..process();
      entityAB.addComponent(PooledComponentC());
      world.process();
    });
    test('An entity that\'s been deleted twice, can only be reused once', () {
      entityAB..deleteFromWorld()..deleteFromWorld();
      final componentA = ComponentA();
      final componentB = ComponentB();

      world.process();
      final entityA = world.createAndAddEntity([componentA]);
      final entityB = world.createAndAddEntity([componentB]);
      world.process();

      expect(entityA.getComponents()[0], equals(componentA));
      expect(entityB.getComponents()[0], equals(componentB));
      expect(entityA.getComponents().length, equals(1));
      expect(entityB.getComponents().length, equals(1));
    });
    test('''
Adding a component will not get the entity processed if the world is not notified of the change''',
        () {
      final expectedEntities = [entityAC];
      final es = TestEntitySystem(
          Aspect.forAllOf([PooledComponentC]), expectedEntities);
      world
        ..addSystem(es)
        ..initialize()
        ..process();
      entityAB.addComponent(PooledComponentC());
      world.process();
    });
    test('''
Adding a component will get the entity processed if the world is notified of the change''',
        () {
      final expectedEntities = [entityAC];
      final es = TestEntitySystem(
          Aspect.forAllOf([PooledComponentC]), expectedEntities);
      world
        ..addSystem(es)
        ..initialize()
        ..process();
      es._expectedEntities = [entityAB, entityAC];
      entityAB
        ..addComponent(PooledComponentC())
        ..changedInWorld();
      world.process();
    });
    test('Enabling a disabled component will get the entity processed', () {
      entityAB.disable();
      final expectedEntities = [entityAC];
      final es =
          TestEntitySystem(Aspect.forAllOf([ComponentA]), expectedEntities);
      world
        ..addSystem(es)
        ..initialize()
        ..process();
      es._expectedEntities = [entityAB, entityAC];
      entityAB.enable();
      world.process();
    });
  });
}

typedef EntitySystemStarter = void Function(
    EntitySystem es, void Function() action);

class MockEntitySystem extends Mock implements EntitySystem {}

class MockEntitySystem2 extends Mock implements EntitySystem {}

class MockManager extends Mock implements Manager {}

class TestEntitySystem extends EntitySystem {
  bool isSetup = true;
  List<Entity> _expectedEntities;
  TestEntitySystem(Aspect aspect, this._expectedEntities) : super(aspect);

  @override
  void processEntities(Iterable<Entity> entities) {
    final length = _expectedEntities.length;
    expect(entities.length, length);
    for (final entity in entities) {
      expect(entity, isIn(_expectedEntities));
    }
  }

  @override
  bool checkProcessing() {
    if (isSetup) {
      isSetup = false;
      return false;
    }
    return true;
  }
}
