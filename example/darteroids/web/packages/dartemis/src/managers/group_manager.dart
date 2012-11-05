part of dartemis;

/**
 * If you need to group your entities together, e.g. tanks going into "units" group or explosions into "effects",
 * then use this manager. You must retrieve it using world instance.
 *
 * An [Entity] can only belong to one group at a time.
 */
class GroupManager extends Manager {
  final Map<String, Bag<Entity>> _entitiesByGroup;
  final Map<Entity, Bag<String>> _groupsByEntity;

  GroupManager() : _entitiesByGroup = new Map<String, Bag<Entity>>(),
                   _groupsByEntity = new Map<Entity, Bag<String>>();

  void initialize() {}



  /**
   * Set the group of the entity.
   */
  void add(Entity e, String group) {
    Bag<Entity> entities = _entitiesByGroup[group];
    if (entities == null) {
      entities = new Bag<Entity>();
      _entitiesByGroup[group] = entities;
    }
    entities.add(e);

    Bag<String> groups = _groupsByEntity[e];
    if(groups == null) {
      groups = new Bag<String>();
      _groupsByEntity[e] = groups;
    }
    groups.add(group);
  }

  /**
   * Remove the entity from the specified group.
   */
  void remove(Entity e, String group) {
    Bag<Entity> entities = _entitiesByGroup[group];
    if(entities != null) {
      entities.remove(e);
    }

    Bag<String> groups = _groupsByEntity[e];
    if(groups != null) {
      groups.remove(group);
    }
  }

  void removeFromAllGroups(Entity e) {
    Bag<String> groups = _groupsByEntity[e];
    if(groups != null) {
      groups.forEach((group) {
        Bag<Entity> entities = _entitiesByGroup[group];
        if(entities != null) {
          entities.remove(e);
        }
      });
      groups.clear();
    }
  }

  /**
   * Get all entities that belong to the provided group.
   */
  ImmutableBag<Entity> getEntities(String group) {
    Bag<Entity> entities = _entitiesByGroup[group];
    if(entities == null) {
      entities = new Bag<Entity>();
      _entitiesByGroup[group] = entities;
    }
    return entities;
  }

  /**
   * Returns the groups the entity belongs to, null if none.
   */
  ImmutableBag<String> getGroups(Entity e) {
    return _groupsByEntity[e];
  }

  /**
   * Checks if the entity belongs to any group.
   */
  bool isInAnyGroup(Entity e) {
    return getGroups(e) != null;
  }

  /**
   * Check if the entity is in the supplied group.
   */
  bool inInGroup(Entity e, String group) {
    Bag<String> groups = _groupsByEntity[e];
    return groups.contains(group);
  }

  void deleted(Entity e) {
    removeFromAllGroups(e);
  }

}
