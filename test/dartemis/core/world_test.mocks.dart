// Mocks generated by Mockito 5.3.0 from annotations
// in dartemis/test/dartemis/core/world_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dartemis/dartemis.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeWorld_0 extends _i1.SmartFake implements _i2.World {
  _FakeWorld_0(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

/// A class which mocks [EntitySystem].
///
/// See the documentation for Mockito's code generation for more information.
class MockEntitySystem2 extends _i1.Mock implements _i2.EntitySystem {
  @override
  bool get passive => (super.noSuchMethod(Invocation.getter(#passive),
      returnValue: false, returnValueForMissingStub: false) as bool);
  @override
  int get group => (super.noSuchMethod(Invocation.getter(#group),
      returnValue: 0, returnValueForMissingStub: 0) as int);
  @override
  _i2.World get world => (super.noSuchMethod(Invocation.getter(#world),
      returnValue: _FakeWorld_0(this, Invocation.getter(#world)),
      returnValueForMissingStub:
          _FakeWorld_0(this, Invocation.getter(#world))) as _i2.World);
  @override
  int get frame => (super.noSuchMethod(Invocation.getter(#frame),
      returnValue: 0, returnValueForMissingStub: 0) as int);
  @override
  double get time => (super.noSuchMethod(Invocation.getter(#time),
      returnValue: 0.0, returnValueForMissingStub: 0.0) as double);
  @override
  void begin() => super.noSuchMethod(Invocation.method(#begin, []),
      returnValueForMissingStub: null);
  @override
  void process() => super.noSuchMethod(Invocation.method(#process, []),
      returnValueForMissingStub: null);
  @override
  void end() => super.noSuchMethod(Invocation.method(#end, []),
      returnValueForMissingStub: null);
  @override
  void processEntities(Iterable<int>? entities) =>
      super.noSuchMethod(Invocation.method(#processEntities, [entities]),
          returnValueForMissingStub: null);
  @override
  bool checkProcessing() =>
      (super.noSuchMethod(Invocation.method(#checkProcessing, []),
          returnValue: false, returnValueForMissingStub: false) as bool);
  @override
  void initialize() => super.noSuchMethod(Invocation.method(#initialize, []),
      returnValueForMissingStub: null);
  @override
  void destroy() => super.noSuchMethod(Invocation.method(#destroy, []),
      returnValueForMissingStub: null);
  @override
  void addComponent<T extends _i2.Component>(int? entity, T? component) =>
      super.noSuchMethod(Invocation.method(#addComponent, [entity, component]),
          returnValueForMissingStub: null);
  @override
  void removeComponent<T extends _i2.Component>(int? entity) =>
      super.noSuchMethod(Invocation.method(#removeComponent, [entity]),
          returnValueForMissingStub: null);
  @override
  void deleteFromWorld(int? entity) =>
      super.noSuchMethod(Invocation.method(#deleteFromWorld, [entity]),
          returnValueForMissingStub: null);
}

/// A class which mocks [EntitySystem].
///
/// See the documentation for Mockito's code generation for more information.
class MockEntitySystem extends _i1.Mock implements _i2.EntitySystem {
  @override
  bool get passive => (super.noSuchMethod(Invocation.getter(#passive),
      returnValue: false, returnValueForMissingStub: false) as bool);
  @override
  int get group => (super.noSuchMethod(Invocation.getter(#group),
      returnValue: 0, returnValueForMissingStub: 0) as int);
  @override
  _i2.World get world => (super.noSuchMethod(Invocation.getter(#world),
      returnValue: _FakeWorld_0(this, Invocation.getter(#world)),
      returnValueForMissingStub:
          _FakeWorld_0(this, Invocation.getter(#world))) as _i2.World);
  @override
  int get frame => (super.noSuchMethod(Invocation.getter(#frame),
      returnValue: 0, returnValueForMissingStub: 0) as int);
  @override
  double get time => (super.noSuchMethod(Invocation.getter(#time),
      returnValue: 0.0, returnValueForMissingStub: 0.0) as double);
  @override
  void begin() => super.noSuchMethod(Invocation.method(#begin, []),
      returnValueForMissingStub: null);
  @override
  void process() => super.noSuchMethod(Invocation.method(#process, []),
      returnValueForMissingStub: null);
  @override
  void end() => super.noSuchMethod(Invocation.method(#end, []),
      returnValueForMissingStub: null);
  @override
  void processEntities(Iterable<int>? entities) =>
      super.noSuchMethod(Invocation.method(#processEntities, [entities]),
          returnValueForMissingStub: null);
  @override
  bool checkProcessing() =>
      (super.noSuchMethod(Invocation.method(#checkProcessing, []),
          returnValue: false, returnValueForMissingStub: false) as bool);
  @override
  void initialize() => super.noSuchMethod(Invocation.method(#initialize, []),
      returnValueForMissingStub: null);
  @override
  void destroy() => super.noSuchMethod(Invocation.method(#destroy, []),
      returnValueForMissingStub: null);
  @override
  void addComponent<T extends _i2.Component>(int? entity, T? component) =>
      super.noSuchMethod(Invocation.method(#addComponent, [entity, component]),
          returnValueForMissingStub: null);
  @override
  void removeComponent<T extends _i2.Component>(int? entity) =>
      super.noSuchMethod(Invocation.method(#removeComponent, [entity]),
          returnValueForMissingStub: null);
  @override
  void deleteFromWorld(int? entity) =>
      super.noSuchMethod(Invocation.method(#deleteFromWorld, [entity]),
          returnValueForMissingStub: null);
}

/// A class which mocks [ComponentManager].
///
/// See the documentation for Mockito's code generation for more information.
class MockComponentManager extends _i1.Mock implements _i2.ComponentManager {
  @override
  _i2.World get world => (super.noSuchMethod(Invocation.getter(#world),
      returnValue: _FakeWorld_0(this, Invocation.getter(#world)),
      returnValueForMissingStub:
          _FakeWorld_0(this, Invocation.getter(#world))) as _i2.World);
  @override
  void initialize() => super.noSuchMethod(Invocation.method(#initialize, []),
      returnValueForMissingStub: null);
  @override
  List<T> getComponentsByType<T extends _i2.Component>(
          _i2.ComponentType? type) =>
      (super.noSuchMethod(Invocation.method(#getComponentsByType, [type]),
          returnValue: <T>[], returnValueForMissingStub: <T>[]) as List<T>);
  @override
  List<_i2.Component> getComponentsFor(int? entity) =>
      (super.noSuchMethod(Invocation.method(#getComponentsFor, [entity]),
          returnValue: <_i2.Component>[],
          returnValueForMissingStub: <_i2.Component>[]) as List<_i2.Component>);
  @override
  bool isUpdateNeededForSystem(_i2.EntitySystem? system) =>
      (super.noSuchMethod(Invocation.method(#isUpdateNeededForSystem, [system]),
          returnValue: false, returnValueForMissingStub: false) as bool);
  @override
  void added(int? entity) =>
      super.noSuchMethod(Invocation.method(#added, [entity]),
          returnValueForMissingStub: null);
  @override
  void deleted(int? entity) =>
      super.noSuchMethod(Invocation.method(#deleted, [entity]),
          returnValueForMissingStub: null);
  @override
  void destroy() => super.noSuchMethod(Invocation.method(#destroy, []),
      returnValueForMissingStub: null);
}

/// A class which mocks [Manager].
///
/// See the documentation for Mockito's code generation for more information.
class MockManager extends _i1.Mock implements _i2.Manager {
  @override
  _i2.World get world => (super.noSuchMethod(Invocation.getter(#world),
      returnValue: _FakeWorld_0(this, Invocation.getter(#world)),
      returnValueForMissingStub:
          _FakeWorld_0(this, Invocation.getter(#world))) as _i2.World);
  @override
  void initialize() => super.noSuchMethod(Invocation.method(#initialize, []),
      returnValueForMissingStub: null);
  @override
  void added(int? entity) =>
      super.noSuchMethod(Invocation.method(#added, [entity]),
          returnValueForMissingStub: null);
  @override
  void deleted(int? entity) =>
      super.noSuchMethod(Invocation.method(#deleted, [entity]),
          returnValueForMissingStub: null);
  @override
  void destroy() => super.noSuchMethod(Invocation.method(#destroy, []),
      returnValueForMissingStub: null);
}
