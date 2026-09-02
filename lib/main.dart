import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/signup_page.dart';
import 'screens/login_page.dart';
//Hi this is testing comment
void main() async {
  // Make sure Flutter is initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Start the Constropedia application
  runApp(const ConstropediaApp());
}

class ConstropediaApp extends StatelessWidget {
  const ConstropediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Constropedia',

      // App theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
        ),
        useMaterial3: true,
      ),

      // App routes
      routes: {
        '/signup': (context) => const SignupPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomeScreen(),
      },

      // Starting screen
      home: const LoginPage(),
    );
  }
}


// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Constropedia',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.bookmark_outline),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ==================================================
            // WELCOME
            // ==================================================

            const Text(
              'Welcome to Constropedia 👋',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Learn construction concepts, materials and practices.',
              style: TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 20),


            // ==================================================
            // SEARCH BAR
            // ==================================================

            TextField(
              decoration: InputDecoration(
                hintText: 'Search construction terms...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 25),


            // ==================================================
            // TERM OF THE DAY
            // ==================================================

            const Text(
              'Term of the Day',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [

                    const Icon(
                      Icons.foundation,
                      size: 45,
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [

                          Text(
                            'Reinforced Concrete',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            'Concrete strengthened using steel reinforcement.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),


            // ==================================================
            // CATEGORIES
            // ==================================================

            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,

              children: const [

                CategoryCard(
                  title: 'Materials',
                  icon: Icons.construction,
                ),

                CategoryCard(
                  title: 'Structural',
                  icon: Icons.account_tree,
                ),

                CategoryCard(
                  title: 'Finishing',
                  icon: Icons.format_paint,
                ),

                CategoryCard(
                  title: 'Site Safety',
                  icon: Icons.health_and_safety,
                ),

                CategoryCard(
                  title: 'Tools & Machinery',
                  icon: Icons.engineering,
                ),
              ],
            ),

            const SizedBox(height: 25),


            // ==================================================
            // QUIZ SECTION
            // ==================================================

            const Text(
              'Test Your Knowledge 🧠',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: const Icon(Icons.quiz),

                title: const Text(
                  'Take a Construction Quiz',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: const Text(
                  'Test yourself with category-wise questions.',
                ),

                trailing: const Icon(
                  Icons.arrow_forward_ios,
                ),

                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// CATEGORY CARD
// ============================================================

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),

        onTap: () {},

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              icon,
              size: 40,
            ),

            const SizedBox(height: 10),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
