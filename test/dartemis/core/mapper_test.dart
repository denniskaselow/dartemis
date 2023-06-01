import 'package:dartemis/dartemis.dart';
import 'package:test/test.dart';

import 'components_setup.dart';

void main() {
  group('Mapper', () {
    late World world;
    setUp(() {
      world = World();
    });
    test('gets component for entity', () {
      final componentA = Component0();
      final componentB = Component1();
      final entity = world.createEntity([componentA, componentB]);
      world
        ..initialize()
        ..process();

      final mapper = Mapper<Component0>(world);

      expect(mapper[entity], equals(componentA));
    });
  });
  group('OptionalMapper', () {
    late World world;
    setUp(() {
      world = World();
    });
    test('gets component for entity', () {
      final componentA = Component0();
      final entity = world.createEntity([componentA]);
      world
        ..initialize()
        ..process();

      final mapperA = OptionalMapper<Component0>(world);
      final mapperB = OptionalMapper<Component1>(world);

      expect(mapperA[entity], equals(componentA));
      expect(mapperB[entity], equals(null));
    });
  });
}
