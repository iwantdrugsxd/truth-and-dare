import 'dart:math';
import 'package:flutter/material.dart';
import '../models/undercover_player.dart';
import '../data/undercover_words_data.dart';

enum GamePhase {
  setup,
  roleReveal,
  clueGiving,
  voting,
  elimination,
  gameEnd,
}

enum GameWinner {
  civilians,
  undercover,
  mrWhite,
  none,
}

class UndercoverProvider extends ChangeNotifier {
  final List<UndercoverPlayer> _players = [];
  final Random _random = Random();
  
  GamePhase _phase = GamePhase.setup;
  int _numUndercover = 1;
  int _numMrWhite = 0;
  int _currentRound = 1;
  int _currentPlayerIndex = 0;
  String? _civilianWord;
  String? _undercoverWord;
  Map<String, String> _clues = {};
  Map<String, String> _votes = {};
  List<String> _eliminatedPlayers = [];
  GameWinner _winner = GameWinner.none;
  String? _eliminatedPlayerId;
  List<String> _tiedPlayers = [];
  bool _isTieBreak = false;

  // Getters
  List<UndercoverPlayer> get players => _players.where((p) => p.isAlive).toList();
  List<UndercoverPlayer> get allPlayers => _players;
  GamePhase get phase => _phase;
  int get numUndercover => _numUndercover;
  int get numMrWhite => _numMrWhite;
  int get currentRound => _currentRound;
  int get currentPlayerIndex => _currentPlayerIndex;
  UndercoverPlayer? get currentPlayer => players.isNotEmpty ? players[_currentPlayerIndex] : null;
  String? get civilianWord => _civilianWord;
  String? get undercoverWord => _undercoverWord;
  Map<String, String> get clues => _clues;
  Map<String, String> get votes => _votes;
  GameWinner get winner => _winner;
  String? get eliminatedPlayerId => _eliminatedPlayerId;
  set eliminatedPlayerId(String? value) {
    _eliminatedPlayerId = value;
    notifyListeners();
  }
  List<String> get tiedPlayers => _tiedPlayers;
  bool get isTieBreak => _isTieBreak;
  set phase(GamePhase value) {
    _phase = value;
    notifyListeners();
  }
  set currentRound(int value) {
    _currentRound = value;
    notifyListeners();
  }

