library world_test;

import 'package:test/test.dart';

import "package:dartemis/dartemis_mirrors.dart";
import "../core/components_setup.dart";


void main() {
  group('World injection tests', () {
    World world;
    setUp(() {
      world = new World();
      world.addManager(new TagManager());
      world.addManager(new ManagerWithMapper());
      world.addManager(new ManagerExtendingManagerWithMapper());
      world.addManager(new ManagerWithOtherManager());
      world.addManager(new ManagerWithSystem());
      world.addManager(new ManagerWithNothingToInject());
      world.addSystem(new EntitySystemWithMapper());
      world.addSystem(new EntitySystemExtendingSystemWithMapper());
      world.addSystem(new EntitySystemWithManager());
      world.addSystem(new EntitySystemWithOtherSystem());
      world.addSystem(new EntitySystemWithNothingToInject());

      world.initialize();
    });
    test('world injects Mapper into system', () {
      EntitySystemWithMapper system = world.getSystem(EntitySystemWithMapper);

      expect(system.mapperForA, isNotNull);
      expect(system.mapperForA, const isInstanceOf<Mapper>());
    });
    test('world injects Mapper into extended system', () {
      EntitySystemExtendingSystemWithMapper system = world.getSystem(EntitySystemExtendingSystemWithMapper);

      expect(system.mapperForA, isNotNull);
      expect(system.mapperForA, const isInstanceOf<Mapper>());
      expect(system.mapperForB, isNotNull);
      expect(system.mapperForB, const isInstanceOf<Mapper>());
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

    test('world injects Mapper into manager', () {
      ManagerWithMapper manager = world.getManager(ManagerWithMapper);

      expect(manager.mapperForA, isNotNull);
      expect(manager.mapperForA, const isInstanceOf<Mapper>());
    });
    test('world injects Mapper into extended manager', () {
      ManagerExtendingManagerWithMapper manager = world.getManager(ManagerExtendingManagerWithMapper);

      expect(manager.mapperForA, isNotNull);
      expect(manager.mapperForA, const isInstanceOf<Mapper>());
      expect(manager.mapperForB, isNotNull);
      expect(manager.mapperForB, const isInstanceOf<Mapper>());
    });
    test('world injects Managers into manager', () {
      ManagerWithOtherManager manager = world.getManager(ManagerWithOtherManager);

      expect(manager.tagManager, isNotNull);
      expect(manager.tagManager, same(world.getManager(TagManager)));
    });
    test('world injects Systems into manager', () {
      ManagerWithSystem manager = world.getManager(ManagerWithSystem);

      expect(manager.systemWithManager, isNotNull);
      expect(manager.systemWithManager, same(world.getSystem(EntitySystemWithManager)));
    });
    test('world injects nothing into system when there is nothing to inject', () {
      ManagerWithNothingToInject manager = world.getManager(ManagerWithNothingToInject);

      expect(manager.a, isNull);
      expect(manager.b, isNull);
      expect(manager.c, isNull);
      expect(manager.d, isNull);
    });
  });
}

class EntitySystemWithMapper extends VoidEntitySystem {
  Mapper<ComponentA> mapperForA;
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

class EntitySystemExtendingSystemWithMapper extends EntitySystemWithMapper {
  Mapper<ComponentB> mapperForB;
}

class EntitySystemWithNothingToInject extends VoidEntitySystem {
  var a;
  dynamic b;
  int c;
  String d;
  processSystem() {}
}


class ManagerWithMapper extends Manager {
  Mapper<ComponentA> mapperForA;
  processSystem() {}
}

class ManagerWithOtherManager extends Manager {
  TagManager tagManager;
  processSystem() {}
}

class ManagerWithSystem extends Manager {
  EntitySystemWithManager systemWithManager;
  processSystem() {}
}

class ManagerExtendingManagerWithMapper extends ManagerWithMapper {
  Mapper<ComponentB> mapperForB;
}

class ManagerWithNothingToInject extends Manager {
  var a;
  dynamic b;
  int c;
  String d;
}