library component_to_pooled_component_converter_test;

import "package:unittest/unittest.dart";
import "package:dartemis/transformer.dart";
import 'package:analyzer/analyzer.dart';
import 'package:dart_style/dart_style.dart';

void main() {
  group('ComponentToPooledComponentConverter converts', () {
    var formatter = new DartFormatter();
    var converter = new ComponentToPooledComponentConverter();
    test('component without data', () {
      var component = getClassDeclaration(SIMPLE_COMPONENT);

      converter.convert(component);

      var result = formatter.format(component.toSource());
      expect(result, equals(formatter.format(SIMPLE_POOLED_COMPONENT)));
    });
    test('component with data', () {
      var component = getClassDeclaration(COMPONENT_WITH_DATA);

      converter.convert(component);

      var result = formatter.format(component.toSource());
      expect(result, equals(formatter.format(POOLED_COMPONENT_WITH_DATA)));
    });
    test('component with optional data', () {
      var component = getClassDeclaration(COMPONENT_WITH_OPTIONAL_PARAM_DATA);

      converter.convert(component);

      var result = formatter.format(component.toSource());
      expect(result, equals(formatter.format(POOLED_COMPONENT_WITH_OPTIONAL_PARAM_DATA)));
    });
    test('component with initializer', () {
      var component = getClassDeclaration(COMPONENT_WITH_INITIALIZER);

      converter.convert(component);

      var result = formatter.format(component.toSource());
      expect(result, equals(formatter.format(POOLED_COMPONENT_WITH_INITIALIZER)));
    });
    test('component with simple constructor block', () {
      var component = getClassDeclaration(COMPONENT_WITH_SIMPLE_CONSTRUCTOR_BLOCK);

      converter.convert(component);

      var result = formatter.format(component.toSource());
      expect(result, equals(formatter.format(POOLED_COMPONENT_WITH_SIMPLE_CONSTRUCTOR_BLOCK)));
    });
    test('component with initializer', () {
      var component = getClassDeclaration(SIMPLE_COMPONENT_WITH_INITIALIZER);

      converter.convert(component);

      var result = formatter.format(component.toSource());
      expect(result, equals(formatter.format(SIMPLE_POOLED_COMPONENT_WITH_INITIALIZER)));
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



const COMPONENT_WITH_DATA = '''
class SimpleComponent extends Component {
  String data;
  SimpleComponent(this.data);
}
''';

const POOLED_COMPONENT_WITH_DATA = '''
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



const COMPONENT_WITH_OPTIONAL_PARAM_DATA = '''
class SimpleComponent extends Component {
  String data;
  SimpleComponent([this.data = 'default']);
}
''';

const POOLED_COMPONENT_WITH_OPTIONAL_PARAM_DATA = '''
class SimpleComponent extends PooledComponent {
  String data;
  factory SimpleComponent([data = 'default']) {
    SimpleComponent pooledComponent = new Pooled.of(SimpleComponent, _ctor);
    pooledComponent.data = data;
    return pooledComponent;
  }
  static SimpleComponent _ctor() => new SimpleComponent._();
  SimpleComponent._();
}
''';


const COMPONENT_WITH_INITIALIZER = '''
class SimpleComponent extends Component {
  double data;
  SimpleComponent(num data) : data = data.toDouble();
}
''';

const POOLED_COMPONENT_WITH_INITIALIZER = '''
class SimpleComponent extends PooledComponent {
  double data;
  factory SimpleComponent(num data) {
    SimpleComponent pooledComponent = new Pooled.of(SimpleComponent, _ctor);
    pooledComponent.data = data.toDouble();
    return pooledComponent;
  }
  static SimpleComponent _ctor() => new SimpleComponent._();
  SimpleComponent._();
}
''';



const COMPONENT_WITH_SIMPLE_CONSTRUCTOR_BLOCK = '''
class SimpleComponent extends Component {
  double x;
  SimpleComponent(num x) {
    this.x = x.toDouble();
  }
}
''';

const POOLED_COMPONENT_WITH_SIMPLE_CONSTRUCTOR_BLOCK = '''
class SimpleComponent extends PooledComponent {
  double x;
  factory SimpleComponent(num x) {
    SimpleComponent pooledComponent = new Pooled.of(SimpleComponent, _ctor);
    pooledComponent.x = x.toDouble();
    return pooledComponent;
  }
  static SimpleComponent _ctor() => new SimpleComponent._();
  SimpleComponent._();
}
''';
