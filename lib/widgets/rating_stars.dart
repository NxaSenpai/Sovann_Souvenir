import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final int maxStars;
  const RatingStars({super.key, required this.rating, this.size = 16, this.maxStars = 5});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (i) {
        if (i < rating.floor())      return Icon(Icons.star,        color: AppColors.gold, size: size);
        if (i < rating)              return Icon(Icons.star_half,   color: AppColors.gold, size: size);
        return Icon(Icons.star_border, color: AppColors.gold, size: size);
      }),
    );
  }
}