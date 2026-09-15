class QuizQuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String category;

  QuizQuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.category,
  });

  factory QuizQuestionModel.fromMap(String id, Map<String, dynamic> data) {
    return QuizQuestionModel(
      id: id,
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? const []),
      correctAnswer: data['correctAnswer']?.toString() ?? '',
      category: data['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'category': category,
    };
  }
}
