part of '../../dartemis.dart';

/// An Aspect is used by systems as a matcher against entities, to check if a
/// system is interested in an entity. Aspects define what sort of component
/// types an entity must possess, or not possess.
///
/// This creates an aspect where an entity must possess A and B and C:
///     Aspect.forAllOf([A, B, C])
///
/// This creates an aspect where an entity must possess A and B and C, but must
/// not possess U or V.
///     Aspect.forAllOf([A, B, C])..exclude([U, V])
///
/// This creates an aspect where an entity must possess A and B and C, but must
/// not possess U or V, but must possess one of X or Y or Z.
///     Aspect.forAllOf([A, B, C])..exclude([U, V])..oneOf([X, Y, Z])
///
/// You can create and compose aspects in many ways:
///     Aspect.empty()..oneOf([X, Y, Z])..allOf([A, B, C])..exclude([U, V])
/// is the same as:
///     Aspect.forAllOf([A, B, C])..exclude([U, V])..oneOf([X, Y, Z])
class Aspect {
  /// All components an [Entity] needs to be processed by an [EntitySystem].
  final Set<Type> all = {};

  /// An [Entity] needs one of these components to be processed by the
  /// [EntitySystem].
  final Set<Type> one = {};

  /// An [Entity] will not be processed by the [EntitySystem] if it has one of
  /// these [Component] types.
  final Set<Type> excluded = {};

  /// Creates an aspect where an entity must possess all of the specified
  /// components.
  Aspect.forAllOf(Iterable<Type> componentTypes) {
    all.addAll(componentTypes);
  }

  /// Creates an aspect where an entity must possess one of the specified
  /// components.
  Aspect.forOneOf(Iterable<Type> componentTypes) {
    one.addAll(componentTypes);
  }

  /// Creates and returns an empty aspect. This can be used if you want a system
  /// that processes no entities, but still gets invoked. Typical usages is when
  /// you need to create special purpose systems for debug rendering, like
  /// rendering FPS, how many entities are active in the world, etc.
  ///
  /// You can also use the all, one and exclude methods on this aspect, so if
  /// you wanted to create a system that processes only entities possessing just
  /// one of the components A or B or C, then you can do:
  ///     Aspect.empty()..one("A", "B", "C");
  ///
  /// Returns an empty Aspect that will reject all entities.
  Aspect.empty();

  /// Modifies the aspect in a way that an entity must possess all of the
  /// specified components.
  void allOf(Iterable<Type> componentTypes) {
    all.addAll(componentTypes);
  }

  /// Excludes all of the specified components from the aspect. A system will
  /// not be interested in an entity that possesses one of the specified
  /// excluded components.
  void exclude(Iterable<Type> componentTypes) {
    excluded.addAll(componentTypes);
  }

  /// Modifies the aspect in a way that an entity must possess one of the
  /// specified components.
  void oneOf(Iterable<Type> componentTypes) {
    one.addAll(componentTypes);
  }
}
