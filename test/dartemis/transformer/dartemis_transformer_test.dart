library dartemis_transformer_test;

import "dart:async";

import "package:unittest/unittest.dart";
import 'package:analyzer/analyzer.dart';
import "package:mock/mock.dart";
import "package:barback/barback.dart" show AggregateTransform, Asset, AssetId, BarbackSettings;
import "package:dartemis/transformer.dart";

void main() {
  group('DartemisTransformer', () {
    DartemisTransformer transformer;

    AggregateTransformMock transformMock;
    AssetMock assetMock;
    BarbackSettingsMock barbackSettingsMock;

    setUp(() {
      transformMock = new AggregateTransformMock();
      assetMock = new AssetMock();
      barbackSettingsMock = new BarbackSettingsMock();

      transformer = new DartemisTransformer.asPlugin(barbackSettingsMock);

      transformMock.when(callsTo('get primaryInputs')).alwaysReturn(new Stream.fromIterable([assetMock]));
    });
    group('initializes Mapper in', () {

      test('sytem without initialize', () {
        assetMock.when(callsTo('readAsString')).alwaysReturn(new Future.value(SYSTEM_WITHOUT_INITIALIZE_WITH_MAPPER));

        transformer.apply(transformMock).then(expectAsync((_) {
          var logs = transformMock.getLogs(callsTo('addOutput'));
          logs.verify(happenedOnce);
          var resultAsset = logs.first as LogEntry;
          (resultAsset.args[0] as Asset).readAsString().then(expectAsync((content) {
            expect(content, equals(parseCompilationUnit(SYSTEM_WITHOUT_INITIALIZE_WITH_MAPPER_RESULT).toSource()));
          }));
        }));
      });

      test('sytem with initialize', () {
        assetMock.when(callsTo('readAsString')).alwaysReturn(new Future.value(SYSTEM_WITH_INITIALIZE_WITH_MAPPER));

        transformer.apply(transformMock).then(expectAsync((_) {
          var logs = transformMock.getLogs(callsTo('addOutput'));
          logs.verify(happenedOnce);
          var resultAsset = logs.first as LogEntry;
          (resultAsset.args[0] as Asset).readAsString().then(expectAsync((content) {
            expect(content, equals(parseCompilationUnit(SYSTEM_WITH_INITIALIZE_WITH_MAPPER_RESULT).toSource()));
          }));
        }));
      });

      test('manager without initialize', () {
        assetMock.when(callsTo('readAsString')).alwaysReturn(new Future.value(MANAGER_WITHOUT_INITIALIZE_WITH_MAPPER));

        transformer.apply(transformMock).then(expectAsync((_) {
          var logs = transformMock.getLogs(callsTo('addOutput'));
          logs.verify(happenedOnce);
          var resultAsset = logs.first as LogEntry;
          (resultAsset.args[0] as Asset).readAsString().then(expectAsync((content) {
            expect(content, equals(parseCompilationUnit(MANAGER_WITHOUT_INITIALIZE_WITH_MAPPER_RESULT).toSource()));
          }));
        }));
      });
    });

    group('initializes Manager in', () {

      test('sytem without initialize', () {
        assetMock.when(callsTo('readAsString')).alwaysReturn(new Future.value(SYSTEM_WITHOUT_INITIALIZE_WITH_MANAGER));

        transformer.apply(transformMock).then(expectAsync((_) {
          var logs = transformMock.getLogs(callsTo('addOutput'));
          logs.verify(happenedOnce);
          var resultAsset = logs.first as LogEntry;
          (resultAsset.args[0] as Asset).readAsString().then(expectAsync((content) {
            expect(content, equals(parseCompilationUnit(SYSTEM_WITHOUT_INITIALIZE_WITH_MANAGER_RESULT).toSource()));
          }));
        }));
      });
    });

    group('initializes System in', () {

      test('system without initialize', () {
        assetMock.when(callsTo('readAsString')).alwaysReturn(new Future.value(SYSTEM_WITHOUT_INITIALIZE_WITH_OTHER_SYSTEM));

        transformer.apply(transformMock).then(expectAsync((_) {
          var logs = transformMock.getLogs(callsTo('addOutput'));
          logs.verify(happenedOnce);
          var resultAsset = logs.first as LogEntry;
          (resultAsset.args[0] as Asset).readAsString().then(expectAsync((content) {
            expect(content, equals(parseCompilationUnit(SYSTEM_WITHOUT_INITIALIZE_WITH_OTHER_SYSTEM_RESULT).toSource()));
          }));
        }));
      });
    });

    group('initializes Manager from other Library in', () {

      test('system without initialize', () {
        AssetMock assetOtherLibraryMock = new AssetMock();
        AssetMock assetPartOfOtherLibraryMock = new AssetMock();

        transformMock.when(callsTo('getInput', new AssetId.parse('otherLib|lib/otherLib.dart'))).alwaysReturn(new Future.value(assetOtherLibraryMock));
        transformMock.when(callsTo('getInput', new AssetId.parse('otherLib|lib/src/manager.dart'))).alwaysReturn(new Future.value(assetPartOfOtherLibraryMock));
        assetMock.when(callsTo('readAsString')).alwaysReturn(new Future.value(SYSTEM_WITH_CLASSES_FROM_OTHER_LIBRARY));
        assetOtherLibraryMock.when(callsTo('readAsString')).alwaysReturn(new Future.value(OTHER_LIBRARY));
        assetPartOfOtherLibraryMock.when(callsTo('readAsString')).alwaysReturn(new Future.value(OTHER_LIBRARY_MANAGER));
        barbackSettingsMock.when(callsTo('get configuration')).alwaysReturn({'additionalLibraries': ['otherLib/otherLib.dart']});

        transformer.apply(transformMock).then(expectAsync((_) {
          var logs = transformMock.getLogs(callsTo('addOutput'));
          logs.verify(happenedOnce);
          var resultAsset = logs.first as LogEntry;
          (resultAsset.args[0] as Asset).readAsString().then(expectAsync((content) {
            expect(content, equals(parseCompilationUnit(SYSTEM_WITH_CLASSES_FROM_OTHER_LIBRARY_RESULT).toSource()));
          }));
        }));
      });
    });

    group('initializes everything in', () {

      test('managers and sytems', () {
        assetMock.when(callsTo('readAsString')).alwaysReturn(new Future.value(EVERYTHING_COMBINED));

        transformer.apply(transformMock).then(expectAsync((_) {
          var logs = transformMock.getLogs(callsTo('addOutput'));
          logs.verify(happenedOnce);
          var resultAsset = logs.first as LogEntry;
          (resultAsset.args[0] as Asset).readAsString().then(expectAsync((content) {
            expect(content, equals(parseCompilationUnit(EVERYTHING_COMBINED_RESULT).toSource()));
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

      test('for BarbackSetting without additionalLibraries', () {
        barbackSettingsMock.when(callsTo('get configuration')).alwaysReturn({'additionalLibraries': null});
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


const SYSTEM_WITHOUT_INITIALIZE_WITH_MAPPER = '''
class SimpleSystem extends VoidEntitySystem {
  Mapper<Position> pm;
}
''';

const SYSTEM_WITHOUT_INITIALIZE_WITH_MAPPER_RESULT = '''
class SimpleSystem extends VoidEntitySystem {
  Mapper<Position> pm;
  @override
  void initialize() {
    super.initialize();
    pm = new Mapper<Position>(Position, world);
  }
}
''';

const SYSTEM_WITHOUT_INITIALIZE_WITH_MANAGER = '''
class SimpleSystem extends VoidEntitySystem {
  SimpleManager sm;
}
class SimpleManager extends Manager {
}
''';

const SYSTEM_WITHOUT_INITIALIZE_WITH_MANAGER_RESULT = '''
class SimpleSystem extends VoidEntitySystem {
  SimpleManager sm;
  @override
  void initialize() {
    super.initialize();
    sm = world.getManager(SimpleManager);
  }
}
class SimpleManager extends Manager {
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
  @override
  void initialize() {
    super.initialize();
    pm = new Mapper<Position>(Position, world);
  }
}
''';

const SYSTEM_WITHOUT_INITIALIZE_WITH_OTHER_SYSTEM = '''
class SimpleSystem extends VoidEntitySystem {
  OtherSystem om;
}
class OtherSystem extends EntitySystem {
}
''';

const SYSTEM_WITHOUT_INITIALIZE_WITH_OTHER_SYSTEM_RESULT = '''
class SimpleSystem extends VoidEntitySystem {
  OtherSystem om;
  @override
  void initialize() {
    super.initialize();
    om = world.getSystem(OtherSystem);
  }
}
class OtherSystem extends EntitySystem {
}
''';

const SYSTEM_WITH_INITIALIZE_WITH_MAPPER = '''
class SimpleSystem extends VoidEntitySystem {
  Mapper<Position> pm;
  @override
  void initialize() {}
}
''';

const SYSTEM_WITH_INITIALIZE_WITH_MAPPER_RESULT = '''
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

const SYSTEM_WITH_CLASSES_FROM_OTHER_LIBRARY = '''
class SimpleSystem extends EntitySystem {
  SimpleManager sm;
  OtherSystem os;
}
''';

const SYSTEM_WITH_CLASSES_FROM_OTHER_LIBRARY_RESULT = '''
class SimpleSystem extends EntitySystem {
  SimpleManager sm;
  OtherSystem os;
  @override
  void initialize() {
    super.initialize();
    os = world.getSystem(OtherSystem);
    sm = world.getManager(SimpleManager);
  }
}
''';

const OTHER_LIBRARY = '''
  library otherLib;

  part 'src/manager.dart';

  class OtherSystem extends EntitySystem {}
''';

const OTHER_LIBRARY_MANAGER = '''
  part of otherLib;

  class SimpleManager extends Manager {}
''';

const EVERYTHING_COMBINED = '''
class SimpleManager extends Manager {
  OtherManager om;
  SimpleSystem ss;
}
class OtherManager extends Manager {
  Mapper<Position> pm;
}
class SimpleSystem extends EntitySystem {
  SimpleManager sm;
  Mapper<Position> pm;
}
class OtherSystem extends VoidEntitySystem {
}
''';

const EVERYTHING_COMBINED_RESULT = '''
class SimpleManager extends Manager {
  OtherManager om;
  SimpleSystem ss;
  @override
  void initialize() {
    super.initialize();
    ss = world.getSystem(SimpleSystem);
    om = world.getManager(OtherManager);
  }
}
class OtherManager extends Manager {
  Mapper<Position> pm;
  @override
  void initialize() {
    super.initialize();
    pm = new Mapper<Position>(Position, world);
  }
}
class SimpleSystem extends EntitySystem {
  SimpleManager sm;
  Mapper<Position> pm;
  @override
  void initialize() {
    super.initialize();
    sm = world.getManager(SimpleManager);
    pm = new Mapper<Position>(Position, world);
  }
}
class OtherSystem extends VoidEntitySystem {
}
''';

class AggregateTransformMock extends Mock implements AggregateTransform {}
class AssetMock extends Mock implements Asset {}
class BarbackSettingsMock extends Mock implements BarbackSettings {}
