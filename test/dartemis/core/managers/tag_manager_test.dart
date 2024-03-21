import 'package:dartemis/dartemis.dart';
import 'package:test/test.dart';

void main() {
  group('TagManager tests', () {
    const tag = 'some tag';

    late World world;
    late TagManager sut;
    late int entityWithTag;
    late int entityWithoutTag;
    setUp(() {
      world = World();
      sut = TagManager();
      world.addManager(sut);

      entityWithTag = world.createEntity();
      entityWithoutTag = world.createEntity();

      sut.register(entityWithTag, tag);
    });
    test('getEntity returns registered entity', () {
      final actualEntity = sut.getEntity(tag);

      expect(actualEntity, equals(entityWithTag));
    });
    test('getEntity returns null if tag has been unregistered', () {
      sut.unregister(tag);

      final actualEntity = sut.getEntity(tag);

      expect(actualEntity, isNull);
    });
    test('getEntity returns null if tag does not exist', () {
      final actualEntity = sut.getEntity('nonexistent tag');

      expect(actualEntity, isNull);
    });
    test('getTag returns registered tag', () {
      final actualTag = sut.getTag(entityWithTag);

      expect(actualTag, equals(tag));
    });
    test('getTag returns null if entity has no tag', () {
      final actualTag = sut.getTag(entityWithoutTag);

      expect(actualTag, isNull);
    });
    test('getTag returns null if tag has been unregistered', () {
      sut.unregister(tag);

      final actualTag = sut.getTag(entityWithTag);

      expect(actualTag, isNull);
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
      world.deleteEntity(entityWithTag);

      final actualEntity = sut.getEntity('tag');
      expect(actualEntity, equals(anotherEntity));
    });
  });
}
