part of '../../../dartemis.dart';

/// You may sometimes want to specify to which player an entity belongs to.
///
/// An entity can only belong to a single player at a time.
class PlayerManager extends Manager {
  final Map<Entity, String?> _playerByEntity;
  final Map<String, EntityBag> _entitiesByPlayer;

  /// Creates the [PlayerManager].
  PlayerManager()
      : _playerByEntity = <Entity, String>{},
        _entitiesByPlayer = <String, EntityBag>{};

  /// Make [entity] belong to [player].
  void setPlayer(Entity entity, String player) {
    _playerByEntity[entity] = player;
    _entitiesByPlayer.putIfAbsent(player, EntityBag.new).add(entity);
  }

  /// Returns all entities that belong to [player].
  Iterable<Entity> getEntitiesOfPlayer(String player) =>
      _entitiesByPlayer[player] ??= EntityBag();

  /// Removes [entity] from the player it is associated with.
  void removeFromPlayer(Entity entity) {
    final player = _playerByEntity[entity];
    if (player != null) {
      _entitiesByPlayer[player]?.remove(entity);
    }
  }

  /// Returns the player associated with [entity].
  String? getPlayer(Entity entity) => _playerByEntity[entity];

  @override
  void deleted(Entity entity) => removeFromPlayer(entity);
}
