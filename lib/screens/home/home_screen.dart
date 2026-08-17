import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/media_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';
import 'widgets/media_horizontal_section.dart';

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
      // Check if data is already loaded before fetching
      if (mediaProvider.popularMovies.isEmpty) {
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                MediaHorizontalSection(
                  title: 'Popular Movies',
                  items: mediaProvider.popularMovies,
                ),
                const SizedBox(height: 24),
                
                MediaHorizontalSection(
                  title: 'Popular Series',
                  items: mediaProvider.popularSeries,
                ),
                const SizedBox(height: 24),
                
                MediaHorizontalSection(
                  title: 'New Releases',
                  items: mediaProvider.newReleases,
                ),
                const SizedBox(height: 24),
                
                MediaHorizontalSection(
                  title: 'High IMDb Ratings',
                  items: mediaProvider.highRatedTitles,
                ),
                const SizedBox(height: 24),
                
                MediaHorizontalSection(
                  title: 'Recommended For You',
                  items: mediaProvider.recommendedTitles,
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}