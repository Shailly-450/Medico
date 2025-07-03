import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/test_checkup.dart';

class TestCheckupCard extends StatelessWidget {
  final TestCheckup checkup;
  final VoidCallback? onTap;
  final VoidCallback? onMarkCompleted;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;

  const TestCheckupCard({
    Key? key,
    required this.checkup,
    this.onTap,
    this.onMarkCompleted,
    this.onCancel,
    this.onReschedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with type, status, and priority
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      checkup.typeDisplayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getTypeColor(),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      checkup.statusDisplayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      checkup.priorityDisplayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getPriorityColor(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title and description
              Text(
                checkup.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                checkup.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),

              // Date and time
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    checkup.formattedDateTime,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Location
              if (checkup.location != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        checkup.location!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Doctor info
              if (checkup.doctorName != null) ...[
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: checkup.doctorImage != null
                          ? NetworkImage(checkup.doctorImage!)
                          : null,
                      child: checkup.doctorImage == null
                          ? const Icon(Icons.person, size: 16)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            checkup.doctorName!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (checkup.doctorSpecialty != null)
                            Text(
                              checkup.doctorSpecialty!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Cost
              if (checkup.estimatedCost != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Estimated: \$${checkup.estimatedCost!.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Special requirements
              if (checkup.requiresFasting || checkup.requiresPreparation) ...[
                Row(
                  children: [
                    Icon(
                      Icons.warning,
                      size: 16,
                      color: Colors.orange[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      checkup.requiresFasting
                          ? 'Fasting required'
                          : 'Preparation required',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Action buttons
              if (checkup.status != TestCheckupStatus.completed &&
                  checkup.status != TestCheckupStatus.cancelled) ...[
                Row(
                  children: [
                    if (onMarkCompleted != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onMarkCompleted,
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Complete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    if (onMarkCompleted != null && onReschedule != null)
                      const SizedBox(width: 8),
                    if (onReschedule != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onReschedule,
                          icon: const Icon(Icons.schedule, size: 16),
                          label: const Text('Reschedule'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    if (onReschedule != null && onCancel != null)
                      const SizedBox(width: 8),
                    if (onCancel != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onCancel,
                          icon: const Icon(Icons.cancel, size: 16),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (checkup.type) {
      case TestCheckupType.bloodTest:
      case TestCheckupType.urineTest:
        return Colors.red;
      case TestCheckupType.xRay:
      case TestCheckupType.mri:
      case TestCheckupType.ctScan:
      case TestCheckupType.ultrasound:
        return Colors.blue;
      case TestCheckupType.ecg:
      case TestCheckupType.stressTest:
        return Colors.purple;
      case TestCheckupType.endoscopy:
      case TestCheckupType.colonoscopy:
        return Colors.orange;
      case TestCheckupType.mammogram:
      case TestCheckupType.papSmear:
        return Colors.pink;
      case TestCheckupType.dentalCheckup:
        return Colors.teal;
      case TestCheckupType.eyeExam:
        return Colors.indigo;
      case TestCheckupType.hearingTest:
        return Colors.cyan;
      case TestCheckupType.skinCheck:
        return Colors.brown;
      case TestCheckupType.physicalExam:
        return Colors.green;
      case TestCheckupType.vaccination:
        return Colors.lime;
      case TestCheckupType.allergyTest:
        return Colors.amber;
      case TestCheckupType.sleepStudy:
        return Colors.deepPurple;
      case TestCheckupType.custom:
        return Colors.grey;
    }
  }

  Color _getStatusColor() {
    switch (checkup.status) {
      case TestCheckupStatus.scheduled:
        return Colors.blue;
      case TestCheckupStatus.completed:
        return Colors.green;
      case TestCheckupStatus.cancelled:
        return Colors.red;
      case TestCheckupStatus.rescheduled:
        return Colors.orange;
      case TestCheckupStatus.overdue:
        return Colors.red;
      case TestCheckupStatus.pendingResults:
        return Colors.purple;
    }
  }

  Color _getPriorityColor() {
    switch (checkup.priority) {
      case TestCheckupPriority.low:
        return Colors.green;
      case TestCheckupPriority.medium:
        return Colors.orange;
      case TestCheckupPriority.high:
        return Colors.red;
      case TestCheckupPriority.urgent:
        return Colors.purple;
    }
  }
}
