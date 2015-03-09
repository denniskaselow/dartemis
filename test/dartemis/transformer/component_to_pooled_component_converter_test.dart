library component_to_pooled_component_converter_test;

import "package:unittest/unittest.dart";
import "package:dartemis/transformer.dart";
import 'package:analyzer/analyzer.dart';
import 'package:dart_style/dart_style.dart';

void main() {
  group('ComponentToPooledComponentConverter', () {
    var formatter = new DartFormatter();
    var converter = new ComponentToPooledComponentConverter();
    test('SimpleComponent without content', () {
      var component = getClassDeclaration(SIMPLE_COMPONENT);

      converter.convert(component);

      var result = formatter.format(component.toSource());
      expect(result, equals(formatter.format(SIMPLE_POOLED_COMPONENT)));
    });
  });
}

ClassDeclaration getClassDeclaration(String componentSource) {
  var compilationUnit = parseCompilationUnit(SIMPLE_COMPONENT);
  return compilationUnit.declarations[0];
}

const SIMPLE_COMPONENT = '''
class SimpleComponent extends Component {}
''';

const SIMPLE_POOLED_COMPONENT = '''
class SimpleComponent extends PooledComponent {
  static SimpleComponent _ctor() => new SimpleComponent._();
  SimpleComponent._();
  factory SimpleComponent() {
    SimpleComponent pooledComponent = new Pooled.of(SimpleComponent, _ctor);
    return pooledComponent;
  }
}
''';

