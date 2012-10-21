part of dartemis;

/**
 * High performance component retrieval from entities. Use this wherever you need
 * to retrieve components from entities often and fast.
 *
 * @author Arni Arent
 */
class ComponentMapper<A extends Component> {
  ComponentType _type;
  Bag<A> _components;

  ComponentMapper(Type componentType, World world) {
    this._type = ComponentTypeManager.getTypeFor(componentType);
    _components = world.componentManager.getComponentsByType(this._type);
  }

  /**
   * Fast but unsafe retrieval of a component for this entity.
   * No bounding checks, so this could throw an ArrayIndexOutOfBoundsExeption,
   * however in most scenarios you already know the entity possesses this component.
   */
  A get(Entity e) {
    return _components[e.id];
  }

  /**
   * Fast and safe retrieval of a component for this entity.
   * If the entity does not have this component then null is returned.
   */
  A getSafe(Entity e) {
    if(_components.isIndexWithinBounds(e.id)) {
      return _components[e.id];
    }
    return null;
  }

  /**
   * Checks if the entity has this type of component.
   */
  bool has(Entity e) {
    return getSafe(e) != null;
  }

}
