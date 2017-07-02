library entityt_manager_test;

import "package:test/test.dart";

import "package:dartemis/dartemis.dart";

void main() {
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
    test('entities have unique uniqueIds', () {
      Entity a = world.createEntity();
      Entity b = world.createEntity();

      expect(a.uniqueId, isNot(equals(b.uniqueId)));
    });
    test('isEnabled returns correct values for enabled/disabled', () {
      Entity a = world.createEntity();
      Entity b = world.createEntity();
      world
        ..disable(b)
        ..processEntityChanges();

      expect(world.entityManager.isEnabled(a.id), equals(true));
      expect(world.entityManager.isEnabled(b.id), equals(false));
    });
    test(
        'isEnabled does not fail if bag of disabled entities is smaller than amount of entities',
        () {
      for (int i = 0; i < 16; i++) {
        world.createEntity();
      }
      Entity a = world.createEntity();

      expect(world.entityManager.isEnabled(a.id), equals(true));
    });
  });
}
