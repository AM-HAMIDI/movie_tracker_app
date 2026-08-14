import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/media_item.dart';
import '../models/enums.dart';

class MediaCard extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onTap;
  final double width;
  final double height;

  const MediaCard({
    super.key,
    required this.item,
    required this.onTap,
    this.width = 130,
    this.height = 190,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    item.poster.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: item.poster,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[900],
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[850],
                              child: const Icon(Icons.movie, color: Colors.white24, size: 36),
                            ),
                          )
                        : Container(
                            color: Colors.grey[850],
                            child: const Icon(Icons.movie, color: Colors.white24, size: 36),
                          ),
                    if (item.imdbRating.isNotEmpty && item.imdbRating != 'N/A')
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 12),
                              const SizedBox(width: 2),
                              Text(
                                item.imdbRating,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            Text(
              '${item.type == MediaType.series ? "Series" : "Movie"} • ${item.year}',
              style: const TextStyle(fontSize: 11, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}