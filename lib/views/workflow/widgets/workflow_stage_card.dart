import 'package:flutter/material.dart';
import '../../../models/medical_workflow.dart';
import '../../../core/services/workflow_service.dart';
import '../../../core/theme/app_colors.dart';

class WorkflowStageCard extends StatelessWidget {
  final WorkflowStageData stage;
  final Function(WorkflowStatus)? onStatusUpdate;
  final VoidCallback? onAdvance;

  const WorkflowStageCard({
    Key? key,
    required this.stage,
    this.onStatusUpdate,
    this.onAdvance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final workflowService = WorkflowService();
    final stageColor = workflowService.getStageColor(stage.type);
    final statusColor = workflowService.getStatusColor(stage.status);
    final stageIcon = workflowService.getStageIcon(stage.type);

    return Card(
      elevation: stage.status == WorkflowStatus.inProgress ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: stage.status == WorkflowStatus.inProgress
              ? AppColors.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: stageColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    stageIcon,
                    color: stageColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stage.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stage.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(statusColor),
              ],
            ),
            const SizedBox(height: 16),

            // Doctor and Location Info
            if (stage.doctorName != null || stage.location != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    if (stage.doctorName != null) ...[
                      const Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        stage.doctorName!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      if (stage.location != null) const SizedBox(width: 16),
                    ],
                    if (stage.location != null) ...[
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        stage.location!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // Dates
            if (stage.scheduledDate != null || stage.completedDate != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    if (stage.scheduledDate != null) ...[
                      const Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Scheduled: ${_formatDate(stage.scheduledDate!)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    if (stage.completedDate != null) ...[
                      if (stage.scheduledDate != null)
                        const SizedBox(width: 16),
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Completed: ${_formatDate(stage.completedDate!)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // Cost
            if (stage.cost != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Cost: ₹${stage.cost!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

            // Requirements
            if (stage.requirements.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Requirements:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...stage.requirements
                        .map((requirement) => Padding(
                              padding:
                                  const EdgeInsets.only(left: 8, bottom: 2),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.fiber_manual_record,
                                    size: 4,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      requirement,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ],
                ),
              ),

            // Notes
            if (stage.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notes:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...stage.notes
                        .map((note) => Padding(
                              padding:
                                  const EdgeInsets.only(left: 8, bottom: 2),
                              child: Text(
                                '• $note',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ))
                        .toList(),
                  ],
                ),
              ),

            // Action Buttons
            if (stage.status == WorkflowStatus.pending ||
                stage.status == WorkflowStatus.inProgress)
              _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor),
      ),
      child: Text(
        _getStatusText(stage.status),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          if (stage.status == WorkflowStatus.pending)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    onStatusUpdate?.call(WorkflowStatus.inProgress),
                icon: const Icon(Icons.play_arrow, size: 16),
                label: const Text('Start'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          if (stage.status == WorkflowStatus.inProgress) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onAdvance,
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => onStatusUpdate?.call(WorkflowStatus.onHold),
              icon: const Icon(Icons.pause, size: 16),
              label: const Text('Hold'),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getStatusText(WorkflowStatus status) {
    switch (status) {
      case WorkflowStatus.pending:
        return 'PENDING';
      case WorkflowStatus.inProgress:
        return 'IN PROGRESS';
      case WorkflowStatus.completed:
        return 'COMPLETED';
      case WorkflowStatus.cancelled:
        return 'CANCELLED';
      case WorkflowStatus.onHold:
        return 'ON HOLD';
      default:
        return 'UNKNOWN';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
