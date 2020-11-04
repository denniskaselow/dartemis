part of dartemis;

/// If you need to group your entities together, e.g. tanks going into "units"
/// group or explosions into "effects", then use this manager. You must retrieve
/// it using world instance.
///
/// An [int] can only belong to several groups (0,n) at a time.
class GroupManager extends Manager {
  final Map<String, Bag<int>> _entitiesByGroup;
  final Map<int, Bag<String>?> _groupsByEntity;

  /// Creates the [GroupManager].
  GroupManager()
      : _entitiesByGroup = <String, Bag<int>>{},
        _groupsByEntity = <int, Bag<String>>{};

  /// Set the group of the entity.
  void add(int entity, String group) {
    _entitiesByGroup.putIfAbsent(group, () => Bag<int>()).add(entity);
    _groupsByEntity.putIfAbsent(entity, () => Bag<String>())!.add(group);
  }

  /// Remove the entity from the specified group.
  void remove(int entity, String group) {
    _entitiesByGroup[group]?.remove(entity);
    _groupsByEntity[entity]?.remove(group);
  }

  /// Remove [entity] from all existing groups.
  void removeFromAllGroups(int entity) {
    final groups = _groupsByEntity[entity];
    if (groups != null) {
      groups
        ..forEach((group) {
          _entitiesByGroup[group]?.remove(entity);
        })
        ..clear();
    }
  }

  /// Get all entities that belong to the provided group.
  Iterable<int> getEntities(String group) =>
      _entitiesByGroup.putIfAbsent(group, () => Bag<int>());

  /// Returns the groups the entity belongs to, null if none.
  Iterable<String>? getGroups(int entity) => _groupsByEntity[entity];

  /// Checks if the entity belongs to any group.
  bool isInAnyGroup(int entity) => getGroups(entity) != null;

  /// Check if the entity is in the supplied group.
  bool isInGroup(int entity, String group) {
    final groups = _groupsByEntity[entity];
    return (groups != null) && groups.contains(group);
  }

  @override
  void deleted(int entity) => removeFromAllGroups(entity);
}
