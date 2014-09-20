library system_transformer_test;

import "dart:async";

import "package:unittest/unittest.dart";
import 'package:analyzer/analyzer.dart';
import "package:mock/mock.dart";
import "package:barback/barback.dart" show Transform, Asset;
import "package:dartemis/transformer.dart";

void main() {
  group('SystemTransformer initializes Mapper in', () {
    TransformMock transformMock;
    AssetMock assetMock;
    SystemTransformer transformer;

    setUp(() {
      transformer = new SystemTransformer.asPlugin();
      transformMock = new TransformMock();
      assetMock = new AssetMock();
    });

    test('sytem without initialize', () {
      transformMock.when(callsTo('get primaryInput')).alwaysReturn(assetMock);
      assetMock.when(callsTo('readAsString')).alwaysReturn(new Future.value(SYSTEM_WITHOUT_INITIALIZE));

      transformer.apply(transformMock).then(expectAsync((_) {
        var resultAsset = transformMock.getLogs(callsTo('addOutput')).first as LogEntry;
        (resultAsset.args[0] as Asset).readAsString().then(expectAsync((content) {
          expect(content, equals(parseCompilationUnit(SYSTEM_WITHOUT_INITIALIZE_RESULT).toSource()));
        }));
      }));
    });

    test('sytem with initialize', () {
      transformMock.when(callsTo('get primaryInput')).alwaysReturn(assetMock);
      assetMock.when(callsTo('readAsString')).alwaysReturn(new Future.value(SYSTEM_WITH_INITIALIZE));

      transformer.apply(transformMock).then(expectAsync((_) {
        var resultAsset = transformMock.getLogs(callsTo('addOutput')).first as LogEntry;
        (resultAsset.args[0] as Asset).readAsString().then(expectAsync((content) {
          expect(content, equals(parseCompilationUnit(SYSTEM_WITH_INITIALIZE_RESULT).toSource()));
        }));
      }));
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

class TransformMock extends Mock implements Transform {}
class AssetMock extends Mock implements Asset {}