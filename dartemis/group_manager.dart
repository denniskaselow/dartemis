/**
 * If you need to group your entities together, e.g. tanks going into "units" group or explosions into "effects",
 * then use this manager. You must retrieve it using _world instance.
 *
 * A entity can only belong to one group at a time.
 *
 * @author Arni Arent
 *
 */
class GroupManager {
  World _world;
  var _EMPTY_BAG;
  var _entitiesByGroup;
  var _groupByEntity;

  GroupManager(this._world) {
    _entitiesByGroup = new Map<String, Bag<Entity>>();
    _groupByEntity = new Bag<String>();
    _EMPTY_BAG = new Bag<Entity>();
  }

  /**
   * Set the group of the entity.
   *
   * @param group group to set the entity into.
   * @param e entity to set into the group.
   */
  void addEntityToGroup(String group, Entity e) {
    remove(e); // Entity can only belong to one group.

    Bag<Entity> entities = _entitiesByGroup[group];
    if(entities == null) {
      entities = new Bag<Entity>();
      _entitiesByGroup[group] = entities;
    }
    entities.add(e);

    _groupByEntity[e.id] = group;
  }

  /**
   * Get all entities that belong to the provided group.
   * @param group name of the group.
   * @return read-only bag of entities belonging to the group.
   */
  ImmutableBag<Entity> getEntities(String group) {
    Bag<Entity> bag = _entitiesByGroup[group];
    if(bag == null)
      return _EMPTY_BAG;
    return bag;
  }

  /**
   * Removes the provided entity from the group it is assigned to, if any.
   * @param e the entity.
   */
  void remove(Entity e) {
    if(e.id < _groupByEntity.getCapacity()) {
      String group = _groupByEntity[e.id];
      if(group != null) {
        _groupByEntity.set(e.id, null);

        Bag<Entity> entities = _entitiesByGroup[group];
        if(entities != null) {
          entities.remove(e);
        }
      }
    }
  }

  /**
   * @param e entity
   * @return the name of the group that this entity belongs to, null if none.
   */
  String getGroupOf(Entity e) {
    if(e.id < _groupByEntity.getCapacity()) {
      return _groupByEntity[e.id];
    }
    return null;
  }

  /**
   * Checks if the entity belongs to any group.
   * @param e the entity to check.
   * @return true if it is in any group, false if none.
   */
  bool isGrouped(Entity e) {
    return getGroupOf(e) != null;
  }
}
