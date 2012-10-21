part of dartemis;

class TagManager extends Manager {
  final Map<String, Entity> _entitiesByTag;
  final Map<Entity, String> _tagsByEntity;

  TagManager() : _entitiesByTag = new Map<String, Entity>(),
                 _tagsByEntity = new Map<Entity, String>();



  void register(String tag, Entity e) {
    _entitiesByTag[tag] = e;
    _tagsByEntity[e] = tag;
  }

  void unregister(String tag) {
    _tagsByEntity.remove(_entitiesByTag.remove(tag));
  }

  bool isRegistered(String tag) {
    return _entitiesByTag.containsKey(tag);
  }

  Entity getEntity(String tag) {
    return _entitiesByTag[tag];
  }

  Collection<String> getRegisteredTags() {
    return _tagsByEntity.getValues();
  }

  void deleted(Entity e) {
    String removedTag = _tagsByEntity.remove(e);
    if(removedTag != null) {
      _entitiesByTag.remove(removedTag);
    }
  }

  void initialize() {}
}
