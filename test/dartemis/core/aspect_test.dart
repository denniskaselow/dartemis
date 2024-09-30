import 'package:dartemis/dartemis.dart';
import 'package:test/test.dart';

import 'components_setup.dart';

void main() {
  group('Aspect Tests', () {
    test('getAspectForAll with one component', () {
      final aspect = Aspect.forAllOf([PooledComponent2]);
      expect(aspect.all, contains(PooledComponent2));
      expect(aspect.all, hasLength(1));
      expect(aspect.excluded, isEmpty);
      expect(aspect.one, isEmpty);
    });
    test('getAspectForAll with all components', () {
      final aspect =
          Aspect.forAllOf([Component0, Component1, PooledComponent2]);
      expect(
        aspect.all,
        containsAll([Component0, Component1, PooledComponent2]),
      );
      expect(aspect.excluded, isEmpty);
      expect(aspect.one, isEmpty);
    });
    test('getAspectForAll with one component, excluding another one', () {
      final aspect = Aspect.forAllOf([PooledComponent2])..exclude([Component0]);
      expect(aspect.all, containsAll([PooledComponent2]));
      expect(aspect.excluded, containsAll([Component0]));
      expect(aspect.one, isEmpty);
    });
    test('getAspectForAll with one component, excluding another two', () {
      final aspect = Aspect.forAllOf([PooledComponent2])
        ..exclude([Component0, Component1]);
      expect(aspect.all, containsAll([PooledComponent2]));
      expect(aspect.excluded, containsAll([Component0, Component1]));
      expect(aspect.one, isEmpty);
    });
    test('getAspectForAll with one component, and one of two', () {
      final aspect = Aspect.forAllOf([PooledComponent2])
        ..oneOf([Component0, Component1]);
      expect(aspect.all, containsAll([PooledComponent2]));
      expect(aspect.excluded, isEmpty);
      expect(aspect.one, containsAll([Component0, Component1]));
    });
    test('getAspectForOne with all components', () {
      final aspect =
          Aspect.forOneOf([Component0, Component1, PooledComponent2]);
      expect(aspect.all, isEmpty);
      expect(aspect.excluded, isEmpty);
      expect(
        aspect.one,
        containsAll([Component0, Component1, PooledComponent2]),
      );
    });
    test('getAspectForOne with chaining each component', () {
      final aspect = Aspect.forOneOf([Component0])
        ..oneOf([Component1])
        ..oneOf([PooledComponent2]);
      expect(aspect.all, isEmpty);
      expect(aspect.excluded, isEmpty);
      expect(
        aspect.one,
        containsAll([Component0, Component1, PooledComponent2]),
      );
    });
    test('getEmpty()', () {
      final aspect = Aspect.empty();
      expect(aspect.all, isEmpty);
      expect(aspect.excluded, isEmpty);
      expect(aspect.one, isEmpty);
    });
  });
}
