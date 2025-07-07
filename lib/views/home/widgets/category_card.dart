import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;

  const CategoryCard({
    Key? key,
    required this.icon,
    required this.title,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = isActive ? AppColors.primary : AppColors.secondary;
    final iconColor = isActive ? Colors.white : AppColors.primary;
    final textColor = isActive ? Colors.white : AppColors.primary;
    final fontWeight = isActive ? FontWeight.bold : FontWeight.w500;

    return Card(
      elevation: 0,
      color: bgColor,
      margin: const EdgeInsets.only(right: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: textColor,
                fontWeight: fontWeight,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
} 