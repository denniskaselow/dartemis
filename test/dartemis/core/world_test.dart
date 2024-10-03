import 'package:dartemis/dartemis.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'components_setup.dart';
import 'world_test.mocks.dart';

@GenerateNiceMocks(
  [
    MockSpec<EntitySystem>(as: #MockEntitySystem2),
    MockSpec<EntitySystem>(),
    MockSpec<ComponentManager>(),
    MockSpec<Manager>(),
  ],
)
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

      // TODO(me): remove this and other ignores after https://github.com/dart-lang/sdk/issues/56819 is fixed
      // can't use @visibleForTesting annotation as it will complain about
      // calls to super in the overriding method
      // ignore: invalid_use_of_visible_for_overriding_member
      verify(system.initialize(world)).called(1);
    });
    test('systems can not be added after calling initialize', () {
      world.initialize();

      expect(() => world.addSystem(MockEntitySystem2()), throwsStateError);
    });
    test("the same system can't be added twice", () {
      world.addSystem(system);

      expect(() => world.addSystem(system), throwsArgumentError);
    });
    test('world processes added system', () {
      world
        ..addSystem(system)
        ..process();

      // ignore: invalid_use_of_visible_for_overriding_member
      verify(system.process()).called(1);
    });
    test('world processes added system', () {
      world
        ..addSystem(system)
        ..process();

      // ignore: invalid_use_of_visible_for_overriding_member
      verify(system.process()).called(1);
    });
    test('world does not process passive system', () {
      when(system.passive).thenReturn(true);

      world
        ..addSystem(system)
        ..process();

      // ignore: invalid_use_of_visible_for_overriding_member
      verifyNever(system.process());
    });
    test('world processes systems by group', () {
      final system2 = MockEntitySystem2();
      when(system2.passive).thenReturn(false);
      when(system2.group).thenReturn(1);
      when(componentManager.isUpdateNeededForSystem(system2)).thenReturn(false);

      world
        ..addSystem(system)
        ..addSystem(system2)
        ..process();
      // ignore: invalid_use_of_visible_for_overriding_member
      verify(system.process()).called(1);
      verifyNever(system2.process());

      world.process(1);
      // ignore: invalid_use_of_visible_for_overriding_member
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
        ..addSystem(system2)
        ..delta = 10.0
        ..process()
        ..delta = 20.0
        ..process(1)
        ..delta = 15.0
        ..process();

      expect(world.time(), equals(25.0));
      expect(world.time(1), equals(20.0));
      expect(world.frame(), equals(2));
      expect(world.frame(1), equals(1));
    });
    test('world initializes added managers', () {
      final manager = MockManager();

      world
        ..addManager(manager)
        ..initialize();

      verify(manager.initialize(world)).called(1);
    });
    test("the same manager can't be added twice", () {
      world.addManager(MockManager());

      expect(() => world.addManager(MockManager()), throwsArgumentError);
    });
    test('managers can not be added after calling initialize', () {
      world.initialize();

      expect(() => world.addManager(TagManager()), throwsStateError);
    });
    test('world deletes all entites', () {
      world
        ..initialize()
        ..createEntity()
        ..createEntity()
        ..process();

      expect(world.entityManager.activeEntityCount, equals(2));
      world
        ..deleteAllEntities()
        ..process();
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

      // ignore: invalid_use_of_visible_for_overriding_member
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
    late Entity entityAB;
    late Entity entityAC;
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
EntitySystem which requires one Component processes entity with this component''',
        () {
      final expectedEntities = [entityAB, entityAC];
      final es =
          TestEntitySystem(Aspect(allOf: [Component0]), expectedEntities);
      systemStarter(es, () {});
    });
    test('''
EntitySystem which required multiple Components does not process entity with a subset of those components''',
        () {
      final expectedEntities = [entityAB];
      final es = TestEntitySystem(
        Aspect(allOf: [Component0, Component1]),
        expectedEntities,
      );
      systemStarter(es, () {});
    });
    test('''
EntitySystem which requires one of multiple components processes entity with a subset of those components''',
        () {
      final expectedEntities = [entityAB, entityAC];
      final es = TestEntitySystem(
        Aspect(oneOf: [Component0, Component1]),
        expectedEntities,
      );
      systemStarter(es, () {});
    });
    test('''
EntitySystem which excludes a component does not process entity with one of those components''',
        () {
      final expectedEntities = [entityAB];
      final es = TestEntitySystem(
        Aspect(allOf: [Component0])..exclude([PooledComponent2]),
        expectedEntities,
      );
      systemStarter(es, () {});
    });
    test('A removed entity will not get processed', () {
      final expectedEntities = [entityAC];
      final es =
          TestEntitySystem(Aspect(allOf: [Component0]), expectedEntities);
      systemStarter(es, () => es.deleteFromWorld(entityAB));
    });
    test(
        'A removed entity can still be interacted with as long as the system is'
        ' not finished', () {
      final es = TestEntitySystemWithInteractingDeletedEntities();
      world
        ..createEntity([Component0()])
        ..createEntity([Component0()]);
      systemStarter(es, () => {});
    });
    test("An entity that's been deleted twice, can only be reused once", () {
      world
        ..deleteEntity(entityAB)
        ..deleteEntity(entityAB);
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
        Aspect(allOf: [PooledComponent2]),
        expectedEntities,
      );
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
    test(
        'world can handle entites with an id higher than 32 when spawned later',
        () {
      final es = TestEntitySystemForComponent3();
      world
        ..addSystem(es)
        ..initialize()
        ..process();

      for (var i = 0; i <= 32; i++) {
        world.createEntity([Component3()]);
      }

      world.process();
    });
  });
  group('isUpdateNeededForSystem', () {
    late World world;
    late Entity entityA;
    late Entity entityB;
    late Entity entityC;
    late TestEntitySystem es;
    setUp(() {
      world = World();
      entityA = world.createEntity([Component0(), Component32()]);
      entityB = world.createEntity([Component32()]);
      entityC = world.createEntity([Component0()]);
      final expectedEntities = [entityA];
      es = TestEntitySystem(Aspect(allOf: [Component0]), expectedEntities);

      world
        ..addSystem(es)
        ..initialize()
        ..process();
    });
    test('systems should not require update when no change happened', () {
      expect(world.componentManager.isUpdateNeededForSystem(es), isFalse);
    });
    test('systems should require update when new entity is added', () {
      world.createEntity([Component0()]);

      expect(world.componentManager.isUpdateNeededForSystem(es), isTrue);
    });
    test('systems should require update when entity is removed', () {
      world
        ..deleteEntity(entityA)
        // workaround to trigger actual deletion of entities by processing a non
        // existent system group
        ..process(-1);

      expect(world.componentManager.isUpdateNeededForSystem(es), isTrue);
    });
    test(
        'systems should require update when component required by system is '
        'removed', () {
      world.removeComponent<Component0>(entityA);

      expect(world.componentManager.isUpdateNeededForSystem(es), isTrue);
    });
    test(
        'systems should require update when component required by system is '
        'moved', () {
      world.moveComponent<Component0>(entityA, entityC);

      expect(world.componentManager.isUpdateNeededForSystem(es), isTrue);
    });
    test(
        'systems should require update when component required by system is '
        'moved to a entity  that did not have the component before', () {
      world.moveComponent<Component0>(entityA, entityB);

      expect(world.componentManager.isUpdateNeededForSystem(es), isTrue);
    });
    test(
        'systems should not require update when component required by system '
        'is moved', () {
      world.moveComponent<Component32>(entityA, entityB);

      expect(world.componentManager.isUpdateNeededForSystem(es), isFalse);
    });
    test(
        'systems should require update when component required by system is '
        'added', () {
      world.addComponent(entityB, Component0());

      expect(world.componentManager.isUpdateNeededForSystem(es), isTrue);
    });
    test(
        'systems should not require update when unrelated component is '
        'added', () {
      world
        ..addComponent(entityA, Component32())
        ..addComponent(entityB, Component32());

      expect(world.componentManager.isUpdateNeededForSystem(es), isFalse);
    });
    test(
        'systems should not require update when unrelated component is '
        'removed', () {
      world
        ..removeComponent<Component32>(entityA)
        ..removeComponent<Component32>(entityB);

      expect(world.componentManager.isUpdateNeededForSystem(es), isFalse);
    });
  });
}

typedef EntitySystemStarter = void Function(
  EntitySystem es,
  void Function() action,
);

class TestEntitySystem extends EntitySystem {
  bool isSetup = true;
  List<Entity> _expectedEntities;
  TestEntitySystem(super.aspect, this._expectedEntities);

  @override
  void processEntities(Iterable<Entity> entities) {
    final length = _expectedEntities.length;
    expect(
      entities.length,
      length,
      reason:
          '''expected $length entities, got ${entities.length} entities: [${entities.join(', ')}]''',
    );
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
      : super(
          Aspect(
            allOf: [
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
            ],
          ),
        );

  @override
  void processEntities(Iterable<Entity> entities) {}

  @override
  bool checkProcessing() => true;
}

class TestEntitySystemForComponent3 extends EntityProcessingSystem {
  late Mapper<Component3> mapper;

  TestEntitySystemForComponent3() : super(Aspect(allOf: [Component3]));

  @override
  void initialize(World world) {
    super.initialize(world);
    mapper = Mapper<Component3>(world);
  }

  @override
  void processEntity(Entity entity) {
    final component = mapper.getSafe(entity);

    expect(
      component,
      isNotNull,
      reason: 'component for entity $entity is null',
    );
  }
}

class TestEntitySystemWithInteractingDeletedEntities extends EntitySystem {
  late final Mapper<Component0> mapper0;
  TestEntitySystemWithInteractingDeletedEntities()
      : super(Aspect(allOf: [Component0]));

  @override
  void initialize(World world) {
    super.initialize(world);
    mapper0 = Mapper<Component0>(world);
  }

  @override
  bool checkProcessing() => true;

  @override
  void processEntities(Iterable<Entity> entities) {
    // some interaction that causes one entity to be deleted
    world.deleteEntity(entities.last);

    for (final entity in entities) {
      expect(mapper0[entity], isA<Component0>());
    }
  }
}
