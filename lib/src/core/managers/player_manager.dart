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

  void setPlayer(Entity entity, String player) {
    _playerByEntity[entity] = player;
    Bag<Entity> entities = _entitiesByPlayer[player];
    if (entities == null) {
      entities = new Bag<Entity>();
      _entitiesByPlayer[player] = entities;
    }
    entities.add(entity);
  }

  Iterable<Entity> getEntitiesOfPlayer(String player) {
    Bag<Entity> entities = _entitiesByPlayer[player];
    return entities ??= new Bag<Entity>();
  }

  void removeFromPlayer(Entity entity) {
    final String player = _playerByEntity[entity];
    if (player != null) {
      final Bag<Entity> entities = _entitiesByPlayer[player];
      if (entities != null) {
        entities.remove(entity);
      }
    }
  }

  String getPlayer(Entity entity) => _playerByEntity[entity];

  @override
  void deleted(Entity entity) => removeFromPlayer(entity);
}
