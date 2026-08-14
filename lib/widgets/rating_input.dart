import 'package:flutter/material.dart';

class RatingInput extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;

  const RatingInput({
    super.key,
    required this.rating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return IconButton(
          icon: Icon(
            starValue <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
            color: Colors.amber,
            size: 32,
          ),
          onPressed: () {
            // If tapping already selected rating, reset to 0
            if (rating == starValue) {
              onRatingChanged(0);
            } else {
              onRatingChanged(starValue);
            }
          },
        );
      }),
    );
  }
}