library transformer._all_tests;

import 'dartemis_transformer_test.dart' as dartemis_transformer;
import 'component_to_pooled_component_converter_test.dart' as component_to_pooled_component_converter;
import 'initialize_method_converter_test.dart' as initialize_method_converter;

void main() {
  dartemis_transformer.main();
  component_to_pooled_component_converter.main();
  initialize_method_converter.main();
}