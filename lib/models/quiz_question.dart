class QuizQuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String category;
  final String difficulty;
  final Map<String, String> optionExplanations;

  QuizQuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.category,
    this.difficulty = 'Medium',
    this.optionExplanations = const {},
  });

  factory QuizQuestionModel.fromMap(String id, Map<String, dynamic> data) {
    Map<String, String> parsedExplanations = {};
    if (data['optionExplanations'] is Map) {
      final rawMap = data['optionExplanations'] as Map;
      parsedExplanations = rawMap.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }

    return QuizQuestionModel(
      id: id,
      question: data['question']?.toString() ?? '',
      options: List<String>.from(data['options'] ?? const []),
      correctAnswer: data['correctAnswer']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      difficulty: data['difficulty']?.toString() ?? 'Medium',
      optionExplanations: parsedExplanations,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'category': category,
      'difficulty': difficulty,
      'optionExplanations': optionExplanations,
    };
  }
}
