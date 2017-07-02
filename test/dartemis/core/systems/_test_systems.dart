library systems._all_tests;

import 'delayed_entity_processing_system_test.dart' as delayedEntityProcessingSystem;
import 'interval_entity_system_test.dart' as intervalEntitySystem;

void main() {
  intervalEntitySystem.main();
  delayedEntityProcessingSystem.main();
}