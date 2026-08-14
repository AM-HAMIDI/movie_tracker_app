import 'package:flutter/material.dart';
import '../../core/router/app_router.dart';
import '../../models/media_item.dart';
import '../../repositories/media_repository.dart';

class ListDetailScreen extends StatefulWidget {
  final String listId;
  const ListDetailScreen({super.key, required this.listId});

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  final _mediaRepo = MediaRepository();
  List<MediaItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    // Fetches titles associated with the custom list
    final results = await _mediaRepo.searchMedia('Batman');
    if (mounted) {
      setState(() {
        _items = results;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List Titles')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  leading: item.poster.isNotEmpty
                      ? Image.network(item.poster, width: 40, fit: BoxFit.cover)
                      : const Icon(Icons.movie),
                  title: Text(item.title),
                  subtitle: Text('${item.year} • ${item.type.name}'),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.mediaDetail,
                      arguments: item.imdbId,
                    );
                  },
                );
              },
            ),
    );
  }
}