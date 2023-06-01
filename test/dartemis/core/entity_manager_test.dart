import 'package:dartemis/dartemis.dart';
import 'package:test/test.dart';

void main() {
  group('integration tests for EntityManager', () {
    late World world;
    setUp(() {
      world = World();
    });
    test('entities have uniqure IDs', () {
      final a = world.createEntity();
      final b = world.createEntity();

      expect(a, isNot(equals(b)));
    });
  });
}
