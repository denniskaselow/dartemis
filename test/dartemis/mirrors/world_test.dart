library world_test;

import "package:unittest/unittest.dart";

import "package:dartemis/dartemis_mirrors.dart";
import "../core/components_setup.dart";


void main() {
  group('World injection tests', () {
    World world;
    setUp(() {
      world = new World();
      world.addManager(new TagManager());
      world.addSystem(new EntitySystemWithComponentMapper());
      world.addSystem(new EntitySystemExtendingSystemWithComponentMapper());
      world.addSystem(new EntitySystemWithManager());
      world.addSystem(new EntitySystemWithOtherSystem());
      world.addSystem(new EntitySystemWithNothingToInject());

      world.initialize();
    });
    test('world injects ComponentMapper into system', () {
      EntitySystemWithComponentMapper system = world.getSystem(EntitySystemWithComponentMapper);

      expect(system.mapperForA, isNotNull);
      expect(system.mapperForA, new isInstanceOf<ComponentMapper>('ComponentMapper'));
    });
    test('world injects ComponentMapper into extended system', () {
      EntitySystemExtendingSystemWithComponentMapper system = world.getSystem(EntitySystemExtendingSystemWithComponentMapper);

      expect(system.mapperForA, isNotNull);
      expect(system.mapperForA, new isInstanceOf<ComponentMapper>('ComponentMapper'));
      expect(system.mapperForB, isNotNull);
      expect(system.mapperForB, new isInstanceOf<ComponentMapper>('ComponentMapper'));
    });
    test('world injects Managers into system', () {
      EntitySystemWithManager system = world.getSystem(EntitySystemWithManager);

      expect(system.tagManager, isNotNull);
      expect(system.tagManager, same(world.getManager(TagManager)));
    });
    test('world injects Systems into system', () {
      EntitySystemWithOtherSystem system = world.getSystem(EntitySystemWithOtherSystem);

      expect(system.systemWithManager, isNotNull);
      expect(system.systemWithManager, same(world.getSystem(EntitySystemWithManager)));
    });
    test('world injects nothing into system when there is nothing to inject', () {
      EntitySystemWithNothingToInject system = world.getSystem(EntitySystemWithNothingToInject);

      expect(system.a, isNull);
      expect(system.b, isNull);
      expect(system.c, isNull);
      expect(system.d, isNull);
    });
  });
}

class EntitySystemWithComponentMapper extends VoidEntitySystem {
  ComponentMapper<ComponentA> mapperForA;
  processSystem() {}
}

class EntitySystemWithManager extends VoidEntitySystem {
  TagManager tagManager;
  processSystem() {}
}

class EntitySystemWithOtherSystem extends VoidEntitySystem {
  EntitySystemWithManager systemWithManager;
  processSystem() {}
}

class EntitySystemExtendingSystemWithComponentMapper extends EntitySystemWithComponentMapper {
  ComponentMapper<ComponentB> mapperForB;
}

class EntitySystemWithNothingToInject extends VoidEntitySystem {
  var a;
  dynamic b;
  int c;
  String d;
  processSystem() {}
}