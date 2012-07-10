/**
 * High performance component retrieval from entities. Use this wherever you need
 * to retrieve components from entities often and fast.
 *
 * @author Arni Arent
 *
 * @param <T>
 */
class ComponentMapper {
  ComponentType _type;
  EntityManager _em;
  Type _classType;

  ComponentMapper(this._classType, World world) {
    this._em = world.entityManager;
    this._type = ComponentTypeManager.getTypeFor(_classType);
  }

  Component getComponent(Entity e) {
    return _em._getComponent(e, _type);
  }

}
