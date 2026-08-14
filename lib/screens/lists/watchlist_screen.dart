import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/router/app_router.dart';
import '../../models/media_item.dart';
import '../../repositories/media_repository.dart';
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
            _WatchlistTab(query: 'Marvel'),
            _WatchlistTab(query: 'Star Wars'),
            _WatchlistTab(query: 'Avengers'),
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
  final _mediaRepo = MediaRepository();
  List<MediaItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTabMedia();
  }

  void _loadTabMedia() async {
    final results = await _mediaRepo.searchMedia(widget.query);
    if (mounted) {
      setState(() {
        _items = results;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_items.isEmpty) return const Center(child: Text('No titles in this section.'));

    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return ListTile(
          leading: item.poster.isNotEmpty
              ? Image.network(item.poster, width: 40, fit: BoxFit.cover)
              : const Icon(Icons.movie),
          title: Text(item.title),
          subtitle: Text('${item.type.name.toUpperCase()} • ${item.year}'),
          onTap: () {
            Navigator.pushNamed(context, AppRouter.mediaDetail, arguments: item.imdbId);
          },
        );
      },
    );
  }
}