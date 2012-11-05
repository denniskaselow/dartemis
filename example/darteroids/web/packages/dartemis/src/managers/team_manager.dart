part of dartemis;

/**
 * Use this class together with PlayerManager.
 *
 * You may sometimes want to create teams in your game, so that
 * some players are team mates.
 *
 * A player can only belong to a single team.
 */
class TeamManager extends Manager {
  Map<String, Bag<String>> _playersByTeam;
  Map<String, String> _teamByPlayer;

  TeamManager() {
    _playersByTeam = new Map<String, Bag<String>>();
    _teamByPlayer = new Map<String, String>();
  }

  void initialize() {}

  String getTeam(String player) {
    return _teamByPlayer[player];
  }

  void setTeam(String player, String team) {
    removeFromTeam(player);

    _teamByPlayer[player] = team;

    Bag<String> players = _playersByTeam[team];
    if(players == null) {
      players = new Bag<String>();
      _playersByTeam[team] = players;
    }
    players.add(player);
  }

  ImmutableBag<String> getPlayers(String team) {
    return _playersByTeam[team];
  }

  void removeFromTeam(String player) {
    String team = _teamByPlayer.remove(player);
    if(team != null) {
      Bag<String> players = _playersByTeam[team];
      if(players != null) {
        players.remove(player);
      }
    }
  }

}
