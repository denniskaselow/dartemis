library system_transformer_test;

import "dart:async";

import "package:unittest/unittest.dart";
import 'package:analyzer/analyzer.dart';
import "package:mock/mock.dart";
import "package:barback/barback.dart" show AggregateTransform, Asset;
import "package:dartemis/transformer.dart";

void main() {
  group('SystemTransformer', () {
    AggregateTransformMock transformMock;
    AssetMock assetMock;
    SystemTransformer transformer;

    setUp(() {
      transformer = new SystemTransformer.asPlugin();
      transformMock = new AggregateTransformMock();
      assetMock = new AssetMock();
      transformMock.when(callsTo('get primaryInputs')).alwaysReturn(new Stream.fromIterable([assetMock]));
    });
    group('initializes Mapper in', () {

      test('sytem without initialize', () {
        assetMock.when(callsTo('readAsString')).alwaysReturn(new Future.value(SYSTEM_WITHOUT_INITIALIZE));

        transformer.apply(transformMock).then(expectAsync((_) {
          var resultAsset = transformMock.getLogs(callsTo('addOutput')).first as LogEntry;
          (resultAsset.args[0] as Asset).readAsString().then(expectAsync((content) {
            expect(content, equals(parseCompilationUnit(SYSTEM_WITHOUT_INITIALIZE_RESULT).toSource()));
          }));
        }));
      });

      test('sytem with initialize', () {
        assetMock.when(callsTo('readAsString')).alwaysReturn(new Future.value(SYSTEM_WITH_INITIALIZE));

        transformer.apply(transformMock).then(expectAsync((_) {
          var resultAsset = transformMock.getLogs(callsTo('addOutput')).first as LogEntry;
          (resultAsset.args[0] as Asset).readAsString().then(expectAsync((content) {
            expect(content, equals(parseCompilationUnit(SYSTEM_WITH_INITIALIZE_RESULT).toSource()));
          }));
        }));
      });
    });

    group('doesn\'t crash', () {
      test('for system with dynamic fields', () {
        assetMock.when(callsTo('readAsString')).alwaysReturn(new Future.value(SYSTEM_WITH_DYNAMIC_FIELD));

        transformer.apply(transformMock).then(expectAsync((_) {
          var resultAsset = transformMock.getLogs(callsTo('addOutput')).first as LogEntry;
          (resultAsset.args[0] as Asset).readAsString().then(expectAsync((content) {
            expect(content, equals(parseCompilationUnit(SYSTEM_WITH_DYNAMIC_FIELD).toSource()));
          }));
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

class AggregateTransformMock extends Mock implements AggregateTransform {}
class AssetMock extends Mock implements Asset {}