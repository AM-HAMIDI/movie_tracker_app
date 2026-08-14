import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/media_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';
import 'widgets/popular_section.dart';
import 'widgets/new_releases_section.dart';
import 'widgets/recommended_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mediaProvider = context.read<MediaProvider>();
      if (mediaProvider.popularTitles.isEmpty) {
        mediaProvider.fetchHomeDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaProvider = context.watch<MediaProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => mediaProvider.fetchHomeDashboard(),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (mediaProvider.isLoadingHome) {
            return const LoadingIndicator(message: 'Loading titles...');
          }

          if (mediaProvider.homeErrorMessage != null) {
            return ErrorView(
              message: mediaProvider.homeErrorMessage!,
              onRetry: () => mediaProvider.fetchHomeDashboard(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => mediaProvider.fetchHomeDashboard(),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                PopularSection(items: mediaProvider.popularTitles),
                const SizedBox(height: 16),
                NewReleasesSection(items: mediaProvider.newReleases),
                const SizedBox(height: 16),
                RecommendedSection(items: mediaProvider.recommendedTitles),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}