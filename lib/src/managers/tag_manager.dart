part of dartemis;

class TagManager {
  World _world;
  final _entityByTag;

  TagManager(this._world) : _entityByTag = new Map<String, Entity>();

  void register(String tag, Entity e) {
    _entityByTag[tag] = e;
  }

  void unregister(String tag) {
    _entityByTag.remove(tag);
  }

  bool isRegistered(String tag) {
    return _entityByTag.containsKey(tag);
  }

  Entity getEntity(String tag) {
    return _entityByTag[tag];
  }

  void remove(Entity e) {
//     TODO
//    _entityByTag.getValues().remove(e);
  }
}
