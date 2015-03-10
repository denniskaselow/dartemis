library component_to_pooled_component_converter_test;

import "package:unittest/unittest.dart";
import "package:dartemis/transformer.dart";
import 'package:analyzer/analyzer.dart';
import 'package:dart_style/dart_style.dart';

void main() {
  group('ComponentToPooledComponentConverter', () {
    var formatter = new DartFormatter();
    var converter = new ComponentToPooledComponentConverter();
    test('SimpleComponent without data', () {
      var component = getClassDeclaration(SIMPLE_COMPONENT);

      converter.convert(component);

      var result = formatter.format(component.toSource());
      expect(result, equals(formatter.format(SIMPLE_POOLED_COMPONENT)));
    });
    test('SimpleComponent with data', () {
      var component = getClassDeclaration(SIMPLE_COMPONENT_WITH_DATA);

      converter.convert(component);

      var result = formatter.format(component.toSource());
      expect(result, equals(formatter.format(SIMPLE_POOLED_COMPONENT_WITH_DATA)));
    });
  });
}

ClassDeclaration getClassDeclaration(String componentSource) {
  var compilationUnit = parseCompilationUnit(componentSource);
  return compilationUnit.declarations[0];
}



const SIMPLE_COMPONENT = '''
class SimpleComponent extends Component {}
''';

const SIMPLE_POOLED_COMPONENT = '''
class SimpleComponent extends PooledComponent {
  factory SimpleComponent() {
    SimpleComponent pooledComponent = new Pooled.of(SimpleComponent, _ctor);
    return pooledComponent;
  }
  static SimpleComponent _ctor() => new SimpleComponent._();
  SimpleComponent._();
}
''';



const SIMPLE_COMPONENT_WITH_DATA = '''
class SimpleComponent extends Component {
  String data;
  SimpleComponent(this.data);
}
''';

const SIMPLE_POOLED_COMPONENT_WITH_DATA = '''
class SimpleComponent extends PooledComponent {
  String data;
  factory SimpleComponent(data) {
    SimpleComponent pooledComponent = new Pooled.of(SimpleComponent, _ctor);
    pooledComponent.data = data;
    return pooledComponent;
  }
  static SimpleComponent _ctor() => new SimpleComponent._();
  SimpleComponent._();
}
''';
