part of dartemis;

/**
 * If you need to tag any entity, use this. A typical usage would be to tag
 * entities such as "PLAYER", "BOSS" or something that is very unique.
 * An [Entity] can only belong to one tag (0,1) at a time.
 */
class TagManager extends Manager {
  final Map<String, Entity> _entitiesByTag;
  final Map<Entity, String> _tagsByEntity;

  TagManager()
      : _entitiesByTag = new Map<String, Entity>(),
        _tagsByEntity = new Map<Entity, String>();

  void register(Entity e, String tag) {
    _entitiesByTag[tag] = e;
    _tagsByEntity[e] = tag;
  }

  void unregister(String tag) {
    _tagsByEntity.remove(_entitiesByTag.remove(tag));
  }

  bool isRegistered(String tag) => _entitiesByTag.containsKey(tag);
  Entity getEntity(String tag) => _entitiesByTag[tag];
  Iterable<String> getRegisteredTags() => _tagsByEntity.values;

  void deleted(Entity e) {
    String removedTag = _tagsByEntity.remove(e);
    if (removedTag != null) {
      _entitiesByTag.remove(removedTag);
    }
  }
}