  void addPlayer(String name) {
    if (_players.length >= 12) return;
    if (name.trim().isEmpty) return;

    final index = _players.length;
    final player = UndercoverPlayer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      icon: UndercoverPlayer.availableIcons[index % UndercoverPlayer.availableIcons.length],
      color: UndercoverPlayer.availableColors[index % UndercoverPlayer.availableColors.length],
      role: UndercoverRole.civilian,
    );
    _players.add(player);
    notifyListeners();
  }

  void removePlayer(String id) {
    _players.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void setNumUndercover(int count) {
    _numUndercover = count;
    notifyListeners();
  }

  void setNumMrWhite(int count) {
    _numMrWhite = count;
    notifyListeners();
  }

  void startGame() {
    if (_players.length < 3) {
      throw Exception('Need at least 3 players to start');
    }
    
    // Validate that there's at least one civilian
    if (_numUndercover + _numMrWhite >= _players.length) {
      throw Exception('Need at least one civilian. Reduce undercovers or Mr. White.');
    }
    
    // Select random word pair
    final wordPair = UndercoverWordsData.wordPairs[_random.nextInt(UndercoverWordsData.wordPairs.length)];
    _civilianWord = wordPair['civilian'];
    _undercoverWord = wordPair['undercover'];

    // Assign roles
    final shuffled = List<UndercoverPlayer>.from(_players)..shuffle(_random);
    
    int undercoverCount = 0;
    int mrWhiteCount = 0;

    for (var player in shuffled) {
      if (undercoverCount < _numUndercover) {
        player.role = UndercoverRole.undercover;
        player.word = _undercoverWord;
        undercoverCount++;
      } else if (mrWhiteCount < _numMrWhite) {
        player.role = UndercoverRole.mrWhite;
        player.word = null;
        mrWhiteCount++;
      } else {
        player.role = UndercoverRole.civilian;
        player.word = _civilianWord;
      }
    }

    _phase = GamePhase.roleReveal;
    _currentPlayerIndex = 0;
    notifyListeners();
  }

  void markRoleRevealed(String playerId) {
    final player = _players.firstWhere((p) => p.id == playerId);
    player.hasRevealedRole = true;
    notifyListeners();
  }

  void startClueGiving() {
    _phase = GamePhase.clueGiving;
    _clues.clear();
    _currentPlayerIndex = _random.nextInt(players.length);
    notifyListeners();
  }

  void submitClue(String playerId, String clue) {
    // Allow empty clues for verbal play
    _clues[playerId] = clue.trim().isEmpty ? 'Verbal clue' : clue.trim();
    final player = _players.firstWhere((p) => p.id == playerId);
    player.clue = clue.trim().isEmpty ? null : clue.trim();
    notifyListeners();
  }

  bool allCluesSubmitted() {
    if (_isTieBreak && _tiedPlayers.isNotEmpty) {
      // In tiebreak, only tied players need to submit clues
      return _tiedPlayers.every((id) => _clues.containsKey(id));
    }
    return players.every((p) => _clues.containsKey(p.id));
  }

  void startVoting() {
    _phase = GamePhase.voting;
    _votes.clear();
    _currentPlayerIndex = 0;
    if (_isTieBreak && _tiedPlayers.isNotEmpty) {
      // In tiebreak, only vote for tied players
      for (var player in _players) {
        if (_tiedPlayers.contains(player.id)) {
          player.votesReceived = 0;
        }
        player.votedFor = null;
      }
    } else {
      for (var player in players) {
        player.votesReceived = 0;
        player.votedFor = null;
      }
    }
    notifyListeners();
  }

  void submitVote(String voterId, String targetId) {
    if (voterId == targetId) return; // Can't vote for self
    
    final voter = _players.firstWhere((p) => p.id == voterId);
    if (voter.votedFor != null) {
      // Remove old vote
      final oldTarget = _players.firstWhere((p) => p.id == voter.votedFor);
      oldTarget.votesReceived--;
    }
    
    voter.votedFor = targetId;
    _votes[voterId] = targetId;
    final target = _players.firstWhere((p) => p.id == targetId);
    target.votesReceived++;
    notifyListeners();
  }

  bool allVotesSubmitted() {
    if (_isTieBreak && _tiedPlayers.isNotEmpty) {
      // In tiebreak, only tied players vote
      return _tiedPlayers.every((id) => _votes.containsKey(id));
    }
    return players.every((p) => _votes.containsKey(p.id));
  }

  void voteForPlayer(String playerId) {
    // Direct elimination for verbal voting
    final eliminated = _players.firstWhere((p) => p.id == playerId && p.isAlive);
    eliminated.isAlive = false;
    _eliminatedPlayerId = eliminated.id;
    _eliminatedPlayers.add(eliminated.id);
    _isTieBreak = false;
    _tiedPlayers.clear();

    // Check if Mr. White can guess
    if (eliminated.role == UndercoverRole.mrWhite) {
      _phase = GamePhase.elimination;
      notifyListeners();
      return;
    }

    // Check win conditions
    checkWinConditions();
    
    if (_winner == GameWinner.none) {
      // Continue to next round
      _currentRound++;
      _phase = GamePhase.elimination;
      _clues.clear();
      _votes.clear();
      if (players.isNotEmpty) {
        _currentPlayerIndex = _random.nextInt(players.length);
      }
      for (var player in players) {
        player.clue = null;
        player.votesReceived = 0;
        player.votedFor = null;
      }
    } else {
      _phase = GamePhase.gameEnd;
    }
    
    notifyListeners();
  }

  void processElimination() {
    // Find player(s) with most votes
    if (players.isEmpty) return;
    
    List<UndercoverPlayer> candidates;
    if (_isTieBreak && _tiedPlayers.isNotEmpty) {
      // In tiebreak, only consider tied players
      final tiedPlayersList = _players.where((p) => _tiedPlayers.contains(p.id) && p.isAlive).toList();
      if (tiedPlayersList.isEmpty) return;
      final maxVotes = tiedPlayersList.map((p) => p.votesReceived).reduce(max);
      candidates = tiedPlayersList.where((p) => p.votesReceived == maxVotes).toList();
    } else {
      final maxVotes = players.map((p) => p.votesReceived).reduce(max);
      candidates = players.where((p) => p.votesReceived == maxVotes).toList();
    }

    if (candidates.length > 1 && !_isTieBreak) {
      // First tie - need tiebreak
      _tiedPlayers = candidates.map((p) => p.id).toList();
      _isTieBreak = true;
      _phase = GamePhase.clueGiving;
      _clues.clear();
      _votes.clear();
      // Only tied players can give clues
      for (var player in _players) {
        player.clue = null;
        player.votesReceived = 0;
        player.votedFor = null;
      }
      _currentPlayerIndex = 0;
      // Set current player to first tied player
      final firstTiedIndex = players.indexWhere((p) => _tiedPlayers.contains(p.id));
      if (firstTiedIndex != -1) {
        _currentPlayerIndex = firstTiedIndex;
      }
      notifyListeners();
      return;
    }
    
    // If still tied after tiebreak, eliminate randomly
    if (candidates.length > 1) {
      candidates = [candidates[_random.nextInt(candidates.length)]];
    }

    // Single winner - eliminate
    final eliminated = candidates.first;
    eliminated.isAlive = false;
    _eliminatedPlayerId = eliminated.id;
    _eliminatedPlayers.add(eliminated.id);
    _isTieBreak = false;
    _tiedPlayers.clear();

    // Check if Mr. White can guess
    if (eliminated.role == UndercoverRole.mrWhite) {
      _phase = GamePhase.elimination;
      notifyListeners();
      return;
    }

    // Check win conditions
    checkWinConditions();
    
    if (_winner == GameWinner.none) {
      // Continue to next round
      _currentRound++;
      _phase = GamePhase.clueGiving;
      _clues.clear();
      _votes.clear();
      if (players.isNotEmpty) {
        _currentPlayerIndex = _random.nextInt(players.length);
      }
      for (var player in players) {
        player.clue = null;
        player.votesReceived = 0;
        player.votedFor = null;
      }
    } else {
      _phase = GamePhase.gameEnd;
    }
    
    notifyListeners();
  }

  void mrWhiteGuess(String guess) {
    if (guess.trim().toLowerCase() == _civilianWord?.toLowerCase()) {
      _winner = GameWinner.mrWhite;
      _phase = GamePhase.gameEnd;
    } else {
      // Wrong guess - check if last bad guy
      if (isLastBadGuy) {
        // Mr. White was the last bad guy, civilians win
        _winner = GameWinner.civilians;
        _phase = GamePhase.gameEnd;
      } else {
        // Not last bad guy, continue game
        checkWinConditions();
        if (_winner == GameWinner.none) {
          _currentRound++;
          _phase = GamePhase.clueGiving;
          _clues.clear();
          _votes.clear();
          _currentPlayerIndex = _random.nextInt(players.length);
          for (var player in players) {
            player.clue = null;
            player.votesReceived = 0;
            player.votedFor = null;
          }
        } else {
          _phase = GamePhase.gameEnd;
        }
      }
    }
    notifyListeners();
  }

  void checkWinConditions() {
    final alivePlayers = players;
    final aliveUndercovers = alivePlayers.where((p) => p.role == UndercoverRole.undercover).length;
    final aliveCivilians = alivePlayers.where((p) => p.role == UndercoverRole.civilian).length;
    final aliveMrWhite = alivePlayers.where((p) => p.role == UndercoverRole.mrWhite).length;
    final aliveBadGuys = aliveUndercovers + aliveMrWhite;

    // Bad guys win if civilians < bad guys
    if (aliveCivilians < aliveBadGuys && aliveBadGuys > 0) {
      _winner = GameWinner.undercover;
      return;
    }

    // Undercover wins if only 2 players remain (undercover + 1 other)
    if (alivePlayers.length == 2 && aliveUndercovers > 0) {
      _winner = GameWinner.undercover;
      return;
    }

    // Civilians win ONLY if all undercovers AND all Mr. White are eliminated
    if (aliveUndercovers == 0 && aliveMrWhite == 0 && aliveCivilians > 0) {
      _winner = GameWinner.civilians;
      return;
    }
  }

  bool get isLastBadGuy {
    final alivePlayers = players;
    final aliveUndercovers = alivePlayers.where((p) => p.role == UndercoverRole.undercover).length;
    final aliveMrWhite = alivePlayers.where((p) => p.role == UndercoverRole.mrWhite).length;
    return (aliveUndercovers + aliveMrWhite) == 0;
  }

  void nextPlayer() {
    if (players.isNotEmpty) {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % players.length;
      notifyListeners();
    }
  }

  void restartGame() {
    // Keep players but reset their game state
    for (var player in _players) {
      player.isAlive = true;
      player.role = UndercoverRole.civilian;
      player.word = null;
      player.clue = null;
      player.votesReceived = 0;
      player.votedFor = null;
      player.hasRevealedRole = false;
    }
    
    // Reset game state
    _phase = GamePhase.setup;
    _currentRound = 1;
    _currentPlayerIndex = 0;
    _civilianWord = null;
    _undercoverWord = null;
    _clues.clear();
    _votes.clear();
    _eliminatedPlayers.clear();
    _winner = GameWinner.none;
    _eliminatedPlayerId = null;
    _tiedPlayers.clear();
    _isTieBreak = false;
    
    // Start new game with same players
    startGame();
    notifyListeners();
  }

  void resetGame() {
    _players.clear();
    _phase = GamePhase.setup;
    _numUndercover = 1;
    _numMrWhite = 0;
    _currentRound = 1;
    _currentPlayerIndex = 0;
    _civilianWord = null;
    _undercoverWord = null;
    _clues.clear();
    _votes.clear();
    _eliminatedPlayers.clear();
    _winner = GameWinner.none;
    _eliminatedPlayerId = null;
    _tiedPlayers.clear();
    _isTieBreak = false;
    notifyListeners();
  }
}

