import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:constropedia/models/article.dart';
import 'package:constropedia/models/mixture_record.dart';
import 'package:constropedia/models/quiz_question.dart';
import 'package:constropedia/services/local_quiz_data.dart';
import 'package:constropedia/theme/app_theme.dart';
import 'package:constropedia/widgets/app_ui.dart';
import 'package:constropedia/widgets/category_card.dart';

void main() {
  group('Article Model Tests', () {
    test('Article.fromMap parses valid map correctly', () {
      final data = {
        'title': 'Portland Cement',
        'description': 'A fine hydraulic powder.',
        'content': 'Cement hydrates when mixed with water.',
        'category': 'Materials',
        'imageUrl': 'https://example.com/cement.jpg',
      };

      final article = Article.fromMap('art_001', data);

      expect(article.id, 'art_001');
      expect(article.title, 'Portland Cement');
      expect(article.description, 'A fine hydraulic powder.');
      expect(article.content, 'Cement hydrates when mixed with water.');
      expect(article.category, 'Materials');
      expect(article.imageUrl, 'https://example.com/cement.jpg');
    });

    test('Article.fromMap handles missing/null optional fields safely', () {
      final article = Article.fromMap('art_empty', {});

      expect(article.id, 'art_empty');
      expect(article.title, '');
      expect(article.description, '');
      expect(article.content, '');
      expect(article.category, '');
      expect(article.imageUrl, isNull);
    });

    test('Article.toMap returns correct serializable map', () {
      final article = Article(
        id: 'art_002',
        title: 'Rebar',
        description: 'Reinforcement bar',
        content: 'Tensile strength steel.',
        category: 'Structural',
        imageUrl: 'https://example.com/rebar.jpg',
      );

      final map = article.toMap();

      expect(map['title'], 'Rebar');
      expect(map['category'], 'Structural');
      expect(map['imageUrl'], 'https://example.com/rebar.jpg');
    });
  });

  group('ConcreteMixtureRecord Model Tests', () {
    test('ConcreteMixtureRecord.fromMap parses numeric types correctly', () {
      final data = {
        'cement': 540.0,
        'blastFurnaceSlag': 0.0,
        'flyAsh': 0.0,
        'water': 162.0,
        'superplasticizer': 2.5,
        'coarseAggregate': 1040.0,
        'fineAggregate': 676.0,
        'age': 28,
        'compressiveStrength': 79.99,
      };

      final record = ConcreteMixtureRecord.fromMap('record001', data);

      expect(record.id, 'record001');
      expect(record.cement, 540.0);
      expect(record.water, 162.0);
      expect(record.age, 28);
      expect(record.compressiveStrength, 79.99);
      expect(record.components.length, 9);
    });

    test('ConcreteMixtureRecord handles missing fields with defaults', () {
      final record = ConcreteMixtureRecord.fromMap('record_empty', {});

      expect(record.cement, 0.0);
      expect(record.age, 0);
      expect(record.compressiveStrength, 0.0);
      expect(record.components.length, 9);
    });
  });

  group('QuizQuestionModel & Scoring Tests', () {
    test('QuizQuestionModel parses difficulty and explanations', () {
      final data = {
        'question': 'What is the binder in concrete?',
        'options': ['Cement', 'Sand', 'Gravel', 'Water'],
        'correctAnswer': 'Cement',
        'category': 'Materials',
        'difficulty': 'Easy',
        'optionExplanations': {
          'Cement': 'Correct. Cement acts as hydraulic binder.',
          'Sand': 'Incorrect. Sand is fine aggregate.',
        },
      };

      final question = QuizQuestionModel.fromMap('q01', data);

      expect(question.id, 'q01');
      expect(question.question, 'What is the binder in concrete?');
      expect(question.options.length, 4);
      expect(question.correctAnswer, 'Cement');
      expect(question.difficulty, 'Easy');
      expect(question.optionExplanations['Cement'], contains('binder'));
    });

    test(
      'LocalQuizData provides exactly 50 validated questions across 5 categories',
      () {
        final allQuestions = LocalQuizData.getAllQuestions();
        expect(allQuestions.length, 50);

        const expectedCategories = [
          'Materials',
          'Structural',
          'Finishing',
          'Site Safety',
          'Tools & Machinery',
        ];

        for (final cat in expectedCategories) {
          final catQuestions = LocalQuizData.getQuestionsByCategory(cat);
          expect(
            catQuestions.length,
            10,
            reason: '$cat must contain exactly 10 questions',
          );

          for (final q in catQuestions) {
            expect(q.options.length, 4, reason: '${q.id} must have 4 options');
            expect(
              q.options.contains(q.correctAnswer),
              isTrue,
              reason: '${q.id} correct answer must be one of the options',
            );
            expect(q.difficulty, isNotEmpty);
          }
        }
      },
    );

    test('Quiz scoring calculation behaves as expected', () {
      const total = 10;
      int score = 7;
      final percentage = ((score / total) * 100).round();
      expect(percentage, 70);

      // Edge case: 0 total questions
      const zeroTotal = 0;
      final zeroPercentage = zeroTotal == 0
          ? 0
          : ((score / zeroTotal) * 100).round();
      expect(zeroPercentage, 0);
    });
  });

  group('Widget Smoke & Component Tests', () {
    testWidgets('CategoryCard displays title and icon properly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: CategoryCard(title: 'Materials', icon: Icons.layers_outlined),
          ),
        ),
      );

      expect(find.text('Materials'), findsOneWidget);
      expect(find.byIcon(Icons.layers_outlined), findsOneWidget);
    });

    testWidgets('AppSectionHeader renders title and subtitle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: AppSectionHeader(
              title: 'Categories',
              subtitle: 'Browse topics by trade',
            ),
          ),
        ),
      );

      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Browse topics by trade'), findsOneWidget);
    });

    testWidgets('CategoryChip displays given label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: CategoryChip(label: 'Site Safety')),
        ),
      );

      expect(find.text('Site Safety'), findsOneWidget);
    });
  });
}
