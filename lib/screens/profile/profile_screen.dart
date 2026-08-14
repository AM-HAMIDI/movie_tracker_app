import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/activity_provider.dart';
import '../../widgets/loading_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().fetchUserStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final activityProvider = context.watch<ActivityProvider>();
    final stats = activityProvider.userStats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRouter.editProfile),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, AppRouter.login, (r) => false);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.deepPurpleAccent,
                  child: Icon(Icons.person, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(user?.fullName ?? 'User', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('@${user?.username ?? ""}', style: const TextStyle(color: Colors.white54)),
                if (user?.bio.isNotEmpty ?? false) ...[
                  const SizedBox(height: 6),
                  Text(user!.bio, style: const TextStyle(color: Colors.white70)),
                ],
              ],
            ),
          ),
          const Divider(height: 36),
          const Text('📊 Activity Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (activityProvider.isLoading)
            const LoadingIndicator(message: 'Calculating activity statistics...')
          else if (stats != null) ...[
            _StatCard(title: 'Watched Movies', value: '${stats.watchedMovies}'),
            _StatCard(title: 'Watched Series', value: '${stats.watchedSeries}'),
            _StatCard(title: 'Total Episodes Logged', value: '${stats.totalEpisodes}'),
            _StatCard(title: 'Favorite Genre', value: stats.favoriteGenre),
            _StatCard(title: 'Average Rating Given', value: '${stats.averageRating} ⭐'),
            _StatCard(
              title: 'Total Estimated Watch Time',
              value: '${(stats.totalWatchTimeMinutes / 60).toStringAsFixed(1)} Hours',
            ),
          ] else
            const Center(child: Text('No activity logged yet.')),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 14)),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
            ),
          ],
        ),
      ),
    );
  }
}