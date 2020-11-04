library mapper_test;

import 'package:test/test.dart';

import 'package:dartemis/dartemis.dart';

import 'components_setup.dart';

void main() {
  group('mapper', () {
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
}
