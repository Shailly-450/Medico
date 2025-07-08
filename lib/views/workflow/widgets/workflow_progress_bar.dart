import 'package:flutter/material.dart';
import '../../../models/medical_workflow.dart';
import '../../../core/theme/app_colors.dart';

class WorkflowProgressBar extends StatelessWidget {
  final MedicalWorkflow workflow;
  final bool showLabels;
  final double height;

  const WorkflowProgressBar({
    Key? key,
    required this.workflow,
    this.showLabels = false,
    this.height = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progressPercentage = workflow.progressPercentage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabels) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress: ${progressPercentage.toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${workflow.completedStages.length}/${workflow.stages.length} stages',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: Stack(
              children: [
                // Background
                Container(
                  width: double.infinity,
                  height: height,
                  color: Colors.grey.shade200,
                ),

                // Progress fill
                FractionallySizedBox(
                  widthFactor: progressPercentage / 100,
                  child: Container(
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getProgressColors(),
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showLabels) ...[
          const SizedBox(height: 8),
          _buildStageIndicators(),
        ],
      ],
    );
  }

  Widget _buildStageIndicators() {
    final mainStages = _getMainStages();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: mainStages.asMap().entries.map((entry) {
        final index = entry.key;
        final stage = entry.value;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 4,
              right: index == mainStages.length - 1 ? 0 : 4,
            ),
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getStageIndicatorColor(stage),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getStageIndicatorBorderColor(stage),
                      width: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStageLabel(stage),
                  style: TextStyle(
                    fontSize: 10,
                    color: _getStageTextColor(stage),
                    fontWeight: _getStageTextWeight(stage),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  List<WorkflowStage> _getMainStages() {
    // Return the main workflow stages in order
    return [
      WorkflowStage.consultation,
      WorkflowStage.testing,
      WorkflowStage.surgery,
      WorkflowStage.completed,
    ];
  }

  List<Color> _getProgressColors() {
    final progressPercentage = workflow.progressPercentage;

    if (progressPercentage >= 100) {
      return [Colors.green, Colors.green.shade600];
    } else if (progressPercentage >= 75) {
      return [Colors.blue, Colors.green];
    } else if (progressPercentage >= 50) {
      return [AppColors.primary, Colors.blue];
    } else if (progressPercentage >= 25) {
      return [Colors.orange, AppColors.primary];
    } else {
      return [Colors.red.shade300, Colors.orange];
    }
  }

  Color _getStageIndicatorColor(WorkflowStage stage) {
    final currentStageIndex = _getStageIndex(workflow.currentStage);
    final stageIndex = _getStageIndex(stage);

    if (stageIndex < currentStageIndex) {
      return Colors.green; // Completed
    } else if (stageIndex == currentStageIndex) {
      return AppColors.primary; // Current
    } else {
      return Colors.grey.shade300; // Pending
    }
  }

  Color _getStageIndicatorBorderColor(WorkflowStage stage) {
    final currentStageIndex = _getStageIndex(workflow.currentStage);
    final stageIndex = _getStageIndex(stage);

    if (stageIndex < currentStageIndex) {
      return Colors.green.shade600;
    } else if (stageIndex == currentStageIndex) {
      return AppColors.primary;
    } else {
      return Colors.grey.shade400;
    }
  }

  Color _getStageTextColor(WorkflowStage stage) {
    final currentStageIndex = _getStageIndex(workflow.currentStage);
    final stageIndex = _getStageIndex(stage);

    if (stageIndex < currentStageIndex) {
      return Colors.green;
    } else if (stageIndex == currentStageIndex) {
      return AppColors.primary;
    } else {
      return Colors.grey;
    }
  }

  FontWeight _getStageTextWeight(WorkflowStage stage) {
    final currentStageIndex = _getStageIndex(workflow.currentStage);
    final stageIndex = _getStageIndex(stage);

    if (stageIndex == currentStageIndex) {
      return FontWeight.w600;
    } else {
      return FontWeight.normal;
    }
  }

  String _getStageLabel(WorkflowStage stage) {
    switch (stage) {
      case WorkflowStage.consultation:
        return 'Consult';
      case WorkflowStage.testing:
        return 'Test';
      case WorkflowStage.surgery:
        return 'Surgery';
      case WorkflowStage.completed:
        return 'Done';
      default:
        return 'Unknown';
    }
  }

  int _getStageIndex(WorkflowStage stage) {
    switch (stage) {
      case WorkflowStage.consultation:
        return 0;
      case WorkflowStage.testing:
        return 1;
      case WorkflowStage.surgery:
        return 2;
      case WorkflowStage.completed:
        return 3;
      default:
        return -1;
    }
  }
}
