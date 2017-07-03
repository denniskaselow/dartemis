part of dartemis;

/// If you need to group your entities together, e.g. tanks going into "units"
/// group or explosions into "effects", then use this manager. You must retrieve
/// it using world instance.
///
/// An [Entity] can only belong to several groups (0,n) at a time.
class GroupManager extends Manager {
  final Map<String, Bag<Entity>> _entitiesByGroup;
  final Map<Entity, Bag<String>> _groupsByEntity;

  GroupManager()
      : _entitiesByGroup = <String, Bag<Entity>>{},
        _groupsByEntity = <Entity, Bag<String>>{};

  /// Set the group of the entity.
  void add(Entity entity, String group) {
    Bag<Entity> entities = _entitiesByGroup[group];
    if (entities == null) {
      entities = new Bag<Entity>();
      _entitiesByGroup[group] = entities;
    }
    entities.add(entity);

    Bag<String> groups = _groupsByEntity[entity];
    if (groups == null) {
      groups = new Bag<String>();
      _groupsByEntity[entity] = groups;
    }
    groups.add(group);
  }

  /// Remove the entity from the specified group.
  void remove(Entity entity, String group) {
    final Bag<Entity> entities = _entitiesByGroup[group];
    if (entities != null) {
      entities.remove(entity);
    }

    final Bag<String> groups = _groupsByEntity[entity];
    if (groups != null) {
      groups.remove(group);
    }
  }

  void removeFromAllGroups(Entity entity) {
    final Bag<String> groups = _groupsByEntity[entity];
    if (groups != null) {
      groups
        ..forEach((group) {
          final Bag<Entity> entities = _entitiesByGroup[group];
          if (entities != null) {
            entities.remove(entity);
          }
        })
        ..clear();
    }
  }

  /// Get all entities that belong to the provided group.
  Iterable<Entity> getEntities(String group) {
    Bag<Entity> entities = _entitiesByGroup[group];
    if (entities == null) {
      entities = new Bag<Entity>();
      _entitiesByGroup[group] = entities;
    }
    return entities;
  }

  /// Returns the groups the entity belongs to, null if none.
  Iterable<String> getGroups(Entity entity) => _groupsByEntity[entity];

  /// Checks if the entity belongs to any group.
  bool isInAnyGroup(Entity entity) => getGroups(entity) != null;

  /// Check if the entity is in the supplied group.
  bool isInGroup(Entity entity, String group) {
    final Bag<String> groups = _groupsByEntity[entity];
    return (groups != null) && groups.contains(group);
  }

  @override
  void deleted(Entity entity) => removeFromAllGroups(entity);
}
