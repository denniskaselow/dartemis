part of dartemis;

/// You may sometimes want to specify to which player an entity belongs to.
///
/// An entity can only belong to a single player at a time.
class PlayerManager extends Manager {
  Map<Entity, String> _playerByEntity;
  Map<String, Bag<Entity>> _entitiesByPlayer;

  PlayerManager() {
    _playerByEntity = <Entity, String>{};
    _entitiesByPlayer = <String, Bag<Entity>>{};
  }

  void setPlayer(Entity e, String player) {
    _playerByEntity[e] = player;
    Bag<Entity> entities = _entitiesByPlayer[player];
    if (entities == null) {
      entities = new Bag<Entity>();
      _entitiesByPlayer[player] = entities;
    }
    entities.add(e);
  }

  Iterable<Entity> getEntitiesOfPlayer(String player) {
    Bag<Entity> entities = _entitiesByPlayer[player];
    return entities ??= new Bag<Entity>();
  }

  void removeFromPlayer(Entity e) {
    final String player = _playerByEntity[e];
    if (player != null) {
      final Bag<Entity> entities = _entitiesByPlayer[player];
      if (entities != null) {
        entities.remove(e);
      }
    }
  }

  String getPlayer(Entity e) => _playerByEntity[e];

  @override
  void deleted(Entity e) => removeFromPlayer(e);
}
