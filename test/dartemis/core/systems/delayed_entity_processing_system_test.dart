library delayedEntityProcessingSystem;

import "package:unittest/unittest.dart";

import "package:dartemis/dartemis.dart";

void main() {
  group('DelayedEntityProcessingSystem tests', () {
    test('executes after delay has passed', () {
      World world = new World();
      var t1 = new Timer(100.0);
      var t2 = new Timer(150.0);
      world.createAndAddEntity([t1]);
      world.createAndAddEntity([t2]);
      var sut = new TestDelayedEntityProcessingSystem();
      world.addSystem(sut);
      world.delta = 50.0;
      world.initialize();

      world.process();
      expect(sut.getInitialTimeDelay(), equals(100.0));
      expect(sut.getRemainingTimeUntilProcessing(), equals(50.0));
      expect(world.entityManager.totalDeleted, equals(0));
      expect(t1.time, equals(100.0));
      expect(t2.time, equals(150.0));

      world.process();
      expect(sut.getInitialTimeDelay(), equals(50.0));
      expect(sut.getRemainingTimeUntilProcessing(), equals(50.0));
      expect(world.entityManager.totalDeleted, equals(0));
      expect(t1.time, equals(0.0));
      expect(t2.time, equals(50.0));

      world.process();
      expect(sut.getInitialTimeDelay(), equals(50.0));
      expect(sut.getRemainingTimeUntilProcessing(), equals(50.0));
      expect(world.entityManager.totalDeleted, equals(1));
      expect(t2.time, equals(0.0));

      world.process();
      expect(sut.getInitialTimeDelay(), equals(50.0));
      expect(sut.getRemainingTimeUntilProcessing(), equals(0.0));
      expect(t2.time, equals(0.0));
      expect(world.entityManager.totalDeleted, equals(2));
    });

    test('takes passed time into account when adding new entity', () {
      World world = new World();
      var t1 = new Timer(100.0);
      var t2 = new Timer(150.0);
      world.createAndAddEntity([t1]);
      var sut = new TestDelayedEntityProcessingSystem();
      world.addSystem(sut);
      world.delta = 50.0;
      world.initialize();

      world.process();
      world.createAndAddEntity([t2]);
      world.process();
      expect(sut.getInitialTimeDelay(), equals(100.0));
      expect(sut.getRemainingTimeUntilProcessing(), equals(100.0));
      expect(world.entityManager.totalDeleted, equals(0));
      expect(t1.time, equals(0.0));
      expect(t2.time, equals(100.0));
    });
  });
}

class Timer extends Component {
  double time;
  Timer(this.time);
}

class TestDelayedEntityProcessingSystem extends DelayedEntityProcessingSystem {
  ComponentMapper<Timer> timerMapper;
  TestDelayedEntityProcessingSystem() : super(Aspect.getAspectForAllOf([Timer]));

  @override
  void initialize() {
    timerMapper = new ComponentMapper(Timer, world);
  }

  @override
  num getRemainingDelay(Entity entity) => timerMapper.get(entity).time;

  @override
  void processDelta(Entity entity, num accumulatedDelta) {
    timerMapper.get(entity).time -= accumulatedDelta;
  }

  @override
  void processExpired(Entity e) {
    e.deleteFromWorld();
  }
}