library mapper_test;

import 'package:test/test.dart';

import 'package:dartemis/dartemis.dart';

import 'components_setup.dart';

void main() {
  group('Mapper', () {
    late World world;
    setUp(() {
      world = World();
    });
    test('gets component for entity', () {
      final componentA = ComponentA();
      final componentB = ComponentB();
      final entity = world.createEntity([componentA, componentB]);
      world
        ..initialize()
        ..process();

      final mapper = Mapper<ComponentA>(world);

      expect(mapper[entity], equals(componentA));
    });
  });
  group('OptionalMapper', () {
    late World world;
    setUp(() {
      world = World();
    });
    test('gets component for entity', () {
      final componentA = ComponentA();
      final entity = world.createEntity([componentA]);
      world
        ..initialize()
        ..process();

      final mapperA = OptionalMapper<ComponentA>(world);
      final mapperB = OptionalMapper<ComponentB>(world);

      expect(mapperA[entity], equals(componentA));
      expect(mapperB[entity], equals(null));
    });
  });
}
