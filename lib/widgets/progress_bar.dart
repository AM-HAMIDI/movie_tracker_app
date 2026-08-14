import 'package:flutter/material.dart';

class SeriesProgressBar extends StatelessWidget {
  final int watchedCount;
  final int totalCount;
  final String status;

  const SeriesProgressBar({
    super.key,
    required this.watchedCount,
    required this.totalCount,
    this.status = 'Watching',
  });

  Color _getStatusColor() {
    if (watchedCount == 0) return Colors.grey;
    if (watchedCount >= totalCount && totalCount > 0) return const Color(0xFF9C27B0); // Purple
    if (status == 'On Hold' || status == 'Dropped') return const Color(0xFFE53935); // Red
    if (watchedCount < totalCount) return const Color(0xFFFFB300); // Yellow
    return const Color(0xFF4CAF50); // Green
  }

  @override
  Widget build(BuildContext context) {
    final double percent = totalCount > 0 ? (watchedCount / totalCount).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress: $watchedCount / $totalCount Episodes',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            Text(
              '${(percent * 100).toInt()}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: Colors.grey[850],
            valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
          ),
        ),
      ],
    );
  }
}