import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/article.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import '../widgets/category_card.dart';
import 'article_page.dart';
import 'bookmarks_page.dart';
import 'quiz_history_page.dart';
import 'quiz_page.dart';
import 'search_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  String _displayName = '';
  Article? _termOfTheDay;
  bool _loadingTerm = true;
  String? _termError;

  @override
  void initState() {
    super.initState();
    _loadWelcomeData();
    _loadTermOfTheDay();
  }

  Future<void> _loadWelcomeData() async {
    try {
      final profile = await _firestoreService.getUserProfile();
      final data = profile.data();
      final name = data?['name']?.toString().trim() ?? '';
      if (!mounted) return;
      setState(() {
        _displayName = name;
      });
    } catch (e) {
      debugPrint('Unable to load user profile: $e');
    }
  }

  Future<void> _loadTermOfTheDay() async {
    setState(() {
      _loadingTerm = true;
      _termError = null;
    });

    try {
      final articles = await _firestoreService.getArticles();
      if (!mounted) return;

      Article? selected;
      if (articles.isNotEmpty) {
        final index = DateTime.now().day % articles.length;
        selected = articles[index];
      }

      setState(() {
        _termOfTheDay = selected;
        _loadingTerm = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingTerm = false;
        _termError = e.toString();
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _displayName.isEmpty
        ? 'Welcome to Constropedia'
        : 'Hello, $_displayName';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Constropedia'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookmarksPage(),
                ),
              );
            },
            icon: const Icon(Icons.bookmark_outline_rounded),
            tooltip: 'Bookmarks',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuizHistoryPage(),
                ),
              );
            },
            icon: const Icon(Icons.insights_outlined),
            tooltip: 'Quiz history and progress',
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log out',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(
                'Learn construction terminology, materials and site practice.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              TextField(
                readOnly: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchPage(),
                    ),
                  );
                },
                decoration: const InputDecoration(
                  hintText: 'Search construction terms...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 28),
              const AppSectionHeader(
                title: 'Term of the Day',
                subtitle: 'A featured article from your library.',
              ),
              const SizedBox(height: 12),
              _buildTermOfTheDay(),
              const SizedBox(height: 28),
              const AppSectionHeader(
                title: 'Categories',
                subtitle: 'Browse terms by construction topic.',
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  return GridView.count(
                    crossAxisCount: isWide ? 3 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: isWide ? 1.35 : 1.08,
                    children: const [
                      CategoryCard(
                        title: 'Materials',
                        icon: Icons.layers_outlined,
                      ),
                      CategoryCard(
                        title: 'Structural',
                        icon: Icons.account_tree_outlined,
                      ),
                      CategoryCard(
                        title: 'Finishing',
                        icon: Icons.format_paint_outlined,
                      ),
                      CategoryCard(
                        title: 'Site Safety',
                        icon: Icons.health_and_safety_outlined,
                      ),
                      CategoryCard(
                        title: 'Tools & Machinery',
                        icon: Icons.precision_manufacturing_outlined,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              const AppSectionHeader(
                title: 'Practice',
                subtitle: 'Check understanding with category quizzes.',
              ),
              const SizedBox(height: 12),
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuizPage(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconBadge(icon: Icons.quiz_outlined),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Take a construction quiz',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.charcoal,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '10 questions per category, scored and saved.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.muted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermOfTheDay() {
    if (_loadingTerm) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(22),
          child: Center(
            child: SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          ),
        ),
      );
    }

    if (_termError != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unable to load today’s term',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                _termError!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _loadTermOfTheDay,
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final article = _termOfTheDay;
    if (article == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No articles are available yet. Terms will appear here once they are added.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticlePage(article: article),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconBadge(icon: iconForCategory(article.category)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    CategoryChip(label: article.category),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
