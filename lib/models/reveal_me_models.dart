enum RevealMePhase { none, lobby, answering, reveal, voting, results, finished }

RevealMePhase phaseFromStatus(String? status) {
  switch (status) {
    case 'lobby':
      return RevealMePhase.lobby;
    case 'answering':
      return RevealMePhase.answering;
    case 'reveal':
      return RevealMePhase.reveal;
    case 'voting':
      return RevealMePhase.voting;
    case 'results':
      return RevealMePhase.results;
    case 'finished':
      return RevealMePhase.finished;
    default:
      return RevealMePhase.none;
  }
}

class RevealMePlayer {
  final String id;
  final String? userId;
  final String name;
  final bool isHost;
  final double score;
  final int questionsAnswered;

  RevealMePlayer({
    required this.id,
    this.userId,
    required this.name,
    required this.isHost,
    required this.score,
    required this.questionsAnswered,
  });

  factory RevealMePlayer.fromLobbyJson(Map<String, dynamic> j) => RevealMePlayer(
        id: j['id'],
        userId: j['user_id'],
        name: j['name'],
        isHost: j['is_host'] == true,
        score: double.tryParse('${j['average_score'] ?? 0}') ?? 0,
        questionsAnswered: j['questions_answered'] ?? 0,
      );

  factory RevealMePlayer.fromResultsJson(Map<String, dynamic> j) => RevealMePlayer(
        id: j['id'],
        name: j['name'],
        isHost: false,
        score: (j['score'] is int) ? (j['score'] as int).toDouble() : (j['score'] ?? 0).toDouble(),
        questionsAnswered: j['questionsAnswered'] ?? 0,
      );
}

class RevealMeQuestion {
  final String id;
  final String text;
  final String category;
  final int roundNumber;
  final int totalRounds;
  final int timerSeconds;
  final DateTime roundStartedAt;
  final String? existingAnswer;

  RevealMeQuestion({
    required this.id,
    required this.text,
    required this.category,
    required this.roundNumber,
    required this.totalRounds,
    required this.timerSeconds,
    required this.roundStartedAt,
    this.existingAnswer,
  });

  factory RevealMeQuestion.fromJson(Map<String, dynamic> j) => RevealMeQuestion(
        id: j['question']['id'],
        text: j['question']['question'],
        category: j['question']['category'] ?? '',
        roundNumber: j['roundNumber'],
        totalRounds: j['totalRounds'],
        timerSeconds: j['timerSeconds'] ?? 30,
        roundStartedAt: DateTime.parse(j['roundStartedAt']).toLocal(),
        existingAnswer: j['existingAnswer'],
      );
}

class RevealMeAnswerCard {
  final String id;
  final String text;

  RevealMeAnswerCard({required this.id, required this.text});

  factory RevealMeAnswerCard.fromJson(Map<String, dynamic> j) =>
      RevealMeAnswerCard(id: j['id'], text: j['answer_text']);
}

class RevealMeRoundResult {
  final String answerId;
  final String answerText;
  final String playerName;
  final int votes;
  final bool fastBonus;
  final bool perfectBonus;
  final bool comebackBonus;

  RevealMeRoundResult({
    required this.answerId,
    required this.answerText,
    required this.playerName,
    required this.votes,
    required this.fastBonus,
    required this.perfectBonus,
    required this.comebackBonus,
  });

  factory RevealMeRoundResult.fromJson(Map<String, dynamic> j) => RevealMeRoundResult(
        answerId: j['answerId'],
        answerText: j['answerText'],
        playerName: j['playerName'],
        votes: j['votes'] ?? 0,
        fastBonus: j['fastBonus'] == true,
        perfectBonus: j['perfectBonus'] == true,
        comebackBonus: j['comebackBonus'] == true,
      );
}
