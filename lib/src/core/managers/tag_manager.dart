part of '../../../dartemis.dart';

/// If you need to tag any entity, use this. A typical usage would be to tag
/// entities such as "PLAYER", "BOSS" or something that is very unique.
/// An entity can only belong to one tag (0,1) at a time.
class TagManager extends Manager {
  final Map<String, Entity?> _entitiesByTag;
  final Map<Entity, String?> _tagsByEntity;

  /// Create the [TagManager].
  TagManager()
      : _entitiesByTag = <String, Entity>{},
        _tagsByEntity = <Entity, String>{};

  /// Register a [tag] to an [entity].
  void register(Entity entity, String tag) {
    unregister(tag);
    _entitiesByTag[tag] = entity;
    _tagsByEntity[entity] = tag;
  }

  /// Unregister entity tagged with [tag].
  void unregister(String tag) {
    _tagsByEntity.remove(_entitiesByTag.remove(tag));
  }

  /// Returns [:true:] if there is an entity with [tag].
  bool isRegistered(String tag) => _entitiesByTag.containsKey(tag);

  /// Returns the entity with [tag].
  Entity? getEntity(String tag) => _entitiesByTag[tag];

  /// Returns the tag of the [entity].
  String? getTag(Entity entity) => _tagsByEntity[entity];

  /// Returns all known tags.
  Iterable<String> getRegisteredTags() =>
      _tagsByEntity.values as Iterable<String>;

  @override
  void deleted(Entity entity) {
    final removedTag = _tagsByEntity.remove(entity);
    if (removedTag != null) {
      _entitiesByTag.remove(removedTag);
    }
  }
}
