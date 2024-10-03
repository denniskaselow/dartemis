part of '../../dartemis.dart';

/// An Aspect is used by systems as a matcher against entities, to check if a
/// system is interested in an entity. Aspects define what sort of component
/// types an entity must possess, or not possess.
///
/// This creates an aspect where an entity must possess A and B and C:
///     Aspect(allOf: [A, B, C])
///
/// This creates an aspect where an entity must possess A and B and C, but must
/// not possess U or V.
///     Aspect(allOf: [A, B, C])..exclude([U, V])
///
/// This creates an aspect where an entity must possess A and B and C, but must
/// not possess U or V, but must possess one of X or Y or Z.
///     Aspect(allOf: [A, B, C])..exclude([U, V])..oneOf([X, Y, Z])
///
/// You can create and compose aspects in many ways:
///     Aspect.empty()..oneOf([X, Y, Z])..allOf([A, B, C])..exclude([U, V])
/// is the same as:
///     Aspect(allOf: [A, B, C])..exclude([U, V])..oneOf([X, Y, Z])
class Aspect {
  /// All components an [Entity] needs to be processed by an [EntitySystem].
  final Set<Type> all = {};

  /// An [Entity] needs one of these components to be processed by the
  /// [EntitySystem].
  final Set<Type> one = {};

  /// An [Entity] will not be processed by the [EntitySystem] if it has one of
  /// these [Component] types.
  final Set<Type> excluded = {};

  /// Creates and returns an aspect.
  ///
  /// A system only processes an [Entity] that posses all [Component]s
  /// given by [allOf].
  ///
  /// With [oneOf] an [Entity] must posses at least one of the specified
  /// [Component]s to be processed by a system.
  ///
  /// [exclude] can be used to prevent an [Entity] to be processed when it has
  /// one of the specified [Component]s.
  ///
  /// If no arguments are passed it will be an empty aspect.
  /// This can be used if you want a system that processes no entities,
  /// but still gets invoked. Typical usages is when
  /// you need to create special purpose systems for debug rendering, like
  /// rendering FPS, how many entities are active in the world, etc.
  Aspect({
    Iterable<Type> allOf = const {},
    Iterable<Type> oneOf = const {},
    Iterable<Type> exclude = const {},
  }) {
    all.addAll(allOf);
    one.addAll(oneOf);
    excluded.addAll(exclude);
  }

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
