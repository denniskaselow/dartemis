part of dartemis;

/**
 * All components extend from this class.
 *
 * If you want to use a poolable component that will be added to a FreeList when
 * it is being removed use [FreeListComponent] instead.
 */
abstract class Component {
  /// Does nothing in [Component], only relevant for [FreeListComponent].
  void _removed(int typeId) {}
}

/**
 * All components that should be managed in a FreeList must extend this class
 * and have a factory constructor that calls the factory constructor of this
 * class. By doing so, dartemis can handle the construction of
 * [FreeListComponent]s and reuse them when they are no longer needed.
 */
abstract class FreeListComponent extends Component {

  FreeListComponent();
  /**
   * Creates a new [FreeListComponent] of [Type] [componentType].
   *
   * The instance created with [componentConstructor] should be created with
   * a zero-argument contructor because it will only be called once. All fields
   * of the created component should be set in the calling factory constructor.
   */
  factory FreeListComponent.of(Type componentType, ComponentConstructor componentConstructor) {
    return FreeComponents._getComponent(componentType, componentConstructor);
  }

  _removed(int typeId) {
    cleanUp();
    FreeComponents._add(this, typeId);
  }

  /**
   * If you need to do some cleanup when removing this component override this
   * method.
   */
  void cleanUp() {}
}