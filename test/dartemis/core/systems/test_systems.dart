library systems.test_systems;

import 'delayed_entity_processing_system_test.dart' as delayed_entity_processing_system;
import 'interval_entity_system_test.dart' as interval_entity_system;

void main() {
  interval_entity_system.main();
  delayed_entity_processing_system.main();
}