import 'package:flutter/material.dart';
import '../models/enums.dart';

class WatchStatusSelector extends StatelessWidget {
  final String currentStatus;
  final ValueChanged<String> onStatusChanged;

  const WatchStatusSelector({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  static const List<String> _statuses = [
    'None',
    'Plan to Watch',
    'Watching',
    'Watched',
    'On Hold',
    'Dropped',
    'Favorite',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedValue = _statuses.contains(currentStatus) ? currentStatus : 'None';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurpleAccent),
          items: _statuses.map((status) {
            return DropdownMenuItem<String>(
              value: status,
              child: Text(
                status,
                style: TextStyle(
                  color: status == selectedValue ? Colors.deepPurpleAccent : Colors.white,
                  fontWeight: status == selectedValue ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) onStatusChanged(val);
          },
        ),
      ),
    );
  }
}