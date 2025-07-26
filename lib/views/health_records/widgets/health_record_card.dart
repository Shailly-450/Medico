import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/health_record.dart';
import '../../../models/family_member.dart';
import '../../../viewmodels/family_members_view_model.dart';
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                record.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            // Family Member Indicator
                            Consumer<FamilyMembersViewModel>(
                              builder: (context, familyVM, child) {
                                final familyMember =
                                    familyVM.members.firstWhere(
                                  (member) =>
                                      member.id == record.familyMemberId,
                                  orElse: () => FamilyMember(
                                      id: '',
                                      name: 'Unknown',
                                      role: '',
                                      imageUrl: ''),
                                );

                                return Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  child: CircleAvatar(
                                    radius: 10,
                                    backgroundImage: familyMember
                                            .imageUrl.isNotEmpty
                                        ? NetworkImage(familyMember.imageUrl)
                                        : null,
                                    backgroundColor:
                                        AppColors.primary.withOpacity(0.2),
                                    child: familyMember.imageUrl.isEmpty
                                        ? Text(
                                            familyMember.name.isNotEmpty
                                                ? familyMember.name[0]
                                                    .toUpperCase()
                                                : '?',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(record.date),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Important Badge
                  if (record.isImportant)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
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
              if (record.description != null && record.description!.isNotEmpty)
                Text(
                  record.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

              const SizedBox(height: 12),

              // Provider Info
              if (record.provider != null && record.provider!.isNotEmpty)
                Row(
                  children: [
                    if (record.providerImage != null &&
                        record.providerImage!.isNotEmpty)
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage(record.providerImage!),
                      ),
                    if (record.providerImage != null &&
                        record.providerImage!.isNotEmpty)
                      const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        record.provider!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
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
                    tooltip: record.isImportant
                        ? 'Remove from important'
                        : 'Mark as important',
                  ),
                  if (record.attachments != null &&
                      record.attachments!.isNotEmpty)
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
