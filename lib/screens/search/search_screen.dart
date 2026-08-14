import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/router/app_router.dart';
import '../../models/enums.dart';
import '../../models/media_item.dart';
import '../../repositories/media_repository.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _mediaRepo = MediaRepository();
  List<MediaItem> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasSearched = true;
    });

    try {
      final results = await _mediaRepo.searchMedia(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch search results. Check network connection.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search movies, series, actors...',
            border: InputBorder.none,
            filled: false,
          ),
          onSubmitted: (_) => _onSearch(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _onSearch,
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchResults.clear();
                  _hasSearched = false;
                });
              },
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (_isLoading) {
            return const LoadingIndicator(message: 'Searching titles...');
          }
          if (_errorMessage != null) {
            return ErrorView(message: _errorMessage!, onRetry: _onSearch);
          }
          if (!_hasSearched) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 72, color: Colors.white24),
                  SizedBox(height: 12),
                  Text('Search for movies and TV series', style: TextStyle(color: Colors.white54)),
                ],
              ),
            );
          }
          if (_searchResults.isEmpty) {
            return const Center(
              child: Text('No results found.', style: TextStyle(color: Colors.white54)),
            );
          }

          return ListView.separated(
            itemCount: _searchResults.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.white10),
            itemBuilder: (context, index) {
              final item = _searchResults[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: item.poster.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.poster,
                          width: 45,
                          height: 65,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 45,
                            height: 65,
                            color: Colors.grey[850],
                            child: const Icon(Icons.movie, size: 20),
                          ),
                        )
                      : Container(
                          width: 45,
                          height: 65,
                          color: Colors.grey[850],
                          child: const Icon(Icons.movie, size: 20),
                        ),
                ),
                title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${item.type == MediaType.series ? "Series" : "Movie"} • ${item.year}'),
                trailing: const Icon(Icons.chevron_right, color: Colors.white30),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.mediaDetail,
                    arguments: item.imdbId,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}