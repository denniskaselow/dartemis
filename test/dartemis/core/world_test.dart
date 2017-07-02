library world_test;

import "package:mockito/mockito.dart";
import "package:test/test.dart";

import "package:dartemis/dartemis.dart";
import "components_setup.dart";

void main() {
  group('World tests', () {
    World world;
    MockEntitySystem system;
    setUp(() {
      world = new World();
      system = new MockEntitySystem();
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
      MockEntitySystem2 system2 = new MockEntitySystem2();
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
      MockEntitySystem2 system2 = new MockEntitySystem2();
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
      MockManager manager = new MockManager();
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
      MockManager manager = new MockManager();
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
      world = new World();
      entityAB = world.createAndAddEntity([new ComponentA(), new ComponentB()]);
      entityAC = world.createEntity()
        ..addComponent(new ComponentA())
        ..addComponent(new PooledComponentC())
        ..addToWorld();
      systemStarter = (EntitySystem es) {
        es = world.addSystem(es);
        world
          ..initialize()
          ..process();
      };
    });
    test(
        'EntitySystem which requires one Component processes Entity with this component',
        () {
      List<Entity> expectedEntities = [entityAB, entityAC];
      EntitySystem es = new TestEntitySystem(
          Aspect.getAspectForAllOf([COMPONENT_A]), expectedEntities);
      systemStarter(es);
    });
    test(
        'EntitySystem which required multiple Components does not process Entity with a subset of those components',
        () {
      List<Entity> expectedEntities = [entityAB];
      EntitySystem es = new TestEntitySystem(
          Aspect.getAspectForAllOf([COMPONENT_A, COMPONENT_B]),
          expectedEntities);
      systemStarter(es);
    });
    test(
        'EntitySystem which requires one of multiple components processes Entity with a subset of those components',
        () {
      List<Entity> expectedEntities = [entityAB, entityAC];
      EntitySystem es = new TestEntitySystem(
          Aspect.getAspectForOneOf([COMPONENT_A, COMPONENT_B]),
          expectedEntities);
      systemStarter(es);
    });
    test(
        'EntitySystem which excludes a component does not process Entity with one of those components',
        () {
      List<Entity> expectedEntities = [entityAB];
      EntitySystem es = new TestEntitySystem(
          Aspect.getAspectForAllOf([COMPONENT_A]).exclude([COMPONENT_C]),
          expectedEntities);
      systemStarter(es);
    });
    test('A removed entity will not get processed', () {
      entityAB.deleteFromWorld();
      List<Entity> expectedEntities = [entityAC];
      EntitySystem es = new TestEntitySystem(
          Aspect.getAspectForAllOf([COMPONENT_A]), expectedEntities);
      systemStarter(es);
    });
    test('A disabled entity will not get processed', () {
      entityAB.disable();
      List<Entity> expectedEntities = [entityAC];
      EntitySystem es = new TestEntitySystem(
          Aspect.getAspectForAllOf([COMPONENT_A]), expectedEntities);
      systemStarter(es);
    });
    test(
        'Adding a component will not get the entity processed if the world is not notified of the change',
        () {
      List<Entity> expectedEntities = [entityAC];
      EntitySystem es = new TestEntitySystem(
          Aspect.getAspectForAllOf([COMPONENT_C]), expectedEntities);
      es = world.addSystem(es);
      world
        ..initialize()
        ..process();
      entityAB.addComponent(new PooledComponentC());
      world.process();
    });
    test(
        'Adding a component will get the entity processed if the world is notified of the change',
        () {
      List<Entity> expectedEntities = [entityAC];
      TestEntitySystem es = new TestEntitySystem(
          Aspect.getAspectForAllOf([COMPONENT_C]), expectedEntities);
      es = world.addSystem(es);
      world
        ..initialize()
        ..process();
      es.expectedEntities = [entityAB, entityAC];
      entityAB
        ..addComponent(new PooledComponentC())
        ..changedInWorld();
      world.process();
    });
    test('Enabling a disabled component will get the entity processed', () {
      entityAB.disable();
      List<Entity> expectedEntities = [entityAC];
      TestEntitySystem es = new TestEntitySystem(
          Aspect.getAspectForAllOf([COMPONENT_A]), expectedEntities);
      es = world.addSystem(es);
      world
        ..initialize()
        ..process();
      es.expectedEntities = [entityAB, entityAC];
      entityAB.enable();
      world.process();
    });
  });
}

typedef void EntitySystemStarter(EntitySystem es);

class MockEntitySystem extends Mock implements EntitySystem {}

class MockEntitySystem2 extends Mock implements EntitySystem {}

class MockManager extends Mock implements Manager {}

class TestEntitySystem extends EntitySystem {
  var expectedEntities;
  TestEntitySystem(Aspect aspect, this.expectedEntities) : super(aspect) {}

  void processEntities(Iterable<Entity> entities) {
    int length = expectedEntities.length;
    expect(entities.length, length);
    entities.forEach((entity) => expect(entity, isIn(expectedEntities)));
  }

  bool checkProcessing() => true;
}
