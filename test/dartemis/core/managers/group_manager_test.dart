import 'package:dartemis/dartemis.dart';
import 'package:test/test.dart';

void main() {
  group('GroupManager tests', () {
    late World world;
    late GroupManager sut;
    late int entityA;
    late int entityAB;
    late int entity0;
    setUp(() {
      world = World();
      sut = GroupManager();
      world.addManager(sut);

      entityA = world.createEntity();
      sut.add(entityA, 'A');
      entityAB = world.createEntity();
      sut
        ..add(entityAB, 'A')
        ..add(entityAB, 'B');
      entity0 = world.createEntity();
    });
    test('isInAnyGroup', () {
      expect(sut.isInAnyGroup(entityA), equals(true));
      expect(sut.isInAnyGroup(entityAB), equals(true));
      expect(sut.isInAnyGroup(entity0), equals(false));
    });
    test('isInGroup', () {
      expect(sut.isInGroup(entityA, 'A'), equals(true));
      expect(sut.isInGroup(entityAB, 'A'), equals(true));
      expect(sut.isInGroup(entity0, 'A'), equals(false));
      expect(sut.isInGroup(entityA, 'B'), equals(false));
      expect(sut.isInGroup(entityAB, 'B'), equals(true));
      expect(sut.isInGroup(entity0, 'B'), equals(false));
    });
    test('isInGroup after add and remove', () {
      final entity00 = world.createEntity();
      expect(sut.isInGroup(entity00, 'A'), equals(false));
      sut.add(entity00, 'A');
      expect(sut.isInGroup(entity00, 'A'), equals(true));
      sut.remove(entity00, 'A');
      expect(sut.isInGroup(entity00, 'A'), equals(false));
    });
  });
}
