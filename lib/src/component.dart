part of dartemis;

/**
 * A tag class. All components in the system must implement this class and have
 * a factory constructor that calls the factory constructor [Component] of this
 * class. By doing so, dartemis can handle the construction of [Component]s and
 * reuse them when they are no longer needed.
 */
abstract class Component {
  factory Component(Type componentType, ComponentConstructor componentConstructor) {
    return FreeComponents._getComponent(componentType, componentConstructor);
  }
}