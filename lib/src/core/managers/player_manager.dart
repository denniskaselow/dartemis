part of dartemis;

/// You may sometimes want to specify to which player an entity belongs to.
///
/// An entity can only belong to a single player at a time.
class PlayerManager extends Manager {
  final Map<int, String> _playerByEntity;
  final Map<String, Bag<int>> _entitiesByPlayer;

  /// Creates the [PlayerManager].
  PlayerManager()
      : _playerByEntity = <int, String>{},
        _entitiesByPlayer = <String, Bag<int>>{};

  /// Make [entity] belong to [player].
  void setPlayer(int entity, String player) {
    _playerByEntity[entity] = player;
    _entitiesByPlayer.putIfAbsent(player, () => Bag<int>()).add(entity);
  }

  /// Returns all entities that belong to [player].
  Iterable<int> getEntitiesOfPlayer(String player) =>
      _entitiesByPlayer[player] ??= Bag<int>();

  /// Removes [entity] from the player it is associated with.
  void removeFromPlayer(int entity) {
    final player = _playerByEntity[entity];
    if (player != null) {
      _entitiesByPlayer[player]?.remove(entity);
    }
  }

  /// Returns the player associated with [entity].
  String getPlayer(int entity) => _playerByEntity[entity];

  @override
  void deleted(int entity) => removeFromPlayer(entity);
}
