library dartemis_transformer_test;

import "dart:async";

import "package:unittest/unittest.dart";
import 'package:analyzer/analyzer.dart';
import "package:mock/mock.dart";
import "package:barback/barback.dart" show AggregateTransform, Asset;
import "package:dartemis/transformer.dart";

void main() {
  group('DartemisTransformer', () {
    AggregateTransformMock transformMock;
    AssetMock assetMock;
    AssetMock assetMockForVoidEntitySystem;
    DartemisTransformer transformer;

    setUp(() {
      transformer = new DartemisTransformer.asPlugin();
      transformMock = new AggregateTransformMock();
      assetMock = new AssetMock();
      assetMockForVoidEntitySystem = new AssetMock();
      assetMockForVoidEntitySystem.when(callsTo('readAsString')).alwaysReturn(new Future.value(VOID_ENTITY_SYSTEM));
      transformMock.when(callsTo('get primaryInputs')).alwaysReturn(new Stream.fromIterable([assetMock, assetMockForVoidEntitySystem]));
    });
    group('initializes Mapper in', () {

      test('sytem without initialize', () {
        assetMock.when(callsTo('readAsString')).alwaysReturn(new Future.value(SYSTEM_WITHOUT_INITIALIZE));

        transformer.apply(transformMock).then(expectAsync((_) {
          var logs = transformMock.getLogs(callsTo('addOutput'));
          logs.verify(happenedOnce);
          var resultAsset = logs.first as LogEntry;
          (resultAsset.args[0] as Asset).readAsString().then(expectAsync((content) {
            expect(content, equals(parseCompilationUnit(SYSTEM_WITHOUT_INITIALIZE_RESULT).toSource()));
          }));
        }));
      });

      test('sytem with initialize', () {
        assetMock.when(callsTo('readAsString')).alwaysReturn(new Future.value(SYSTEM_WITH_INITIALIZE));

        transformer.apply(transformMock).then(expectAsync((_) {
          var logs = transformMock.getLogs(callsTo('addOutput'));
          logs.verify(happenedOnce);
          var resultAsset = logs.first as LogEntry;
          (resultAsset.args[0] as Asset).readAsString().then(expectAsync((content) {
            expect(content, equals(parseCompilationUnit(SYSTEM_WITH_INITIALIZE_RESULT).toSource()));
          }));
        }));
      });

      test('manager without initialize', () {
        assetMock.when(callsTo('readAsString')).alwaysReturn(new Future.value(MANAGER_WITHOUT_INITIALIZE));

        transformer.apply(transformMock).then(expectAsync((_) {
          var logs = transformMock.getLogs(callsTo('addOutput'));
          logs.verify(happenedOnce);
          var resultAsset = logs.first as LogEntry;
          (resultAsset.args[0] as Asset).readAsString().then(expectAsync((content) {
            expect(content, equals(parseCompilationUnit(MANAGER_WITHOUT_INITIALIZE_RESULT).toSource()));
          }));
        }));
      });
    });

    group('doesn\'t crash', () {
      test('for system with dynamic fields', () {
        assetMock.when(callsTo('readAsString')).alwaysReturn(new Future.value(SYSTEM_WITH_DYNAMIC_FIELD));

        transformer.apply(transformMock).then(expectAsync((_) {
          transformMock.getLogs(callsTo('addOutput')).verify(neverHappened);
        }));
      });

      test('for classes without superclass', () {
        assetMock.when(callsTo('readAsString')).alwaysReturn(new Future.value(CLASS_WITHOUT_SUPERCLASS));

        transformer.apply(transformMock).then(expectAsync((_) {
          transformMock.getLogs(callsTo('addOutput')).verify(neverHappened);
        }));
      });
    });

    group('doesn\'t create instance', () {
      test('in unrelated classes', () {
        assetMock.when(callsTo('readAsString')).alwaysReturn(new Future.value(SOME_OTHER_CLASS_WITH_MAPPER));

        transformer.apply(transformMock).then(expectAsync((_) {
          transformMock.getLogs(callsTo('addOutput')).verify(neverHappened);
        }));
      });
    });
  });
}


const SYSTEM_WITHOUT_INITIALIZE = '''
class SimpleSystem extends VoidEntitySystem {
  Mapper<Position> pm;
}
''';

const SYSTEM_WITHOUT_INITIALIZE_RESULT = '''
class SimpleSystem extends VoidEntitySystem {
  Mapper<Position> pm;
  @override
  void initialize() {
    pm = new Mapper<Position>(Position, world);
  }
}
''';

const MANAGER_WITHOUT_INITIALIZE = '''
class SimpleManager extends Manager {
  Mapper<Position> pm;
}
''';

const MANAGER_WITHOUT_INITIALIZE_RESULT = '''
class SimpleManager extends Manager {
  Mapper<Position> pm;
  @override
  void initialize() {
    pm = new Mapper<Position>(Position, world);
  }
}
''';

const SYSTEM_WITH_INITIALIZE = '''
class SimpleSystem extends VoidEntitySystem {
  Mapper<Position> pm;
  @override
  void initialize() {}
}
''';

const SYSTEM_WITH_INITIALIZE_RESULT = '''
class SimpleSystem extends VoidEntitySystem {
  Mapper<Position> pm;
  @override
  void initialize() {
    pm = new Mapper<Position>(Position, world);
  }
}
''';

const SYSTEM_WITH_DYNAMIC_FIELD = '''
class SimpleSystem extends VoidEntitySystem {
  var something;
}
''';

const CLASS_WITHOUT_SUPERCLASS = '''
class SomeClass {
}
''';

const SOME_OTHER_CLASS_WITH_MAPPER = '''
class SomeOtherClass extends NotAnEntitySystem {
  Mapper<Position> pm;
}
''';

const VOID_ENTITY_SYSTEM = '''
class VoidEntitySystem extends EntitySystem {
}
''';

class AggregateTransformMock extends Mock implements AggregateTransform {}
class AssetMock extends Mock implements Asset {}