import 'package:dartemis/dartemis.dart';
import 'package:test/test.dart';

void main() {
  group('TagManager tests', () {
    late World world;
    late TagManager sut;
    late int entity;
    setUp(() {
      world = World();
      sut = TagManager();
      world.addManager(sut);

      entity = world.createEntity();
      sut.register(entity, 'tag');
    });
    test('getEntity returns registered entity', () {
      final actualEntity = sut.getEntity('tag');

      expect(actualEntity, equals(entity));
    });
    test(
        '''register overwrites existing entity if a another entity is registered using the same tag''',
        () {
      final anotherEntity = world.createEntity();
      sut.register(anotherEntity, 'tag');

      final actualEntity = sut.getEntity('tag');
      expect(actualEntity, equals(anotherEntity));
    });
    test(
        '''deleting a previously registered entity does not mess up accessing a newly registered entity''',
        () {
      final anotherEntity = world.createEntity();
      sut.register(anotherEntity, 'tag');
      world.deleteEntity(entity);

      final actualEntity = sut.getEntity('tag');
      expect(actualEntity, equals(anotherEntity));
    });
  });
}
