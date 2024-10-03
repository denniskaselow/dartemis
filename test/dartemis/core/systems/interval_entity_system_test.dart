import 'package:dartemis/dartemis.dart';
import 'package:test/test.dart';

void main() {
  group('IntervalEntitySystem tests', () {
    test('delta returns accumulated time since last processing', () {
      final world = World();
      final sut = TestIntervalEntitySystem(40);
      world
        ..addSystem(sut)
        ..initialize()
        ..delta = 16;

      // ignore: invalid_use_of_visible_for_overriding_member
      expect(sut.checkProcessing(), equals(false));
      // ignore: invalid_use_of_visible_for_overriding_member
      expect(sut.checkProcessing(), equals(false));
      // ignore: invalid_use_of_visible_for_overriding_member
      expect(sut.checkProcessing(), equals(true));
      expect(sut.delta, equals(48));
      // ignore: invalid_use_of_visible_for_overriding_member
      sut.end();
      // ignore: invalid_use_of_visible_for_overriding_member
      expect(sut.checkProcessing(), equals(false));
      // ignore: invalid_use_of_visible_for_overriding_member
      expect(sut.checkProcessing(), equals(true));
      expect(sut.delta, equals(32));
    });
  });
}

class TestIntervalEntitySystem extends IntervalEntitySystem {
  TestIntervalEntitySystem(double interval) : super(interval, Aspect());
  @override
  void processEntities(Iterable<Entity> entities) {}
}
