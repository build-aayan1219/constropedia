import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestion = 0;
  int score = 0;
  int? selectedAnswer;

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Which material is commonly used to make concrete?',
      'options': [
        'Cement',
        'Wood',
        'Glass',
        'Plastic',
      ],
      'answer': 0,
    },
    {
      'question': 'What is the main purpose of a foundation?',
      'options': [
        'To decorate the building',
        'To transfer building loads to the ground',
        'To paint the building',
        'To provide lighting',
      ],
      'answer': 1,
    },
    {
      'question': 'Which material is commonly used for reinforcement in concrete?',
      'options': [
        'Paper',
        'Rubber',
        'Steel',
        'Plastic',
      ],
      'answer': 2,
    },
    {
      'question': 'Which equipment is mainly used to lift heavy materials?',
      'options': [
        'Crane',
        'Hammer',
        'Trowel',
        'Level',
      ],
      'answer': 0,
    },
    {
      'question': 'Which of the following is important for construction site safety?',
      'options': [
        'Ignoring safety rules',
        'Using proper safety equipment',
        'Running on the site',
        'Removing warning signs',
      ],
      'answer': 1,
    },
  ];

  void selectAnswer(int answer) {
    setState(() {
      selectedAnswer = answer;
    });
  }

  void nextQuestion() {
    if (selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an answer.'),
        ),
      );
      return;
    }

    if (selectedAnswer == questions[currentQuestion]['answer']) {
      score++;
    }

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
      });
    } else {
      showResult();
    }
  }

  void showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quiz Completed! 🎉'),
          content: Text(
            'Your score is $score out of ${questions.length}.',
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                restartQuiz();
              },
              child: const Text('Try Again'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void restartQuiz() {
    setState(() {
      currentQuestion = 0;
      score = 0;
      selectedAnswer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Construction Quiz'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PROGRESS
            Text(
              'Question ${currentQuestion + 1} of ${questions.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            LinearProgressIndicator(
              value:
                  (currentQuestion + 1) / questions.length,
            ),

            const SizedBox(height: 30),

            // QUESTION
            Text(
              question['question'],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            // OPTIONS
            Expanded(
              child: ListView.builder(
                itemCount: question['options'].length,
                itemBuilder: (context, index) {
                  final option =
                      question['options'][index];

                  final isSelected =
                      selectedAnswer == index;

                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ),

                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          String.fromCharCode(
                            65 + index,
                          ),
                        ),
                      ),

                      title: Text(
                        option,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                            )
                          : null,

                      selected: isSelected,

                      onTap: () {
                        selectAnswer(index);
                      },
                    ),
                  );
                },
              ),
            ),

            // NEXT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: nextQuestion,
                child: Text(
                  currentQuestion ==
                          questions.length - 1
                      ? 'Finish Quiz'
                      : 'Next Question',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}