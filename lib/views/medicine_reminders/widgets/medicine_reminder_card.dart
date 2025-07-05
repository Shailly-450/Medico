import 'package:flutter/material.dart';
import '../../../models/medicine_reminder.dart';
import '../../../core/theme/app_colors.dart';
import '../../shared/app_card.dart';

class MedicineReminderCard extends StatelessWidget {
  final MedicineReminder reminder;
  final VoidCallback? onTap;
  final VoidCallback? onTakeDose;
  final VoidCallback? onSkipDose;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPause;
  final VoidCallback? onRefill;
  final bool showDoseActions;
  final bool isOverdue;

  const MedicineReminderCard({
    Key? key,
    required this.reminder,
    this.onTap,
    this.onTakeDose,
    this.onSkipDose,
    this.onEdit,
    this.onDelete,
    this.onPause,
    this.onRefill,
    this.showDoseActions = false,
    this.isOverdue = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildMedicineInfo(),
                const SizedBox(height: 12),
                _buildReminderInfo(),
                if (reminder.instructions != null) ...[
                  const SizedBox(height: 8),
                  _buildInstructions(),
                ],
                if (showDoseActions) ...[
                  const SizedBox(height: 16),
                  _buildDoseActions(),
                ] else if (onEdit != null ||
                    onDelete != null ||
                    onPause != null) ...[
                  const SizedBox(height: 16),
                  _buildManagementActions(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reminder.reminderName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                reminder.frequencyDescription,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildMedicineInfo() {
    if (reminder.medicine == null) return const SizedBox.shrink();

    final medicine = reminder.medicine!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.medication,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${medicine.dosage} • ${medicine.medicineType}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (medicine.needsRefill)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Refill',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (onRefill != null)
                  GestureDetector(
                    onTap: onRefill,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildReminderInfo() {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 16,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 4),
        Text(
          _getNextDoseText(),
          style: TextStyle(
            color: isOverdue ? Colors.red : Colors.grey[600],
            fontSize: 12,
            fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        const Spacer(),
        if (reminder.totalDoses != null) ...[
          Icon(
            Icons.track_changes,
            size: 16,
            color: Colors.grey[500],
          ),
          const SizedBox(width: 4),
          Text(
            '${reminder.dosesCompleted}/${reminder.totalDoses}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.blue,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              reminder.instructions!,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoseActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onTakeDose,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Take Dose'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onSkipDose,
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Skip'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManagementActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onPause != null)
          TextButton.icon(
            onPressed: onPause,
            icon: Icon(
              reminder.status == ReminderStatus.active
                  ? Icons.pause
                  : Icons.play_arrow,
              size: 16,
            ),
            label: Text(
              reminder.status == ReminderStatus.active ? 'Pause' : 'Resume',
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
          ),
        if (onEdit != null)
          TextButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
            ),
          ),
        if (onDelete != null)
          TextButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('Delete'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(),
        style: TextStyle(
          color: _getStatusColor(),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (isOverdue) return Colors.red;

    switch (reminder.status) {
      case ReminderStatus.active:
        return Colors.green;
      case ReminderStatus.paused:
        return Colors.orange;
      case ReminderStatus.completed:
        return Colors.blue;
      case ReminderStatus.skipped:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    if (isOverdue) return Icons.warning;

    switch (reminder.status) {
      case ReminderStatus.active:
        return Icons.notifications_active;
      case ReminderStatus.paused:
        return Icons.pause;
      case ReminderStatus.completed:
        return Icons.check_circle;
      case ReminderStatus.skipped:
        return Icons.cancel;
    }
  }

  String _getStatusText() {
    if (isOverdue) return 'OVERDUE';

    switch (reminder.status) {
      case ReminderStatus.active:
        return 'ACTIVE';
      case ReminderStatus.paused:
        return 'PAUSED';
      case ReminderStatus.completed:
        return 'COMPLETED';
      case ReminderStatus.skipped:
        return 'SKIPPED';
    }
  }

  String _getNextDoseText() {
    if (isOverdue) return 'Overdue';

    final nextTime = reminder.nextReminderTime;
    if (nextTime == null) return 'No upcoming doses';

    final now = DateTime.now();
    final difference = nextTime.difference(now);

    if (difference.inDays > 0) {
      return 'Next: ${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return 'Next: ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'Next: ${difference.inMinutes}m';
    } else {
      return 'Due now';
    }
  }
}
