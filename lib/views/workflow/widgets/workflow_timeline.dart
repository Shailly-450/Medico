import 'package:flutter/material.dart';
import '../../../models/medical_workflow.dart';
import '../../../core/services/workflow_service.dart';
import '../../../core/theme/app_colors.dart';

class WorkflowTimeline extends StatelessWidget {
  final MedicalWorkflow workflow;

  const WorkflowTimeline({
    Key? key,
    required this.workflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Treatment Timeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildTimelineView(),
        ],
      ),
    );
  }

  Widget _buildTimelineView() {
    final workflowService = WorkflowService();
    final sortedStages = List<WorkflowStageData>.from(workflow.stages)
      ..sort((a, b) => a.order.compareTo(b.order));

    return Column(
      children: sortedStages.asMap().entries.map((entry) {
        final index = entry.key;
        final stage = entry.value;
        final isLast = index == sortedStages.length - 1;

        return _buildTimelineItem(
          stage: stage,
          isLast: isLast,
          workflowService: workflowService,
        );
      }).toList(),
    );
  }

  Widget _buildTimelineItem({
    required WorkflowStageData stage,
    required bool isLast,
    required WorkflowService workflowService,
  }) {
    final stageColor = workflowService.getStageColor(stage.type);
    final statusColor = workflowService.getStatusColor(stage.status);
    final stageIcon = workflowService.getStageIcon(stage.type);

    final isCompleted = stage.status == WorkflowStatus.completed;
    final isInProgress = stage.status == WorkflowStatus.inProgress;
    final isPending = stage.status == WorkflowStatus.pending;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green
                      : isInProgress
                          ? AppColors.primary
                          : Colors.grey.shade300,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted
                        ? Colors.green
                        : isInProgress
                            ? AppColors.primary
                            : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check
                      : isInProgress
                          ? stageIcon
                          : stageIcon,
                  color: isCompleted
                      ? Colors.white
                      : isInProgress
                          ? Colors.white
                          : Colors.grey.shade600,
                  size: 20,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: isCompleted
                      ? Colors.green.shade300
                      : Colors.grey.shade300,
                ),
            ],
          ),

          const SizedBox(width: 16),

          // Stage content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Card(
                elevation: isInProgress ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color:
                        isInProgress ? AppColors.primary : Colors.transparent,
                    width: isInProgress ? 2 : 0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stage.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isInProgress ? AppColors.primary : null,
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
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
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Stage details
                      if (stage.doctorName != null || stage.location != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
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
                                if (stage.location != null)
                                  const SizedBox(width: 16),
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
                      if (stage.scheduledDate != null ||
                          stage.completedDate != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (stage.scheduledDate != null)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.schedule,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Scheduled: ${_formatDateTime(stage.scheduledDate!)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              if (stage.completedDate != null)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Completed: ${_formatDateTime(stage.completedDate!)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),

                      // Cost
                      if (stage.cost != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.attach_money,
                                size: 16,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Cost: ₹${stage.cost!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Progress indicator for in-progress stage
                      if (isInProgress)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Currently in progress...',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Notes for completed stages
                      if (isCompleted && stage.notes.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Notes:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ...stage.notes
                                  .map((note) => Text(
                                        '• $note',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.green,
                                        ),
                                      ))
                                  .toList(),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
