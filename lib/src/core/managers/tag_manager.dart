part of dartemis;

/// If you need to tag any entity, use this. A typical usage would be to tag
/// entities such as "PLAYER", "BOSS" or something that is very unique.
/// An [int] can only belong to one tag (0,1) at a time.
class TagManager extends Manager {
  final Map<String, int> _entitiesByTag;
  final Map<int, String> _tagsByEntity;

  /// Create the [TagManager].
  TagManager()
      : _entitiesByTag = <String, int>{},
        _tagsByEntity = <int, String>{};

  /// Register a [tag] to an [entity].
  void register(int entity, String tag) {
    unregister(tag);
    _entitiesByTag[tag] = entity;
    _tagsByEntity[entity] = tag;
  }

  /// Unregister entity tagged with [tag].
  void unregister(String tag) {
    _tagsByEntity.remove(_entitiesByTag.remove(tag));
  }

  /// Returns [:true:] if there is an [int] with [tag].
  bool isRegistered(String tag) => _entitiesByTag.containsKey(tag);

  /// Returns the [int] with [tag].
  int getEntity(String tag) => _entitiesByTag[tag];

  /// Returns all known tags.
  Iterable<String> getRegisteredTags() => _tagsByEntity.values;

  @override
  void deleted(int entity) {
    final removedTag = _tagsByEntity.remove(entity);
    if (removedTag != null) {
      _entitiesByTag.remove(removedTag);
    }
  }
}
