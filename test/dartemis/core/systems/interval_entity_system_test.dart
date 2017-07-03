library interval_entity_system_test;

import "package:test/test.dart";

import "package:dartemis/dartemis.dart";

void main() {
  group('IntervalEntitySystem tests', () {
    test('delta returns accumulated time since last processing', () {
      World world = new World();
      var sut = new TestIntervalEntitySystem(40);
      world
        ..addSystem(sut)
        ..delta = 16;

      expect(sut.checkProcessing(), equals(false));
      expect(sut.checkProcessing(), equals(false));
      expect(sut.checkProcessing(), equals(true));
      expect(sut.delta, equals(48));
      sut.end();
      expect(sut.checkProcessing(), equals(false));
      expect(sut.checkProcessing(), equals(true));
      expect(sut.delta, equals(32));
    });
  });
}

class TestIntervalEntitySystem extends IntervalEntitySystem {
  TestIntervalEntitySystem(num interval) : super(interval, new Aspect.empty());
  @override
  void processEntities(Iterable<Entity> entities) {}
}
