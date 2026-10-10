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
    required this.difficulty,
    required this.optionExplanations,
  });

  factory QuizQuestionModel.fromMap(String id, Map<String, dynamic> data) {
    return QuizQuestionModel(
      id: id,
      question: data['question']?.toString() ?? '',
      options: List<String>.from(data['options'] ?? const []),
      correctAnswer: data['correctAnswer']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      difficulty: data['difficulty']?.toString() ?? 'Easy',
      optionExplanations: Map<String, String>.from(
        data['optionExplanations'] ?? const {},
      ),
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
