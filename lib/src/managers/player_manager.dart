part of dartemis;

/**
 * You may sometimes want to specify to which player an entity belongs to.
 *
 * An entity can only belong to a single player at a time.
 */
class PlayerManager extends Manager {
  Map<Entity, String> _playerByEntity;
  Map<String, Bag<Entity>> _entitiesByPlayer;

  PlayerManager() {
    _playerByEntity = new Map<Entity, String>();
    _entitiesByPlayer = new Map<String, Bag<Entity>>();
  }

  void setPlayer(Entity e, String player) {
    _playerByEntity[e] = player;
    Bag<Entity> entities = _entitiesByPlayer[player];
    if(entities == null) {
      entities = new Bag<Entity>();
      _entitiesByPlayer[player] = entities;
    }
    entities.add(e);
  }

  ImmutableBag<Entity> getEntitiesOfPlayer(String player) {
    Bag<Entity> entities = _entitiesByPlayer[player];
    if(entities == null) {
      entities = new Bag<Entity>();
    }
    return entities;
  }

  void removeFromPlayer(Entity e) {
    String player = _playerByEntity[e];
    if(player != null) {
      Bag<Entity> entities = _entitiesByPlayer[player];
      if(entities != null) {
        entities.remove(e);
      }
    }
  }

  String getPlayer(Entity e) {
    return _playerByEntity[e];
  }

  void initialize() {}

  void deleted(Entity e) {
    removeFromPlayer(e);
  }

}
