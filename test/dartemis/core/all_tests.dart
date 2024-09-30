import 'aspect_test.dart' as aspect;
import 'component_manager_test.dart' as component_manager;
import 'component_test.dart' as component;
import 'entity_manager_test.dart' as entity_manager;
import 'managers/test_managers.dart' as managers;
import 'mapper_test.dart' as mapper;
import 'systems/test_systems.dart' as systems;
import 'utils/all_tests.dart' as utils;
import 'world_test.dart' as world;

void main() {
  aspect.main();
  component.main();
  component_manager.main();
  entity_manager.main();
  mapper.main();

  managers.main();
  systems.main();
  utils.main();

  world.main();
}
