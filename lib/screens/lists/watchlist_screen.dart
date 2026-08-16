import 'package:flutter/material.dart';
import '../../core/router/app_router.dart';
import '../../core/network/http_client.dart';
import '../../core/config/app_config.dart';
import 'custom_lists_screen.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Watchlists'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Watching'),
              Tab(text: 'Plan to Watch'),
              Tab(text: 'Watched'),
              Tab(text: 'Custom Lists'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Matches the exact backend enums for filtering
            _WatchlistTab(query: 'Watching'),
            _WatchlistTab(query: 'Plan to Watch'),
            _WatchlistTab(query: 'Watched'),
            CustomListsScreen(),
          ],
        ),
      ),
    );
  }
}

class _WatchlistTab extends StatefulWidget {
  final String query;
  const _WatchlistTab({required this.query});

  @override
  State<_WatchlistTab> createState() => _WatchlistTabState();
}

class _WatchlistTabState extends State<_WatchlistTab> {
  final _httpClient = HttpClient();
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTabMedia();
  }

  void _loadTabMedia() async {
    try {
      // Fetches all user activity from the backend
      final response = await _httpClient.get('${AppConfig.baseUrl}/activity/user/all');
      final List allActivities = response.data as List;
      
      // Filters the activity locally based on the Tab's watchStatus
      final filtered = allActivities.where((act) => act['watchStatus'] == widget.query).toList();
      
      if (mounted) {
        setState(() {
          _items = filtered;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_items.isEmpty) return const Center(child: Text('No titles in this section.'));

    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final activity = _items[index];
        final media = activity['media'];
        
        // If media was not populated successfully, skip rendering this item
        if (media == null) return const SizedBox.shrink();

        return ListTile(
          leading: media['poster'] != null && media['poster'].isNotEmpty
              ? Image.network(media['poster'], width: 40, fit: BoxFit.cover)
              : const Icon(Icons.movie),
          title: Text(media['title'] ?? 'Unknown Title'),
          subtitle: Text('${media['type'].toString().toUpperCase()} • ${media['year']}'),
          onTap: () {
            Navigator.pushNamed(context, AppRouter.mediaDetail, arguments: media['imdbId']);
          },
        );
      },
    );
  }
}