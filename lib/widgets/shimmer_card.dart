import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class ShimmerCard extends StatelessWidget {
  final double width;
  final double height;
  const ShimmerCard({super.key, this.width = 180, this.height = 220});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGray,
      highlightColor: Colors.white,
      child: Container(
        width: width, height: height,
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}