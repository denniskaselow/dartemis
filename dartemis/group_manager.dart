/**
 * If you need to group your entities together, e.g. tanks going into "units" group or explosions into "effects",
 * then use this manager. You must retrieve it using world instance.
 *
 * An [Entity] can only belong to one group at a time.
 *
 * @author Arni Arent
 *
 */
class GroupManager {
  final World _world;
  final _EMPTY_BAG;
  final _entitiesByGroup;
  final _groupByEntity;

  GroupManager(this._world) : _entitiesByGroup = new Map<String, Bag<Entity>>(),
                              _groupByEntity = new Bag<String>(),
                              _EMPTY_BAG = new Bag<Entity>();
  
  /**
   * Set the [group] of the [entity].
   */
  void addEntityToGroup(String group, Entity entity) {
    remove(entity); // Entity can only belong to one group.

    Bag<Entity> entities = _entitiesByGroup[group];
    if(entities == null) {
      entities = new Bag<Entity>();
      _entitiesByGroup[group] = entities;
    }
    entities.add(entity);

    _groupByEntity[entity.id] = group;
  }

  /**
   * Get all entities that belong to the provided [group].
   * 
   * Returns a read-only bag of entities belonging to the [group].
   */
  ImmutableBag<Entity> getEntities(String group) {
    Bag<Entity> bag = _entitiesByGroup[group];
    if(bag == null)
      return _EMPTY_BAG;
    return bag;
  }

  /**
   * Removes the provided [entity] from the group it is assigned to, if any.
   */
  void remove(Entity entity) {
    if(entity.id < _groupByEntity.getCapacity()) {
      String group = _groupByEntity[entity.id];
      if(group != null) {
        _groupByEntity.set(entity.id, null);

        Bag<Entity> entities = _entitiesByGroup[group];
        if(entities != null) {
          entities.remove(entity);
        }
      }
    }
  }

  /**
   * Returns the name of the group that this [entity] belongs to, [:null:] if none.
   */
  String getGroupOf(Entity entity) {
    if(entity.id < _groupByEntity.getCapacity()) {
      return _groupByEntity[entity.id];
    }
    return null;
  }

  /**
   * Checks if the [entity] belongs to any group.
   * 
   * Returns [:true:] if it is in any group, [:false:] if none.
   */
  bool isGrouped(Entity entity) {
    return getGroupOf(entity) != null;
  }
}
