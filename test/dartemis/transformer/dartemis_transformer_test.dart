library dartemis_transformer_test;

import "dart:async";

import "package:unittest/unittest.dart";
import "package:mockito/mockito.dart";
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

      when(transformMock.primaryInputs).thenReturn(new Stream.fromIterable([assetMock]));
    });

    group('initializes Manager from other Library in', () {

      test('system without initialize', () {
        AssetMock assetOtherLibraryMock = new AssetMock();
        AssetMock assetPartOfOtherLibraryMock = new AssetMock();

        when(transformMock.getInput(new AssetId.parse('otherLib|lib/otherLib.dart'))).thenReturn(new Future.value(assetOtherLibraryMock));
        when(transformMock.getInput(new AssetId.parse('otherLib|lib/src/manager.dart'))).thenReturn(new Future.value(assetPartOfOtherLibraryMock));
        when(assetMock.readAsString()).thenReturn(new Future.value(SYSTEM_WITH_CLASSES_FROM_OTHER_LIBRARY));
        when(assetOtherLibraryMock.readAsString()).thenReturn(new Future.value(OTHER_LIBRARY));
        when(assetPartOfOtherLibraryMock.readAsString()).thenReturn(new Future.value(OTHER_LIBRARY_MANAGER));
        when(barbackSettingsMock.configuration).thenReturn({'additionalLibraries': ['otherLib/otherLib.dart']});

        transformer.apply(transformMock).then(expectAsync((_) {
          verify(transformMock.addOutput(captureAny)).captured.single.readAsString().then(expectAsync((content) {
            expect(content, equals(SYSTEM_WITH_CLASSES_FROM_OTHER_LIBRARY_RESULT));
          }));
        }));
      });
    });

    group('initializes everything in', () {

      test('managers and sytems', () {
        when(assetMock.readAsString()).thenReturn(new Future.value(EVERYTHING_COMBINED));

        transformer.apply(transformMock).then(expectAsync((_) {
          verify(transformMock.addOutput(captureAny)).captured.single.readAsString().then(expectAsync((content) {
            expect(content, equals(EVERYTHING_COMBINED_RESULT));
          }));
        }));
      });
    });

    group('doesn\'t crash', () {
      test('for system with dynamic fields', () {
        when(assetMock.readAsString()).thenReturn(new Future.value(SYSTEM_WITH_DYNAMIC_FIELD));

        transformer.apply(transformMock).then(expectAsync((_) {
          verifyNever(transformMock.addOutput(captureAny));
        }));
      });

      test('for classes without superclass', () {
        when(assetMock.readAsString()).thenReturn(new Future.value(CLASS_WITHOUT_SUPERCLASS));

        transformer.apply(transformMock).then(expectAsync((_) {
          verifyNever(transformMock.addOutput(captureAny));
        }));
      });

      test('for BarbackSetting without additionalLibraries', () {
        when(barbackSettingsMock.configuration).thenReturn({'additionalLibraries': null});
        when(assetMock.readAsString()).thenReturn(new Future.value(CLASS_WITHOUT_SUPERCLASS));

        transformer.apply(transformMock).then(expectAsync((_) {
          verifyNever(transformMock.addOutput(captureAny));
        }));
      });
    });

    group('doesn\'t create instance', () {
      test('in unrelated classes', () {
        when(assetMock.readAsString()).thenReturn(new Future.value(SOME_OTHER_CLASS_WITH_MAPPER));

        transformer.apply(transformMock).then(expectAsync((_) {
          verifyNever(transformMock.addOutput(captureAny));
        }));
      });
    });
  });
}


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
  @override void initialize() {
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
  @override void initialize() {
    super.initialize();
    ss = world.getSystem(SimpleSystem);
    om = world.getManager(OtherManager);
  }
}
class OtherManager extends Manager {
  Mapper<Position> pm;
  @override void initialize() {
    super.initialize();
    pm = new Mapper<Position>(Position, world);
  }
}
class SimpleSystem extends EntitySystem {
  SimpleManager sm;
  Mapper<Position> pm;
  @override void initialize() {
    super.initialize();
    pm = new Mapper<Position>(Position, world);
    sm = world.getManager(SimpleManager);
  }
}
class OtherSystem extends VoidEntitySystem {}
''';

class AggregateTransformMock extends Mock implements AggregateTransform {}
class AssetMock extends Mock implements Asset {}
class BarbackSettingsMock extends Mock implements BarbackSettings {}
