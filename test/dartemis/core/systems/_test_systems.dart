library systems._all_tests;

import 'interval_entity_system_test.dart' as intervalEntitySystem;
import 'delayed_entity_processing_system_test.dart' as delayedEntityProcessingSystem;

void main() {
  intervalEntitySystem.main();
  delayedEntityProcessingSystem.main();
}