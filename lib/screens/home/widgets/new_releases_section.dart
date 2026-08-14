import 'package:flutter/material.dart';
import '../../../core/router/app_router.dart';
import '../../../models/media_item.dart';
import '../../../widgets/media_card.dart';

class NewReleasesSection extends StatelessWidget {
  final List<MediaItem> items;

  const NewReleasesSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            '✨ New Releases',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return MediaCard(
                item: item,
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
        ),
      ],
    );
  }
}