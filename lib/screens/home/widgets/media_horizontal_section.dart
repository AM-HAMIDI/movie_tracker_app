import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/media_item.dart';
import '../../detail/media_detail_screen.dart'; // Ensure this path matches your project

class MediaHorizontalSection extends StatelessWidget {
  final String title;
  final List<MediaItem> items;

  const MediaHorizontalSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          // Clean title with no icons
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220, // Height for poster + title text
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to your detail screen when tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MediaDetailScreen(imdbId: item.imdbId),
                    ),
                  );
                },
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: item.poster.isNotEmpty && item.poster != 'N/A'
                            ? CachedNetworkImage(
                                imageUrl: item.poster,
                                width: 120,
                                height: 170,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 120,
                                  height: 170,
                                  color: Colors.grey[850],
                                  child: const Center(child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 120,
                                  height: 170,
                                  color: Colors.grey[850],
                                  child: const Icon(Icons.broken_image, color: Colors.white54),
                                ),
                              )
                            : Container(
                                width: 120,
                                height: 170,
                                color: Colors.grey[850],
                                child: const Icon(Icons.movie, color: Colors.white54),
                              ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}