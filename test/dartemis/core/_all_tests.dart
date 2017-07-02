library core._all_tests;

import 'aspect_test.dart' as aspect;
import 'component_manager_test.dart' as componentManager;
import 'component_test.dart' as component;
import 'component_type_test.dart' as componentType;
import 'entity_manager_test.dart' as entityManager;
import 'managers/_test_managers.dart' as managers;

import 'systems/_test_systems.dart' as systems;
import 'utils/_all_tests.dart' as utils;
import 'world_test.dart' as world;

void main() {
  aspect.main();
  component.main();
  componentManager.main();
  componentType.main();
  entityManager.main();
  world.main();

  managers.main();
  systems.main();
  utils.main();
}