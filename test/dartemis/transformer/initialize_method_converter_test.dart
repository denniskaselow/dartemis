library initiale_method_converter_test;

import "package:unittest/unittest.dart";
import "package:dartemis/transformer.dart";
import 'package:analyzer/analyzer.dart';
import 'package:dart_style/dart_style.dart';

void main() {
  group('InitializeMethodConverter', () {
    DartFormatter formatter;
    InitializeMethodConverter converter;
    setUp(() {
      formatter = new DartFormatter();
      converter = new InitializeMethodConverter(_nodes);
    });
    group('initializes Mapper in', () {
      test('sytem without initialize', () {
        var system = getClassDeclaration(SYSTEM_WITHOUT_INITIALIZE_WITH_MAPPER);

        var modified = converter.convert(system);

        var result = formatter.format(system.toSource());
        expect(result, equals(formatter.format(SYSTEM_WITHOUT_INITIALIZE_WITH_MAPPER_RESULT)));
        expect(modified, equals(true));
      });
      test('sytem with mixin without initialize', () {
        var system = getClassDeclaration(SYSTEM_WITH_MIXIN_WITHOUT_INITIALIZE_WITH_MAPPER);

        converter.convert(system);

        var result = formatter.format(system.toSource());
        expect(result, equals(formatter.format(SYSTEM_WITH_MIXIN_WITHOUT_INITIALIZE_WITH_MAPPER_RESULT)));
      });
      test('sytem with initialize', () {
        var system = getClassDeclaration(SYSTEM_WITH_INITIALIZE_WITH_MAPPER);

        converter.convert(system);

        var result = formatter.format(system.toSource());
        expect(result, equals(formatter.format(SYSTEM_WITH_INITIALIZE_WITH_MAPPER_RESULT)));
      });
      test('manager without initialize', () {
        var system = getClassDeclaration(MANAGER_WITHOUT_INITIALIZE_WITH_MAPPER);

        converter.convert(system);

        var result = formatter.format(system.toSource());
        expect(result, equals(formatter.format(MANAGER_WITHOUT_INITIALIZE_WITH_MAPPER_RESULT)));
      });
    });
    group('initializes Manager in', () {
      test('sytem without initialize', () {
        var system = getClassDeclaration(SYSTEM_WITHOUT_INITIALIZE_WITH_MANAGER);

        converter.convert(system);

        var result = formatter.format(system.toSource());
        expect(result, equals(formatter.format(SYSTEM_WITHOUT_INITIALIZE_WITH_MANAGER_RESULT)));
      });
    });
    group('initializes System in', () {
      test('system without initialize', () {
        var system = getClassDeclaration(SYSTEM_WITHOUT_INITIALIZE_WITH_OTHER_SYSTEM);

        converter.convert(system);

        var result = formatter.format(system.toSource());
        expect(result, equals(formatter.format(SYSTEM_WITHOUT_INITIALIZE_WITH_OTHER_SYSTEM_RESULT)));
      });
    });
    group('does nothing', () {
      test('if there is nothing to initialize', () {
        var system = getClassDeclaration(SYSTEM_WITH_DYNAMIC_FIELD);

        converter.convert(system);

        var result = formatter.format(system.toSource());
        expect(result, equals(formatter.format(SYSTEM_WITH_DYNAMIC_FIELD)));
      });
    });
  });
}

ClassDeclaration getClassDeclaration(String systemSource) {
  var compilationUnit = parseCompilationUnit(systemSource);
  return compilationUnit.declarations[0];
}

const SYSTEM_WITHOUT_INITIALIZE_WITH_MAPPER = '''
class SimpleSystem extends VoidEntitySystem {
  Mapper<Position> pm;
}
''';

const SYSTEM_WITHOUT_INITIALIZE_WITH_MAPPER_RESULT = '''
class SimpleSystem extends VoidEntitySystem {
  Mapper<Position> pm;
  @override void initialize() {
    super.initialize();
    pm = new Mapper<Position>(Position, world);
  }
}
''';

const SYSTEM_WITH_MIXIN_WITHOUT_INITIALIZE_WITH_MAPPER = '''
class SimpleSystem extends VoidEntitySystem with SomeMixin {
  Mapper<Position> pm;
}
''';

const SYSTEM_WITH_MIXIN_WITHOUT_INITIALIZE_WITH_MAPPER_RESULT = '''
class SimpleSystem extends VoidEntitySystem with SomeMixin {
  Mapper<Position> pm;
  @override void initialize() {
    super.initialize();
    pm = new Mapper<Position>(Position, world);
  }
}
''';

const SYSTEM_WITH_INITIALIZE_WITH_MAPPER = '''
class SimpleSystem extends VoidEntitySystem {
  Mapper<Position> pm;
  @override void initialize() {}
}
''';

const SYSTEM_WITH_INITIALIZE_WITH_MAPPER_RESULT = '''
class SimpleSystem extends VoidEntitySystem {
  Mapper<Position> pm;
  @override void initialize() {
    pm = new Mapper<Position>(Position, world);
  }
}
''';

const MANAGER_WITHOUT_INITIALIZE_WITH_MAPPER = '''
class SimpleManager extends Manager {
  Mapper<Position> pm;
}
''';

const MANAGER_WITHOUT_INITIALIZE_WITH_MAPPER_RESULT = '''
class SimpleManager extends Manager {
  Mapper<Position> pm;
  @override void initialize() {
    super.initialize();
    pm = new Mapper<Position>(Position, world);
  }
}
''';

const SYSTEM_WITHOUT_INITIALIZE_WITH_MANAGER = '''
class SimpleSystem extends VoidEntitySystem {
  SimpleManager sm;
}
''';

const SYSTEM_WITHOUT_INITIALIZE_WITH_MANAGER_RESULT = '''
class SimpleSystem extends VoidEntitySystem {
  SimpleManager sm;
  @override void initialize() {
    super.initialize();
    sm = world.getManager(SimpleManager);
  }
}
''';

const SYSTEM_WITHOUT_INITIALIZE_WITH_OTHER_SYSTEM = '''
class SimpleSystem extends VoidEntitySystem {
  OtherSystem om;
}
''';

const SYSTEM_WITHOUT_INITIALIZE_WITH_OTHER_SYSTEM_RESULT = '''
class SimpleSystem extends VoidEntitySystem {
  OtherSystem om;
  @override void initialize() {
    super.initialize();
    om = world.getSystem(OtherSystem);
  }
}
''';

const SYSTEM_WITH_DYNAMIC_FIELD = '''
class SimpleSystem extends VoidEntitySystem {
  var something;
}
''';

Map<String, ClassHierarchyNode> _nodes = {
  'VoidEntitySystem': new ClassHierarchyNode('VoidEntitySystem', 'EntitySystem'),
  'OtherSystem': new ClassHierarchyNode('OtherSystem', 'EntitySystem'),
  'SimpleManager': new ClassHierarchyNode('SimpleManager', 'Manager'),
};
