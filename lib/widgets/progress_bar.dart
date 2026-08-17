import 'package:flutter/material.dart';

class SeriesProgressBar extends StatelessWidget {
  final int watchedCount;
  final int totalCount;
  final String status;
  final String seriesStatus; // Added to determine if a series has ended

  const SeriesProgressBar({
    super.key,
    required this.watchedCount,
    required this.totalCount,
    this.status = 'Watching',
    this.seriesStatus = 'N/A', 
  });

  Color _getStatusColor() {
    // قرمز: کاربر اقدام به توقف تماشا کرده است و قسمت‌ها را به‌صورت کامل مشاهده نکرده است
    if (status == 'On Hold' || status == 'Dropped') return Colors.red;
    
    if (watchedCount >= totalCount && totalCount > 0) {
      // بنفش: تمامی قسمت‌ها مشاهده شده است و دیگر قسمت جدیدی برای آن منتشر نخواهد شد
      if (seriesStatus == 'Ended' || status == 'Completed') {
        return Colors.purple; 
      }
      // سبز: تمامی قسمت‌ها مشاهده شده است اما قسمت‌های بعدی در آینده منتشر خواهند شد
      return Colors.green;
    }
    
    // Default active watching state
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    // Use true percentage based on actual totalCount
    final double percent = totalCount > 0 ? (watchedCount / totalCount).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              totalCount > 0 
                  ? 'Progress: $watchedCount / $totalCount Episodes'
                  : 'Progress: $watchedCount Episodes Watched',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            // Always show the percentage text as requested
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
            // مشکی یا بی‌رنگ: قسمت‌های مشاهده‌نشده
            backgroundColor: Colors.black, 
            valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
          ),
        ),
      ],
    );
  }
}