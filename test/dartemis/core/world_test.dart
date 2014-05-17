library world_test;

import "package:mock/mock.dart";
import "package:unittest/unittest.dart";

import "package:dartemis/dartemis.dart";
import "components_setup.dart";

void main() {
  group('World tests', () {
    World world;
    setUp(() {
      world = new World();
    });
    test('world initializes added system', () {
      MockEntitySystem system = new MockEntitySystem();
      world.addSystem(system);
      world.initialize();

      system.getLogs(callsTo('initialize')).verify(happenedExactly(1));
    });
    test('world processes added system', () {
      MockEntitySystem system = new MockEntitySystem();
      system.when(callsTo('get passive')).alwaysReturn(false);

      world.addSystem(system);
      world.process();

      system.getLogs(callsTo('process')).verify(happenedExactly(1));
    });
    test('world does not process passive system', () {
      MockEntitySystem system = new MockEntitySystem();
      system.when(callsTo('get passive')).alwaysReturn(true);

      world.addSystem(system, passive : true);
      world.process();

      system.getLogs(callsTo('process')).verify(neverHappened);
    });
    test('world initializes added managers', () {
      MockManager manager = new MockManager();
      world.addManager(manager);
      world.initialize();

      manager.getLogs(callsTo('initialize')).verify(happenedExactly(1));
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
      world.process();

      world.deleteAllEntities();
      world.deleteAllEntities();
    });
    test('world process increments frame count', () {
      world.initialize();

      world.process();
      expect(world.frame, equals(1));
      world.process();
      expect(world.frame, equals(2));
    });
    test('world process increments time by delta', () {
      world.initialize();

      world.delta = 10;
      world.process();
      expect(world.time, equals(10));
      world.delta = 20;
      world.process();
      expect(world.time, equals(30));
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
      entityAC = world.createEntity();
      entityAC.addComponent(new ComponentA());
      entityAC.addComponent(new ComponentPoolableC());
      entityAC.addToWorld();
      systemStarter = (EntitySystem es) {
        es = world.addSystem(es);
        world.initialize();
        world.process();
      };
    });
    test('EntitySystem which requires one Component processes Entity with this component', () {
      List<Entity> expectedEntities = [entityAB, entityAC];
      EntitySystem es = new TestEntitySystem(Aspect.getAspectForAllOf([COMPONENT_A]), expectedEntities);
      systemStarter(es);
    });
    test('EntitySystem which required multiple Components does not process Entity with a subset of those components', () {
      List<Entity> expectedEntities = [entityAB];
      EntitySystem es = new TestEntitySystem(Aspect.getAspectForAllOf([COMPONENT_A, COMPONENT_B]), expectedEntities);
      systemStarter(es);
    });
    test('EntitySystem which requires one of multiple components processes Entity with a subset of those components', () {
      List<Entity> expectedEntities = [entityAB, entityAC];
      EntitySystem es = new TestEntitySystem(Aspect.getAspectForOneOf([COMPONENT_A, COMPONENT_B]), expectedEntities);
      systemStarter(es);
    });
    test('EntitySystem which excludes a component does not process Entity with one of those components', () {
      List<Entity> expectedEntities = [entityAB];
      EntitySystem es = new TestEntitySystem(Aspect.getAspectForAllOf([COMPONENT_A]).exclude([COMPONENT_C]), expectedEntities);
      systemStarter(es);
    });
    test('A removed entity will not get processed', () {
      entityAB.deleteFromWorld();
      List<Entity> expectedEntities = [entityAC];
      EntitySystem es = new TestEntitySystem(Aspect.getAspectForAllOf([COMPONENT_A]), expectedEntities);
      systemStarter(es);
    });
    test('A disabled entity will not get processed', () {
      entityAB.disable();
      List<Entity> expectedEntities = [entityAC];
      EntitySystem es = new TestEntitySystem(Aspect.getAspectForAllOf([COMPONENT_A]), expectedEntities);
      systemStarter(es);
    });
    test('Adding a component will not get the entity processed if the world is not notified of the change', () {
      List<Entity> expectedEntities = [entityAC];
      EntitySystem es = new TestEntitySystem(Aspect.getAspectForAllOf([COMPONENT_C]), expectedEntities);
      es = world.addSystem(es);
      world.initialize();
      world.process();
      entityAB.addComponent(new ComponentPoolableC());
      world.process();
    });
    test('Adding a component will get the entity processed if the world is notified of the change', () {
      List<Entity> expectedEntities = [entityAC];
      TestEntitySystem es = new TestEntitySystem(Aspect.getAspectForAllOf([COMPONENT_C]), expectedEntities);
      es = world.addSystem(es);
      world.initialize();
      world.process();
      es.expectedEntities = [entityAB, entityAC];
      entityAB.addComponent(new ComponentPoolableC());
      entityAB.changedInWorld();
      world.process();
    });
    test('Enabling a disabled component will get the entity processed', () {
      entityAB.disable();
      List<Entity> expectedEntities = [entityAC];
      TestEntitySystem es = new TestEntitySystem(Aspect.getAspectForAllOf([COMPONENT_A]), expectedEntities);
      es = world.addSystem(es);
      world.initialize();
      world.process();
      es.expectedEntities = [entityAB, entityAC];
      entityAB.enable();
      world.process();
    });
  });
}


typedef void EntitySystemStarter(EntitySystem es);

class MockEntitySystem extends Mock implements EntitySystem {}
class MockManager extends Mock implements Manager {}

class TestEntitySystem extends EntitySystem {
  var expectedEntities;
  TestEntitySystem(Aspect aspect, this.expectedEntities):super(aspect) {}

  void processEntities(Iterable<Entity> entities) {
    int length = expectedEntities.length;
    expect(entities.length, length);
    entities.forEach((entity) => expect(entity, isIn(expectedEntities)));
  }

  bool checkProcessing() => true;
}