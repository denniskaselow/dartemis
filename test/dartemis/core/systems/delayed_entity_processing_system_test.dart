library delayed_entity_processing_system;

import "package:test/test.dart";

import "package:dartemis/dartemis.dart";

void main() {
  group('DelayedEntityProcessingSystem tests', () {
    test('executes after delay has passed', () {
      final world = World();
      final t1 = Timer(100.0);
      final t2 = Timer(150.0);
      world..createAndAddEntity([t1])..createAndAddEntity([t2]);
      final sut = TestDelayedEntityProcessingSystem();
      world
        ..addSystem(sut)
        ..delta = 50.0
        ..initialize()
        ..process();
      expect(sut.getInitialTimeDelay(), equals(100.0));
      expect(sut.getRemainingTimeUntilProcessing(), equals(50.0));
      expect(world.entityManager.totalDeleted, equals(0));
      expect(t1.time, equals(100.0));
      expect(t2.time, equals(150.0));

      world.process();
      expect(sut.getInitialTimeDelay(), equals(50.0));
      expect(sut.getRemainingTimeUntilProcessing(), equals(50.0));
      expect(world.entityManager.totalDeleted, equals(1));
      expect(t1.time, equals(0.0));
      expect(t2.time, equals(50.0));

      world.process();
      expect(sut.getInitialTimeDelay(), equals(50.0));
      expect(sut.getRemainingTimeUntilProcessing(), equals(50.0));
      expect(world.entityManager.totalDeleted, equals(2));
      expect(t2.time, equals(0.0));

      world.process();
      expect(sut.getInitialTimeDelay(), equals(50.0));
      expect(sut.getRemainingTimeUntilProcessing(), equals(0.0));
      expect(t2.time, equals(0.0));
      expect(world.entityManager.totalDeleted, equals(2));
    });

    test('takes passed time into account when adding new entity', () {
      final world = World();
      final t1 = Timer(100.0);
      final t2 = Timer(150.0);
      world.createAndAddEntity([t1]);
      final sut = TestDelayedEntityProcessingSystem();
      world
        ..addSystem(sut)
        ..delta = 50.0
        ..initialize()
        ..process()
        ..createAndAddEntity([t2])
        ..process();
      expect(sut.getInitialTimeDelay(), equals(100.0));
      expect(sut.getRemainingTimeUntilProcessing(), equals(100.0));
      expect(world.entityManager.totalDeleted, equals(1));
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
  Mapper<Timer> timerMapper;
  TestDelayedEntityProcessingSystem() : super(Aspect.forAllOf([Timer]));

  @override
  void initialize() {
    timerMapper = Mapper<Timer>(world);
  }

  @override
  double getRemainingDelay(Entity entity) => timerMapper[entity].time;

  @override
  void processDelta(Entity entity, num accumulatedDelta) {
    timerMapper[entity].time -= accumulatedDelta;
  }

  @override
  void processExpired(Entity entity) {
    entity.deleteFromWorld();
  }
}
