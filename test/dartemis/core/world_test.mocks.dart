import 'package:mockito/mockito.dart' as _i1;
import 'package:dartemis/dartemis.dart' as _i2;

// ignore_for_file: unnecessary_parenthesis

class _FakeWorld extends _i1.Fake implements _i2.World {}

/// A class which mocks [EntitySystem].
///
/// See the documentation for Mockito's code generation for more information.
class MockEntitySystem2 extends _i1.Mock implements _i2.EntitySystem {
  bool get passive => super.noSuchMethod(Invocation.getter(#passive), false);
  int get group => super.noSuchMethod(Invocation.getter(#group), 0);
  _i2.World get world =>
      super.noSuchMethod(Invocation.getter(#world), _FakeWorld());
  int get frame => super.noSuchMethod(Invocation.getter(#frame), 0);
  double get time => super.noSuchMethod(Invocation.getter(#time), 0.0);
  @override
  void processEntities(Iterable<int>? entities) =>
      super.noSuchMethod(Invocation.method(#processEntities, [entities]));
  @override
  bool checkProcessing() =>
      (super.noSuchMethod(Invocation.method(#checkProcessing, []), false)
          as bool);
  @override
  void addComponent<T extends _i2.Component>(int? entity, T? component) =>
      super.noSuchMethod(Invocation.method(#addComponent, [entity, component]));
  @override
  void removeComponent<T extends _i2.Component>(int? entity) =>
      super.noSuchMethod(Invocation.method(#removeComponent, [entity]));
  @override
  void deleteFromWorld(int? entity) =>
      super.noSuchMethod(Invocation.method(#deleteFromWorld, [entity]));
}

/// A class which mocks [EntitySystem].
///
/// See the documentation for Mockito's code generation for more information.
class MockEntitySystem extends _i1.Mock implements _i2.EntitySystem {
  bool get passive => super.noSuchMethod(Invocation.getter(#passive), false);
  int get group => super.noSuchMethod(Invocation.getter(#group), 0);
  _i2.World get world =>
      super.noSuchMethod(Invocation.getter(#world), _FakeWorld());
  int get frame => super.noSuchMethod(Invocation.getter(#frame), 0);
  double get time => super.noSuchMethod(Invocation.getter(#time), 0.0);
  @override
  void processEntities(Iterable<int>? entities) =>
      super.noSuchMethod(Invocation.method(#processEntities, [entities]));
  @override
  bool checkProcessing() =>
      (super.noSuchMethod(Invocation.method(#checkProcessing, []), false)
          as bool);
  @override
  void addComponent<T extends _i2.Component>(int? entity, T? component) =>
      super.noSuchMethod(Invocation.method(#addComponent, [entity, component]));
  @override
  void removeComponent<T extends _i2.Component>(int? entity) =>
      super.noSuchMethod(Invocation.method(#removeComponent, [entity]));
  @override
  void deleteFromWorld(int? entity) =>
      super.noSuchMethod(Invocation.method(#deleteFromWorld, [entity]));
}

/// A class which mocks [ComponentManager].
///
/// See the documentation for Mockito's code generation for more information.
class MockComponentManager extends _i1.Mock implements _i2.ComponentManager {
  _i2.World get world =>
      super.noSuchMethod(Invocation.getter(#world), _FakeWorld());
  @override
  List<T> getComponentsByType<T extends _i2.Component>(
          _i2.ComponentType? type) =>
      (super.noSuchMethod(
          Invocation.method(#getComponentsByType, [type]), <T>[]) as List<T>);
  @override
  List<_i2.Component> getComponentsFor(int? entity) => (super.noSuchMethod(
          Invocation.method(#getComponentsFor, [entity]), <_i2.Component>[])
      as List<_i2.Component>);
  @override
  bool isUpdateNeededForSystem(_i2.EntitySystem? system) => (super.noSuchMethod(
      Invocation.method(#isUpdateNeededForSystem, [system]), false) as bool);
  @override
  void added(int? entity) =>
      super.noSuchMethod(Invocation.method(#added, [entity]));
  @override
  void deleted(int? entity) =>
      super.noSuchMethod(Invocation.method(#deleted, [entity]));
}

/// A class which mocks [Manager].
///
/// See the documentation for Mockito's code generation for more information.
class MockManager extends _i1.Mock implements _i2.Manager {
  _i2.World get world =>
      super.noSuchMethod(Invocation.getter(#world), _FakeWorld());
  @override
  void added(int? entity) =>
      super.noSuchMethod(Invocation.method(#added, [entity]));
  @override
  void deleted(int? entity) =>
      super.noSuchMethod(Invocation.method(#deleted, [entity]));
}
