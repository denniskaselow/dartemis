library entity_bag_test;

import "package:test/test.dart";

import "package:dartemis/dartemis.dart";

void main() {
  group('EntityBag tests', () {
    EntityBag bag;
    World world = new World();
    Entity e1 = world.createEntity();
    Entity e2 = world.createEntity();
    setUp(() {
      bag = new EntityBag(capacity: 1);
      bag.add(e1);
      bag.add(e2);
    });
    test('removing an element', () {
      bag.remove(e1);
      expect(bag.contains(e1), equals(false));
      expect(bag.contains(e2), equals(true));
      expect(bag.size, equals(1));
    });
    test('removing at position', () {
      bag.removeAt(0);
      expect(bag.contains(e1), equals(false));
      expect(bag.contains(e2), equals(true));
      expect(bag.size, equals(1));
    });
    test('removing last element', () {
      bag.removeLast();
      expect(bag.contains(e1), equals(true));
      expect(bag.contains(e2), equals(false));
      expect(bag.size, equals(1));
    });
    test('iterating', () {
      var iter = bag.iterator;
      expect(iter.moveNext(), equals(true));
      expect(iter.current, equals(e1));
      expect(iter.moveNext(), equals(true));
      expect(iter.current, equals(e2));

      bag.remove(e1);
      iter = bag.iterator;
      expect(iter.moveNext(), equals(true));
      expect(iter.current, equals(e2));
      expect(iter.moveNext(), equals(false));
    });
    test('clear', () {
      bag.clear();
      expect(bag.size, equals(0));
    });
  });
}