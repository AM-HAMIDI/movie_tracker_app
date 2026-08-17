import 'package:flutter/material.dart';

class SeriesProgressBar extends StatelessWidget {
  final int watchedCount;
  final int totalCount;
  final String status; // User's watch status
  final String seriesStatus; // Global series status (e.g., 'Ended', 'Ongoing')

  const SeriesProgressBar({
    super.key,
    required this.watchedCount,
    required this.totalCount,
    required this.status,
    this.seriesStatus = '',
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress percentage, ensuring it stays between 0.0 and 1.0
    final double percentage = totalCount > 0 
        ? (watchedCount / totalCount).clamp(0.0, 1.0) 
        : 0.0;
        
    final bool isAllWatched = (watchedCount == totalCount && totalCount > 0);

    // Default color for standard "Watching" progress
    Color barColor = Colors.blueAccent; 

    // 1. Red: User stopped/dropped watching
    if (status.toLowerCase() == 'dropped' || status.toLowerCase() == 'paused' || status.toLowerCase() == 'stopped') {
      barColor = Colors.red;
    } 
    // All available episodes are watched
    else if (isAllWatched) {
      // 2. Purple: All watched and no new episodes (Series has ended)
      if (seriesStatus.toLowerCase() == 'ended' || seriesStatus.toLowerCase() == 'finished' || seriesStatus.toLowerCase() == 'canceled') {
        barColor = Colors.purple;
      } 
      // 3. Green: All watched but future episodes are coming (Series is ongoing)
      else {
        barColor = Colors.green;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Progress', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '${(percentage * 100).toInt()}% ($watchedCount / $totalCount)', 
              style: const TextStyle(color: Colors.white70, fontSize: 12)
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 12, 
          width: double.infinity,
          decoration: BoxDecoration(
            // 4. Black/Transparent for unwatched portions
            color: Colors.black.withOpacity(0.6), 
            borderRadius: BorderRadius.circular(6),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}