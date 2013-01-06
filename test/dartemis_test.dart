import "package:dartemis/dartemis.dart";
import "package:unittest/mock.dart";
import "package:unittest/unittest.dart";
import "dart:math" as Math;

final Type COMPONENT_A = new ComponentA().runtimeType;
final Type COMPONENT_B = new ComponentB().runtimeType;
final Type COMPONENT_C = new ComponentC().runtimeType;

const int COMPONENT_A_BIT = 0x0001;
const int COMPONENT_B_BIT = 0x0002;
const int COMPONENT_C_BIT = 0x0004;
const int DEFAULT_BAG_SIZE = 16;

main() {
  test('ComponentType Test', () {
    expect(ComponentTypeManager.getBit(COMPONENT_A), COMPONENT_A_BIT);
    expect(ComponentTypeManager.getBit(COMPONENT_B), COMPONENT_B_BIT);
    expect(ComponentTypeManager.getBit(COMPONENT_C), COMPONENT_C_BIT);
  });
  group('Aspect Tests', () {
    test('getAspectForAll with one component', () {
      Aspect aspect = Aspect.getAspectForAllOf([COMPONENT_C]);
      expect(aspect.all, COMPONENT_C_BIT);
      expect(aspect.excluded, 0);
      expect(aspect.one, 0);
    });
    test('getAspectForAll with all components', () {
      Aspect aspect = Aspect.getAspectForAllOf([COMPONENT_A, COMPONENT_B, COMPONENT_C]);
      expect(aspect.all, COMPONENT_A_BIT | COMPONENT_B_BIT | COMPONENT_C_BIT);
      expect(aspect.excluded, 0);
      expect(aspect.one, 0);
    });
    test('getAspectForAll with one component, excluding another one', () {
      Aspect aspect = Aspect.getAspectForAllOf([COMPONENT_C]).exclude([COMPONENT_A]);
      expect(aspect.all, COMPONENT_C_BIT);
      expect(aspect.excluded, COMPONENT_A_BIT);
      expect(aspect.one, 0);
    });
    test('getAspectForAll with one component, excluding another two', () {
      Aspect aspect = Aspect.getAspectForAllOf([COMPONENT_C]).exclude([COMPONENT_A, COMPONENT_B]);
      expect(aspect.all, COMPONENT_C_BIT);
      expect(aspect.excluded, COMPONENT_A_BIT | COMPONENT_B_BIT);
      expect(aspect.one, 0);
    });
    test('getAspectForAll with one component, and one of two', () {
      Aspect aspect = Aspect.getAspectForAllOf([COMPONENT_C]).oneOf([COMPONENT_A, COMPONENT_B]);
      expect(aspect.all, COMPONENT_C_BIT);
      expect(aspect.excluded, 0);
      expect(aspect.one, COMPONENT_A_BIT | COMPONENT_B_BIT);
    });
    test('getAspectForOne with all components', () {
      Aspect aspect = Aspect.getAspectForOneOf([COMPONENT_A, COMPONENT_B, COMPONENT_C]);
      expect(aspect.all, 0);
      expect(aspect.excluded, 0);
      expect(aspect.one, COMPONENT_A_BIT | COMPONENT_B_BIT | COMPONENT_C_BIT);
    });
    test('getAspectForOne with chaining each component', () {
      Aspect aspect = Aspect.getAspectForOneOf([COMPONENT_A]).oneOf([COMPONENT_B]).oneOf([COMPONENT_C]);
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

  group('integration tests for World.process()', () {
    World world;
    Entity entityAB;
    Entity entityAC;
    EntitySystemStarter systemStarter;
    setUp(() {
      world = new World();
      entityAB = world.createEntity();
      entityAB.addComponent(new ComponentA());
      entityAB.addComponent(new ComponentB());
      entityAB.addToWorld();
      entityAC = world.createEntity();
      entityAC.addComponent(new ComponentA());
      entityAC.addComponent(new ComponentC());
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
      entityAB.addComponent(new ComponentC());
      world.process();
    });
    test('Adding a component will get the entity processed if the world is notified of the change', () {
      List<Entity> expectedEntities = [entityAC];
      TestEntitySystem es = new TestEntitySystem(Aspect.getAspectForAllOf([COMPONENT_C]), expectedEntities);
      es = world.addSystem(es);
      world.initialize();
      world.process();
      es.expectedEntities = [entityAB, entityAC];
      entityAB.addComponent(new ComponentC());
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
  group('integration tests for EntityManager', () {
    World world;
    setUp(() {
      world = new World();
    });
    test('entities have uniqure IDs', () {
      Entity a = world.createEntity();
      Entity b = world.createEntity();

      expect(a.id, isNot(equals(b.id)));
    });
  });
  group('integration tests for ComponentManager', () {
    World world;
    setUp(() {
      world = new World();
    });
    test('ComponentManager correctly associates entity and components', () {
      Entity entity = world.createEntity();
      Component componentA = new ComponentA();
      Component componentC = new ComponentC();
      entity.addComponent(componentA);
      entity.addComponent(componentC);

      Bag<Component> fillBag = entity.getComponents();

      expect(fillBag[0], equals(componentA));
      expect(fillBag[1], equals(componentC));
      expect(fillBag.size, equals(2));
    });
    test('ComponentManager correctly associates multiple entity and components', () {
      Entity entity1 = world.createEntity();
      Component component1A = new ComponentA();
      Component component1C = new ComponentC();
      entity1.addComponent(component1A);
      entity1.addComponent(component1C);

      Entity entity2 = world.createEntity();
      Component component2A = new ComponentA();
      Component component2B = new ComponentB();
      Component component2C = new ComponentC();
      entity2.addComponent(component2A);
      entity2.addComponent(component2B);
      entity2.addComponent(component2C);

      Bag<Component> fillBag1 = entity1.getComponents();
      Bag<Component> fillBag2 = entity2.getComponents();

      expect(fillBag1[0], equals(component1A));
      expect(fillBag1[1], equals(component1C));
      expect(fillBag1.size, equals(2));

      expect(fillBag2[0], equals(component2A));
      expect(fillBag2[1], equals(component2B));
      expect(fillBag2[2], equals(component2C));
      expect(fillBag2.size, equals(3));
    });
    test('ComponentManager removes Components of deleted Entity', () {
      Entity entity = world.createEntity();
      Component componentA = new ComponentA();
      Component componentC = new ComponentC();
      entity.addComponent(componentA);
      entity.addComponent(componentC);
      world.addEntity(entity);
      world.initialize();
      world.process();
      world.deleteEntity(entity);
      world.process();

      Bag<Component> fillBag = entity.getComponents();
      expect(fillBag.size, equals(0));
    });
    test('ComponentManager can be created for unused Component', () {
      ComponentType type = new ComponentType();
      for (int i = 0; i < DEFAULT_BAG_SIZE; i++) {
        type = new ComponentType();
      }
      Bag<Component> componentsByType = world.componentManager.getComponentsByType(type);
      expect(componentsByType.size, equals(0));
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
  });
  group('FastMath tests', () {
    compareFunctions(double mathFunc(num arg), double fastMathFunc(num arg1)) {
      double diff;
      for (double angle = -4 * Math.PI; angle < 4.01 * Math.PI; angle += Math.PI / 4) {
        diff = mathFunc(angle) - fastMathFunc(angle);
        expect(diff.abs(), lessThan(0.0025), reason: "for angle: $angle");
      }
    }
    compareArcFunctions(double mathFunc(num arg), double fastMathFunc(num arg1)) {
      double diff;
      for (double value = -1.0; value <= 1.0; value += 0.25) {
        diff = mathFunc(value) - fastMathFunc(value);
        expect(diff.abs(), lessThan(0.0025), reason: "for value: $value");
      }
    }
    test('FastMath.sin is close to Math.sin', () {
      compareFunctions(Math.sin, FastMath.sin);
    });
    test('FastMath.cos is close to Math.cos', () {
      compareFunctions(Math.cos, FastMath.cos);
    });
    test('FastMath.asin is close to Math.asin', () {
      compareArcFunctions(Math.asin, FastMath.asin);
    });
    test('FastMath.acos is close to Math.acos', () {
      compareArcFunctions(Math.acos, FastMath.acos);
    });
  });
}

typedef void EntitySystemStarter(EntitySystem es);

class ComponentA extends Component {}
class ComponentB extends Component {}
class ComponentC extends Component {}
class ComponentD extends Component {}
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

