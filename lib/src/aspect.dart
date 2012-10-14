part of dartemis;

/**
 * An Aspect is used by systems as a matcher against entities, to check if a system is
 * interested in an entity. Aspects define what sort of component types an entity must
 * possess, or not possess.
 *
 * This creates an aspect where an entity must possess A and B and C:
 *     Aspect.getAspectForAllOf("A", "B", "C")
 *
 * This creates an aspect where an entity must possess A and B and C, but must not possess U or V.
 *     Aspect.getAspectForAllOf("A", "B", "C").exclude("U", "V")
 *
 * This creates an aspect where an entity must possess A and B and C, but must not possess U or V, but must possess one of X or Y or Z.
 *     Aspect.getAspectForAllOf("A", "B", "C").exclude("U", "V").oneOf("X", "Y", "Z")
 *
 * You can create and compose aspects in many ways:
 *     Aspect.getEmpty().oneOf("X", "Y", "Z").allOf("A", "B", "C").exclude("U", "V")
 * is the same as:
 *     Aspect.getAspectForAllOf("A", "B", "C").exclude("U", "V").oneOf("X", "Y", "Z")
 *
 * The name of the component must alsways be the same as the name of the [Component] class.
 *
 * @author Arni Arent
 *
 */
class Aspect {

  int _all = 0;
  int _excluded = 0;
  int _one = 0;

  /**
   * Returns an aspect where an entity must possess all of the specified components.
   */
  Aspect allOf(String requiredComponentName, [List<String> componentNames]) {
    _all = _updateBitMask(_all, requiredComponentName, componentNames);
    return this;
  }

  /**
   * Excludes all of the specified components from the aspect. A system will not be
   * interested in an entity that possesses one of the specified excluded components.
   *
   * Returns an aspect that can be matched against entities.
   */
  Aspect exclude(String requiredComponentName, [List<String> componentNames]) {
    _excluded = _updateBitMask(_excluded, requiredComponentName, componentNames);
    return this;
  }

  /**
   * Returns an aspect where an entity must possess one of the specified components.
   */
  Aspect oneOf(String requiredComponentName, [List<String> componentNames]) {
    _one = _updateBitMask(_one, requiredComponentName, componentNames);
    return this;
  }

  /**
   * Creates an aspect where an entity must possess all of the specified components.
   */
  static Aspect getAspectForAllOf(String requiredComponentName, [List<String> componentNames]) {
    Aspect aspect = new Aspect();
    aspect.allOf(requiredComponentName, componentNames);
    return aspect;
  }

  /**
   * Creates an aspect where an entity must possess one of the specified componens.
   */
  static getAspectForOneOf(String requiredComponentName, [List<String> componentNames]) {
    Aspect aspect = new Aspect();
    aspect.oneOf(requiredComponentName, componentNames);
    return aspect;
  }

  /**
   * Creates and returns an empty aspect. This can be used if you want a system that processes no entities, but
   * still gets invoked. Typical usages is when you need to create special purpose systems for debug rendering,
   * like rendering FPS, how many entities are active in the world, etc.
   *
   * You can also use the all, one and exclude methods on this aspect, so if you wanted to create a system that
   * processes only entities possessing just one of the components A or B or C, then you can do:
   * Aspect.getEmpty().one("A", "B", "C");
   *
   * Returns an empty Aspect that will reject all entities.
   */
  static Aspect getEmpty() {
    return new Aspect();
  }

  int get all => _all;
  int get excluded => _excluded;
  int get one => _one;

  int _updateBitMask(int mask, String requiredComponentName, [List<String> componentNames]) {
    mask = mask | ComponentTypeManager.getBit(requiredComponentName);
    if (null != componentNames) {
      for (String componentName in componentNames) {
        mask = mask | ComponentTypeManager.getBit(componentName);
      }
    }
    return mask;
  }

}