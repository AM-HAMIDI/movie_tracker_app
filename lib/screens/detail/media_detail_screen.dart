import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/enums.dart';
import '../../models/media_item.dart';
import '../../providers/activity_provider.dart';
import '../../repositories/media_repository.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/watch_status_selector.dart';
import '../../widgets/rating_input.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/add_to_list_sheet.dart'; 
import 'widgets/episode_accordion.dart';
import 'widgets/comment_section.dart';

class MediaDetailScreen extends StatefulWidget {
  final String imdbId;
  const MediaDetailScreen({super.key, required this.imdbId});

  @override
  State<MediaDetailScreen> createState() => _MediaDetailScreenState();
}

class _MediaDetailScreenState extends State<MediaDetailScreen> {
  final _mediaRepo = MediaRepository();
  MediaItem? _media;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  void _loadMedia() async {
    final media = await _mediaRepo.getMediaDetail(widget.imdbId);
    if (mounted) {
      context.read<ActivityProvider>().fetchMediaActivity(widget.imdbId);
      setState(() {
        _media = media;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: LoadingIndicator(message: 'Loading details...'));
    }
    if (_media == null) {
      return const Scaffold(body: Center(child: Text('Failed to load title details.')));
    }

    final activity = context.watch<ActivityProvider>().currentActivity;
    final String currentStatus = activity['watchStatus'] ?? 'None';
    final int currentRating = activity['rating'] ?? 0;
    final List<String> watchedEpisodes = List<String>.from(activity['watchedEpisodes'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text(_media!.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            tooltip: 'Add to Custom List',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => AddToListSheet(imdbId: widget.imdbId),
              );
            },
          ),
          IconButton(
            icon: Icon(
              (activity['isFavorite'] ?? false) ? Icons.favorite : Icons.favorite_border,
              color: (activity['isFavorite'] ?? false) ? Colors.redAccent : Colors.white,
            ),
            onPressed: () => context.read<ActivityProvider>().toggleFavorite(widget.imdbId),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _media!.poster.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: _media!.poster,
                        width: 120,
                        height: 180,
                        fit: BoxFit.cover,
                      )
                    : Container(width: 120, height: 180, color: Colors.grey[850]),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_media!.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${_media!.type == MediaType.series ? "Series" : "Movie"} • ${_media!.year}', style: const TextStyle(color: Colors.white54)),
                    const SizedBox(height: 8),
                    
                    Text('Genre: ${_media!.genre}', style: const TextStyle(color: Colors.white70)),
                    Text('Director: ${_media!.director}', style: const TextStyle(color: Colors.white70)),
                    Text('Actors: ${_media!.actors}', style: const TextStyle(color: Colors.white70)),
                    Text('Status: ${_media!.status}', style: const TextStyle(color: Colors.white70)),
                    
                    if (_media!.type == MediaType.series)
                      Text(
                        'Seasons: ${_media!.totalSeasons} | Episodes: ${_media!.totalEpisodes > 0 ? _media!.totalEpisodes : "N/A"}', 
                        style: const TextStyle(color: Colors.white70)
                      ),
                    
                    const SizedBox(height: 4),
                    Text('IMDb Rating: ${_media!.imdbRating} ⭐', style: const TextStyle(color: Colors.amberAccent)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Watch Status', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          WatchStatusSelector(
            currentStatus: currentStatus,
            onStatusChanged: (newStatus) {
              context.read<ActivityProvider>().updateWatchStatus(widget.imdbId, newStatus);
            },
          ),
          const SizedBox(height: 16),
          const Text('Your Rating', style: TextStyle(fontWeight: FontWeight.bold)),
          RatingInput(
            rating: currentRating,
            onRatingChanged: (rating) {
              context.read<ActivityProvider>().updateRating(widget.imdbId, rating);
            },
          ),
          if (_media!.type == MediaType.series && _media!.totalSeasons > 0) ...[
            const Divider(height: 24),
            SeriesProgressBar(
              watchedCount: watchedEpisodes.length,
              totalCount: _media!.totalSeasons * 8, 
              status: currentStatus,
            ),
            const SizedBox(height: 16),
            const Text('Seasons & Episodes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            EpisodeAccordion(
              imdbId: widget.imdbId,
              totalSeasons: _media!.totalSeasons,
              watchedEpisodes: watchedEpisodes,
              onWatchedChanged: (updatedList) {
                context.read<ActivityProvider>().updateWatchedEpisodes(widget.imdbId, updatedList);
              },
            ),
          ],
          const Divider(height: 32),
          const Text('Plot Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(_media!.plot, style: const TextStyle(color: Colors.white70, height: 1.4)),
          const Divider(height: 32),
          CommentSection(imdbId: widget.imdbId),
        ],
      ),
    );
  }
}