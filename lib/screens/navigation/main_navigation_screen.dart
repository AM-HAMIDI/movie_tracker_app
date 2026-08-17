import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import '../search/search_screen.dart';
import '../lists/watchlist_screen.dart';
import '../profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Check if the current user is a guest
    final isGuest = context.watch<AuthProvider>().isGuest;

    // Dynamically build screens based on role
    final List<Widget> screens = [
      const HomeScreen(),
      const SearchScreen(),
      isGuest ? const _GuestLoginPrompt(title: 'Watchlists', icon: Icons.bookmarks_outlined) : const WatchlistScreen(),
      isGuest ? const _GuestLoginPrompt(title: 'Profile', icon: Icons.person_outline) : const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmarks_outlined), label: 'Lists'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

// Reusable widget to show guests that they need an account
class _GuestLoginPrompt extends StatelessWidget {
  final String title;
  final IconData icon;

  const _GuestLoginPrompt({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 80, color: Colors.white54),
              const SizedBox(height: 16),
              Text(
                'Create an account to access $title.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await context.read<AuthProvider>().logout(); // Clear guest session
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, AppRouter.login);
                  }
                },
                child: const Text('Login / Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}