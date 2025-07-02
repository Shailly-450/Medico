import 'package:flutter/material.dart';
import '../../../models/health_record.dart';
import '../../../core/theme/app_colors.dart';

class HealthRecordCard extends StatelessWidget {
  final HealthRecord record;
  final VoidCallback onTap;
  final VoidCallback onImportantToggle;
  final VoidCallback onDelete;

  const HealthRecordCard({
    Key? key,
    required this.record,
    required this.onTap,
    required this.onImportantToggle,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Category Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(record.category),
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title and Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textBlack,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(record.date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Important Badge
                  if (record.isImportant)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Important',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Text(
                record.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              
              const SizedBox(height: 12),
              
              // Provider Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(record.providerImage),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      record.provider,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: onImportantToggle,
                    icon: Icon(
                      record.isImportant ? Icons.star : Icons.star_border,
                      color: record.isImportant ? Colors.amber : Colors.grey,
                      size: 20,
                    ),
                    tooltip: record.isImportant ? 'Remove from important' : 'Mark as important',
                  ),
                  if (record.attachmentUrl != null)
                    IconButton(
                      onPressed: () {
                        // Handle attachment download/view
                      },
                      icon: const Icon(
                        Icons.attachment,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      tooltip: 'View attachment',
                    ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    tooltip: 'Delete record',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Vital Signs':
        return Icons.favorite;
      case 'Lab Results':
        return Icons.science;
      case 'Medications':
        return Icons.medication;
      case 'Appointments':
        return Icons.calendar_today;
      case 'Procedures':
        return Icons.medical_services;
      case 'Immunizations':
        return Icons.vaccines;
      case 'Allergies':
        return Icons.warning;
      case 'Conditions':
        return Icons.health_and_safety;
      default:
        return Icons.medical_information;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
} 