part of '../../../dartemis.dart';

/// Use this class together with PlayerManager.
///
/// You may sometimes want to create teams in your game, so that
/// some players are team mates.
///
/// A player can only belong to a single team.
class TeamManager extends Manager {
  final Map<String, List<String>> _playersByTeam;
  final Map<String, String?> _teamByPlayer;

  /// Create a TeamManager.
  TeamManager()
      : _playersByTeam = <String, List<String>>{},
        _teamByPlayer = <String, String>{};

  /// Returns the team of [player].
  String? getTeam(String player) => _teamByPlayer[player];

  /// Set the [team] of [player].
  void setTeam(String player, String team) {
    removeFromTeam(player);

    _teamByPlayer[player] = team;
    _playersByTeam.putIfAbsent(team, () => <String>[]).add(player);
  }

  /// Returns all players of [team].
  Iterable<String> getPlayers(String team) =>
      _playersByTeam[team] ?? <String>[];

  /// Removes [player] from their team.
  void removeFromTeam(String player) {
    final team = _teamByPlayer.remove(player);
    if (team != null) {
      _playersByTeam[team]?.remove(player);
    }
  }
}
