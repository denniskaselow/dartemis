/**
 * High performance component retrieval from entities. Use this wherever you need
 * to retrieve components from entities often and fast.
 *
 * @author Arni Arent
 */
class ComponentMapper {
  ComponentType _type;
  EntityManager _em;
  String _componentName;

  ComponentMapper(this._componentName, World world) {
    this._em = world.entityManager;
    this._type = ComponentTypeManager.getTypeFor(_componentName);
  }

  Component getComponent(Entity e) {
    return _em._getComponent(e, _type);
  }

}
