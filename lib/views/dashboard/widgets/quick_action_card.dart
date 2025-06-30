import 'package:flutter/material.dart';
import '../../shared/app_card.dart';
import '../../../core/theme/app_colors.dart';

class QuickActionCard extends StatelessWidget {
  final Map<String, dynamic> action;

  const QuickActionCard({
    Key? key,
    required this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      border: Border.all(color: AppColors.secondary.withOpacity(0.8), width: 1.2),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: action['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              action['icon'],
              color: action['color'],
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            action['title'],
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 