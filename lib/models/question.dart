enum QuestionType { truth, dare }

class Question {
  final int id;
  final String text;
  final QuestionType type;
  final String category;

  Question({
    required this.id,
    required this.text,
    required this.type,
    required this.category,
  });
}
