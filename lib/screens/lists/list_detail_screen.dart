import 'package:flutter/material.dart';
import '../../core/router/app_router.dart';
import '../../models/media_item.dart';
import '../../core/network/http_client.dart';
import '../../core/config/app_config.dart';

class ListDetailScreen extends StatefulWidget {
  final String listId;
  const ListDetailScreen({super.key, required this.listId});

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  List<MediaItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    try {
      // Calls the new backend endpoint to get populated MediaItems for this specific Custom List
      final response = await HttpClient().get('${AppConfig.baseUrl}/activity/lists/${widget.listId}/details');
      final List listData = response.data as List;
      
      if (mounted) {
        setState(() {
          _items = listData.map((e) => MediaItem.fromJson(e as Map<String, dynamic>)).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List Titles')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('This list is empty.'))
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