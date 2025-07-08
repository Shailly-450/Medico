import 'package:flutter/material.dart';
import '../../../models/medical_workflow.dart';
import '../../../core/theme/app_colors.dart';

class WorkflowHeader extends StatelessWidget {
  final MedicalWorkflow workflow;

  const WorkflowHeader({
    Key? key,
    required this.workflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              workflow.patientName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (workflow.isUrgent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red),
                              ),
                              child: const Text(
                                'URGENT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        workflow.condition,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${workflow.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Primary Doctor Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.medical_services,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Primary Doctor',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          workflow.primaryDoctorName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Workflow Status Row
            Row(
              children: [
                Expanded(
                  child: _buildStatusItem(
                    'Current Stage',
                    _getCurrentStageText(),
                    _getCurrentStageIcon(),
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusItem(
                    'Status',
                    _getOverallStatusText(),
                    _getOverallStatusIcon(),
                    _getOverallStatusColor(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress and Dates Row
            Row(
              children: [
                Expanded(
                  child: _buildStatusItem(
                    'Progress',
                    '${workflow.progressPercentage.toInt()}%',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusItem(
                    'Created',
                    _formatDate(workflow.createdDate),
                    Icons.calendar_today,
                    Colors.grey,
                  ),
                ),
              ],
            ),

            // Total Cost if available
            if (workflow.totalCost > 0) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.attach_money,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Estimated Cost',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '₹${workflow.totalCost.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Duration if available
            if (workflow.duration != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Duration: ${_formatDuration(workflow.duration!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentStageText() {
    switch (workflow.currentStage) {
      case WorkflowStage.consultation:
        return 'Consultation';
      case WorkflowStage.testing:
        return 'Testing';
      case WorkflowStage.surgery:
        return 'Surgery';
      case WorkflowStage.completed:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  IconData _getCurrentStageIcon() {
    switch (workflow.currentStage) {
      case WorkflowStage.consultation:
        return Icons.medical_services;
      case WorkflowStage.testing:
        return Icons.science;
      case WorkflowStage.surgery:
        return Icons.local_hospital;
      case WorkflowStage.completed:
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  String _getOverallStatusText() {
    switch (workflow.overallStatus) {
      case WorkflowStatus.pending:
        return 'Pending';
      case WorkflowStatus.inProgress:
        return 'In Progress';
      case WorkflowStatus.completed:
        return 'Completed';
      case WorkflowStatus.cancelled:
        return 'Cancelled';
      case WorkflowStatus.onHold:
        return 'On Hold';
      default:
        return 'Unknown';
    }
  }

  IconData _getOverallStatusIcon() {
    switch (workflow.overallStatus) {
      case WorkflowStatus.pending:
        return Icons.schedule;
      case WorkflowStatus.inProgress:
        return Icons.play_circle;
      case WorkflowStatus.completed:
        return Icons.check_circle;
      case WorkflowStatus.cancelled:
        return Icons.cancel;
      case WorkflowStatus.onHold:
        return Icons.pause_circle;
      default:
        return Icons.help;
    }
  }

  Color _getOverallStatusColor() {
    switch (workflow.overallStatus) {
      case WorkflowStatus.pending:
        return Colors.grey;
      case WorkflowStatus.inProgress:
        return Colors.blue;
      case WorkflowStatus.completed:
        return Colors.green;
      case WorkflowStatus.cancelled:
        return Colors.red;
      case WorkflowStatus.onHold:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} days';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours';
    } else {
      return '${duration.inMinutes} minutes';
    }
  }
}
