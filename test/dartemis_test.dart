import "package:unittest/unittest.dart";
import "package:dartemis/dartemis.dart";

final String COMPONENT_A = "ComponentA";
final String COMPONENT_B = "ComponentB";
final String COMPONENT_C = "ComponentC";

final int COMPONENT_A_BIT = 0x0001;
final int COMPONENT_B_BIT = 0x0002;
final int COMPONENT_C_BIT = 0x0004;

main() {
  test('ComponentType Test', () {
    expect(ComponentTypeManager.getBit(COMPONENT_A), COMPONENT_A_BIT);
    expect(ComponentTypeManager.getBit(COMPONENT_B), COMPONENT_B_BIT);
    expect(ComponentTypeManager.getBit(COMPONENT_C), COMPONENT_C_BIT);
  });
  group('Aspect Tests', () {
    test('getAspectForAll with one component', () {
      Aspect aspect = Aspect.getAspectForAllOf(COMPONENT_C);
      expect(aspect.all, COMPONENT_C_BIT);
      expect(aspect.excluded, 0);
      expect(aspect.one, 0);
    });
    test('getAspectForAll with all components', () {
      Aspect aspect = Aspect.getAspectForAllOf(COMPONENT_A, [COMPONENT_B, COMPONENT_C]);
      expect(aspect.all, COMPONENT_A_BIT | COMPONENT_B_BIT | COMPONENT_C_BIT);
      expect(aspect.excluded, 0);
      expect(aspect.one, 0);
    });
    test('getAspectForAll with one component, excluding another one', () {
      Aspect aspect = Aspect.getAspectForAllOf(COMPONENT_C).exclude(COMPONENT_A);
      expect(aspect.all, COMPONENT_C_BIT);
      expect(aspect.excluded, COMPONENT_A_BIT);
      expect(aspect.one, 0);
    });
    test('getAspectForAll with one component, excluding another two', () {
      Aspect aspect = Aspect.getAspectForAllOf(COMPONENT_C).exclude(COMPONENT_A, [COMPONENT_B]);
      expect(aspect.all, COMPONENT_C_BIT);
      expect(aspect.excluded, COMPONENT_A_BIT | COMPONENT_B_BIT);
      expect(aspect.one, 0);
    });
    test('getAspectForAll with one component, and one of two', () {
      Aspect aspect = Aspect.getAspectForAllOf(COMPONENT_C).oneOf(COMPONENT_A, [COMPONENT_B]);
      expect(aspect.all, COMPONENT_C_BIT);
      expect(aspect.excluded, 0);
      expect(aspect.one, COMPONENT_A_BIT | COMPONENT_B_BIT);
    });
    test('getAspectForOne with all components', () {
      Aspect aspect = Aspect.getAspectForOneOf(COMPONENT_A, [COMPONENT_B, COMPONENT_C]);
      expect(aspect.all, 0);
      expect(aspect.excluded, 0);
      expect(aspect.one, COMPONENT_A_BIT | COMPONENT_B_BIT | COMPONENT_C_BIT);
    });
    test('getAspectForOne with chaining each component', () {
      Aspect aspect = Aspect.getAspectForOneOf(COMPONENT_A).oneOf(COMPONENT_B).oneOf(COMPONENT_C);
      expect(aspect.all, 0);
      expect(aspect.excluded, 0);
      expect(aspect.one, COMPONENT_A_BIT | COMPONENT_B_BIT | COMPONENT_C_BIT);
    });
    test('getEmpty()', () {
      Aspect aspect = Aspect.getEmpty();
      expect(aspect.all, 0);
      expect(aspect.excluded, 0);
      expect(aspect.one, 0);
    });
  });

  group('integration tests for EntitySystems', () {
    World world;
    Entity entityAB;
    Entity entityAC;
    EntitySystemStarter systemStarter;
    setUp(() {
      world = new World();
      entityAB = world.createEntity();
      entityAB.addComponent(new ComponentA());
      entityAB.addComponent(new ComponentB());
      entityAB.refresh();
      entityAC = world.createEntity();
      entityAC.addComponent(new ComponentA());
      entityAC.addComponent(new ComponentC());
      entityAC.refresh();
      systemStarter = (EntitySystem es) {
        es = world.addSystem(es);
        world.initialize();
        world.loopStart();
        world.process();
      };
    });
    test('EntitySystem which requires one Component processes Entity with this component', () {
      List<Entity> expectedEntities = [entityAB, entityAC];
      EntitySystem es = new TestEntitySystem(Aspect.getAspectForAllOf(COMPONENT_A), expectedEntities);
      systemStarter(es);
    });
    test('EntitySystem which required multiple Components does not process Entity with a subset of those components', () {
      List<Entity> expectedEntities = [entityAB];
      EntitySystem es = new TestEntitySystem(Aspect.getAspectForAllOf(COMPONENT_A, [COMPONENT_B]), expectedEntities);
      systemStarter(es);
    });
    test('EntitySystem which requires one of multiple components processes Entity with a subset of those components', () {
      List<Entity> expectedEntities = [entityAB, entityAC];
      EntitySystem es = new TestEntitySystem(Aspect.getAspectForOneOf(COMPONENT_A, [COMPONENT_B]), expectedEntities);
      systemStarter(es);
    });
    test('EntitySystem which excludes a component does not process Entity with one of those components', () {
      List<Entity> expectedEntities = [entityAB];
      EntitySystem es = new TestEntitySystem(Aspect.getAspectForAllOf(COMPONENT_A).exclude(COMPONENT_C), expectedEntities);
      systemStarter(es);
    });
  });
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
      world.addSystem(system);
      world.process();

      system.getLogs(callsTo('process')).verify(happenedExactly(1));
    });
    test('world does not process passive system', () {
      MockEntitySystem system = new MockEntitySystem();
      world.addSystem(system, true);
      world.process();

      system.getLogs(callsTo('process')).verify(happenedExactly(1));
    });
    test('world initializes added managers', () {
      MockManager manager = new MockManager();
      world.addManager(manager);
      world.initialize();

      manager.getLogs(callsTo('initialize')).verify(happenedExactly(1));
    });
    test('world processes added managers', () {
      MockManager manager = new MockManager();
      world.addManager(manager);
      world.process();

      manager.getLogs(callsTo('process')).verify(happenedExactly(1));
    });
  });
}

typedef void EntitySystemStarter(EntitySystem es);

class ComponentA extends Component {}
class ComponentB extends Component {}
class ComponentC extends Component {}
class MockEntitySystem extends Mock implements EntitySystem {}
class MockManager extends Mock implements Manager {}

class TestEntitySystem extends EntitySystem {
  var expectedEntities;
  TestEntitySystem(Aspect aspect, this.expectedEntities):super(aspect) {}

  void processEntities(ImmutableBag<Entity> entities) {
    int length = expectedEntities.length;
    expect(entities.size, length);
    for (int i = 0; i < length; i++) {
      expect(entities[i], isIn(expectedEntities));
    }
  }

  bool checkProcessing() => true;


}

