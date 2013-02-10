part of dartemis;

/**
 * A tag class. All components in the system must extend this class.
 */
abstract class Component {
  factory Component(World world, Type componentType, ComponentConstructor componentConstructor) {
    return world.createComponent(componentType, componentConstructor);
  }
}