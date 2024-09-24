part of '../../../dartemis.dart';

/// If you need to group your entities together, e.g. tanks going into "units"
/// group or explosions into "effects", then use this manager. You must retrieve
/// it using world instance.
///
/// An [int] can only belong to several groups (0,n) at a time.
class GroupManager extends Manager {
  final Map<String, EntityBag> _entitiesByGroup;
  final Map<Entity, Bag<String>> _groupsByEntity;

  /// Creates the [GroupManager].
  GroupManager()
      : _entitiesByGroup = <String, EntityBag>{},
        _groupsByEntity = <Entity, Bag<String>>{};

  /// Set the group of the entity.
  void add(Entity entity, String group) {
    _entitiesByGroup.putIfAbsent(group, EntityBag.new).add(entity);
    _groupsByEntity.putIfAbsent(entity, Bag<String>.new).add(group);
  }

  /// Remove the entity from the specified group.
  void remove(Entity entity, String group) {
    _entitiesByGroup[group]?.remove(entity);
    _groupsByEntity[entity]?.remove(group);
  }

  /// Remove [entity] from all existing groups.
  void removeFromAllGroups(Entity entity) {
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
  Iterable<Entity> getEntities(String group) =>
      _entitiesByGroup.putIfAbsent(group, EntityBag.new);

  /// Returns the groups the entity belongs to, null if none.
  Iterable<String>? getGroups(Entity entity) => _groupsByEntity[entity];

  /// Checks if the entity belongs to any group.
  bool isInAnyGroup(Entity entity) => getGroups(entity) != null;

  /// Check if the entity is in the supplied group.
  bool isInGroup(Entity entity, String group) {
    final groups = _groupsByEntity[entity];
    return (groups != null) && groups.contains(group);
  }

  @override
  void deleted(Entity entity) => removeFromAllGroups(entity);
}
