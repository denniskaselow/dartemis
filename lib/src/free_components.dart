part of dartemis;

/**
 * Inspired by [http://dartgamedevs.org/blog/2012/11/02/Free-Lists-For-Predictable-Game-Performance/]
 * this class stores [Component]s that are no longer used in the game for later reuse.
 */
class FreeComponents {

  static Bag<Bag<Component>> _freeLists = new Bag<Bag<Component>>();

  static Component _getComponent(Type componentType, ComponentConstructor componentConstructor) {
    Bag<Component> freeList = _getFreeList(componentType);
    var component = freeList.removeLast();
    if (null == component) {
      component = componentConstructor();
    }
    return component;
  }

  static Bag<Component> _getFreeList(Type componentType) {
    var index = ComponentTypeManager.getId(componentType);
    _freeLists._ensureCapacity(index);
    var freeList = _freeLists[index];
    if (null == freeList) {
      freeList = new Bag();
      _freeLists[index] = freeList;
    }
    return freeList;
  }

  static void _add(Component component, int typeId) {
    _freeLists[typeId].add(component);
  }

  /**
   * Add a specific [amount] of [Component]s for later reuse.
   */
  static void add(Type componentType, ComponentConstructor componentConstructor, int amount) {
    Bag<Component> freeList = _getFreeList(componentType);
    for (int i = 0; i < amount; i++) {
      freeList.add(componentConstructor());
    }
  }
}

