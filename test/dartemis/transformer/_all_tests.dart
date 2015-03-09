library transformer._all_tests;

import 'dartemis_transformer_test.dart' as dartemis_transformer;
import 'component_to_pooled_component_converter_test.dart' as component_to_pooled_component_converter;
import 'utils/_all_tests.dart' as utils;

void main() {
  utils.main();
  dartemis_transformer.main();
  component_to_pooled_component_converter.main();
}