library world_test;

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:dartemis/dartemis.dart';
import 'components_setup.dart';
import 'world_test.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<EntitySystem>(as: #MockEntitySystem2, returnNullOnMissingStub: true),
  MockSpec<EntitySystem>(returnNullOnMissingStub: true),
  MockSpec<ComponentManager>(returnNullOnMissingStub: true),
  MockSpec<Manager>(returnNullOnMissingStub: true),
])
void main() {
  group('World tests', () {
    late World world;
    late EntitySystem system;
    late ComponentManager componentManager;
    setUp(() {
      componentManager = MockComponentManager();
      system = MockEntitySystem();

      when(system.passive).thenReturn(false);
      when(system.group).thenReturn(0);
      when(componentManager.isUpdateNeededForSystem(system)).thenReturn(false);

      world = World(componentManager: componentManager);
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
      when(componentManager.isUpdateNeededForSystem(system2)).thenReturn(false);

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
      when(componentManager.isUpdateNeededForSystem(system2)).thenReturn(false);

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
      world
        ..initialize()
        ..createEntity()
        ..createEntity()
        ..process();

      expect(world.entityManager.activeEntityCount, equals(2));
      world.deleteAllEntities();
      expect(world.entityManager.activeEntityCount, equals(0));
    });
    test('world delete all entites should not fail if called twice', () {
      world
        ..initialize()
        ..createEntity()
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
    late World world;
    late int entityAB;
    late int entityAC;
    late EntitySystemStarter systemStarter;
    setUp(() {
      world = World();
      entityAB = world.createEntity([Component0(), Component1()]);
      entityAC = world.createEntity();
      world
        ..addComponent(entityAC, Component0())
        ..addComponent(entityAC, PooledComponent2());
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
EntitySystem which requires one Component processes int with this component''',
        () {
      final expectedEntities = [entityAB, entityAC];
      final es =
          TestEntitySystem(Aspect.forAllOf([Component0]), expectedEntities);
      systemStarter(es, () {});
    });
    test('''
EntitySystem which required multiple Components does not process int with a subset of those components''',
        () {
      final expectedEntities = [entityAB];
      final es = TestEntitySystem(
          Aspect.forAllOf([Component0, Component1]), expectedEntities);
      systemStarter(es, () {});
    });
    test('''
EntitySystem which requires one of multiple components processes int with a subset of those components''',
        () {
      final expectedEntities = [entityAB, entityAC];
      final es = TestEntitySystem(
          Aspect.forOneOf([Component0, Component1]), expectedEntities);
      systemStarter(es, () {});
    });
    test('''
EntitySystem which excludes a component does not process int with one of those components''',
        () {
      final expectedEntities = [entityAB];
      final es = TestEntitySystem(
          Aspect.forAllOf([Component0])..exclude([PooledComponent2]),
          expectedEntities);
      systemStarter(es, () {});
    });
    test('A removed entity will not get processed', () {
      final expectedEntities = [entityAC];
      final es =
          TestEntitySystem(Aspect.forAllOf([Component0]), expectedEntities);
      systemStarter(es, () => es.deleteFromWorld(entityAB));
    });
    test('An entity that\'s been deleted twice, can only be reused once', () {
      world..deleteEntity(entityAB)..deleteEntity(entityAB);
      final component0 = Component0();
      final component1 = Component1();

      world.process();
      final entityA = world.createEntity([component0]);
      final entityB = world.createEntity([component1]);
      world.process();

      expect(world.getComponents(entityA)[0], equals(component0));
      expect(world.getComponents(entityB)[0], equals(component1));
      expect(world.getComponents(entityA).length, equals(1));
      expect(world.getComponents(entityB).length, equals(1));
    });
    test('''
Adding a component will get the entity processed''', () {
      final expectedEntities = [entityAC];
      final es = TestEntitySystem(
          Aspect.forAllOf([PooledComponent2]), expectedEntities);
      world
        ..addSystem(es)
        ..initialize()
        ..process();
      es._expectedEntities = [entityAB, entityAC];
      world
        ..addComponent(entityAB, PooledComponent2())
        ..process();
    });
    test('world can handle more than 32 components referenced by systems', () {
      world.addSystem(TestEntitySystemWithMoreThan32Components());
    });
  });
}

typedef EntitySystemStarter = void Function(
    EntitySystem es, void Function() action);

class TestEntitySystem extends EntitySystem {
  bool isSetup = true;
  List<int> _expectedEntities;
  TestEntitySystem(Aspect aspect, this._expectedEntities) : super(aspect);

  @override
  void processEntities(Iterable<int> entities) {
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

class TestEntitySystemWithMoreThan32Components extends EntitySystem {
  TestEntitySystemWithMoreThan32Components()
      : super(Aspect.forAllOf([
          Component0,
          Component1,
          PooledComponent2,
          Component3,
          Component4,
          Component5,
          Component6,
          Component7,
          Component8,
          Component9,
          Component10,
          Component11,
          Component12,
          Component13,
          Component14,
          Component15,
          Component16,
          Component17,
          Component18,
          Component19,
          Component20,
          Component21,
          Component22,
          Component23,
          Component24,
          Component25,
          Component26,
          Component27,
          Component28,
          Component29,
          Component30,
          Component31,
          Component32,
        ]));

  @override
  void processEntities(Iterable<int> entities) {}

  @override
  bool checkProcessing() => true;
}
