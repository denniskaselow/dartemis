part of dartemis;

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
  int _all = 0;
  int _excluded = 0;
  int _one = 0;

  /// Creates an aspect where an entity must possess all of the specified
  /// components.
  Aspect.forAllOf(List<Type> componentTypes) {
    allOf(componentTypes);
  }

  /// Creates an aspect where an entity must possess one of the specified
  /// componens.
  Aspect.forOneOf(List<Type> componentTypes) {
    oneOf(componentTypes);
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
  void allOf(List<Type> componentTypes) {
    _all = _updateBitMask(_all, componentTypes);
  }

  /// Excludes all of the specified components from the aspect. A system will
  /// not be interested in an entity that possesses one of the specified
  /// excluded components.
  void exclude(List<Type> componentTypes) {
    _excluded = _updateBitMask(_excluded, componentTypes);
  }

  /// Modifies the aspect in a way that an entity must possess one of the
  /// specified components.
  void oneOf(List<Type> componentTypes) {
    _one = _updateBitMask(_one, componentTypes);
  }

  int get all => _all;
  int get excluded => _excluded;
  int get one => _one;

  int _updateBitMask(int mask, List<Type> componentTypes) {
    var result = mask;
    if (null != componentTypes) {
      componentTypes.forEach((componentType) {
        result |= ComponentTypeManager.getBit(componentType);
      });
    }
    return result;
  }
}
