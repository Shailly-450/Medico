import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/journey_stage.dart';

class JourneyTimeline extends StatelessWidget {
  final List<JourneyStage> stages;
  final Function(JourneyStage) onStageTap;
  final Function(JourneyStage, JourneyStatus) onStatusUpdate;

  const JourneyTimeline({
    Key? key,
    required this.stages,
    required this.onStageTap,
    required this.onStatusUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stages.length,
      itemBuilder: (context, index) {
        final stage = stages[index];
        final isLast = index == stages.length - 1;
        
        return _buildTimelineItem(
          context,
          stage,
          index,
          isLast,
        );
      },
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    JourneyStage stage,
    int index,
    bool isLast,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line and Icon
          SizedBox(
            width: 60,
            child: Column(
              children: [
                _buildStageIcon(stage),
                if (!isLast) _buildTimelineLine(stage.status),
              ],
            ),
          ),
          
          // Stage Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: _buildStageContent(context, stage),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageIcon(JourneyStage stage) {
    Color iconColor;
    Color backgroundColor;
    IconData icon;
    
    switch (stage.status) {
      case JourneyStatus.completed:
        iconColor = Colors.white;
        backgroundColor = AppColors.success;
        icon = Icons.check;
        break;
      case JourneyStatus.inProgress:
        iconColor = Colors.white;
        backgroundColor = AppColors.warning;
        icon = Icons.pending;
        break;
      case JourneyStatus.cancelled:
        iconColor = Colors.white;
        backgroundColor = AppColors.error;
        icon = Icons.cancel;
        break;
      case JourneyStatus.notStarted:
        iconColor = AppColors.textSecondary;
        backgroundColor = AppColors.secondary.withOpacity(0.3);
        icon = _getStageTypeIcon(stage.type);
        break;
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.secondary,
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 20,
      ),
    );
  }

  Widget _buildTimelineLine(JourneyStatus status) {
    Color lineColor;
    
    switch (status) {
      case JourneyStatus.completed:
        lineColor = AppColors.success;
        break;
      case JourneyStatus.inProgress:
        lineColor = AppColors.warning;
        break;
      case JourneyStatus.cancelled:
        lineColor = AppColors.error;
        break;
      case JourneyStatus.notStarted:
        lineColor = AppColors.secondary.withOpacity(0.3);
        break;
    }
    
    return Container(
      width: 2,
      height: 60,
      color: lineColor,
      margin: const EdgeInsets.only(left: 19),
    );
  }

  Widget _buildStageContent(BuildContext context, JourneyStage stage) {
    return GestureDetector(
      onTap: () => onStageTap(stage),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getStageBorderColor(stage.status),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stage Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stage.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textBlack,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStageTypeLabel(stage.type),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(stage.status),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Stage Description
            Text(
              stage.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            
            // Dates
            if (stage.startDate != null || stage.completedDate != null) ...[
              const SizedBox(height: 12),
              _buildDateInfo(stage),
            ],
            
            // Notes
            if (stage.notes != null && stage.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildNotesSection(stage.notes!),
            ],
            
            // Action Buttons
            const SizedBox(height: 12),
            _buildActionButtons(context, stage),
            
            // Quick Edit Options
            if (stage.status != JourneyStatus.completed) ...[
              const SizedBox(height: 8),
              _buildQuickEditOptions(context, stage),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(JourneyStatus status) {
    Color chipColor;
    Color textColor;
    String statusText;
    
    switch (status) {
      case JourneyStatus.completed:
        chipColor = AppColors.success;
        textColor = Colors.white;
        statusText = 'Completed';
        break;
      case JourneyStatus.inProgress:
        chipColor = AppColors.warning;
        textColor = AppColors.textBlack;
        statusText = 'In Progress';
        break;
      case JourneyStatus.cancelled:
        chipColor = AppColors.error;
        textColor = Colors.white;
        statusText = 'Cancelled';
        break;
      case JourneyStatus.notStarted:
        chipColor = AppColors.info;
        textColor = Colors.white;
        statusText = 'Not Started';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDateInfo(JourneyStage stage) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (stage.startDate != null) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Started: ${_formatDate(stage.startDate!)}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        if (stage.completedDate != null) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                size: 14,
                color: AppColors.success,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Completed: ${_formatDate(stage.completedDate!)}',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildNotesSection(String notes) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Notes',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            notes,
            style: TextStyle(
              color: AppColors.textBlack,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, JourneyStage stage) {
    return Row(
      children: [
        if (stage.status == JourneyStatus.notStarted) ...[
          Expanded(
            child: ElevatedButton(
              onPressed: () => onStatusUpdate(stage, JourneyStatus.inProgress),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('Start'),
            ),
          ),
        ] else if (stage.status == JourneyStatus.inProgress) ...[
          Expanded(
            child: ElevatedButton(
              onPressed: () => onStatusUpdate(stage, JourneyStatus.completed),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('Mark Complete'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () => onStatusUpdate(stage, JourneyStatus.cancelled),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('Cancel'),
            ),
          ),
        ],
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => onStageTap(stage),
          icon: const Icon(Icons.edit, size: 18),
          tooltip: 'Edit Stage',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.secondary.withOpacity(0.1),
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  IconData _getStageTypeIcon(JourneyStageType type) {
    switch (type) {
      case JourneyStageType.consult:
        return Icons.medical_information;
      case JourneyStageType.test:
        return Icons.science;
      case JourneyStageType.surgery:
        return Icons.medical_services;
    }
  }

  String _getStageTypeLabel(JourneyStageType type) {
    switch (type) {
      case JourneyStageType.consult:
        return 'Consultation';
      case JourneyStageType.test:
        return 'Testing';
      case JourneyStageType.surgery:
        return 'Surgery';
    }
  }

  Color _getStageBorderColor(JourneyStatus status) {
    switch (status) {
      case JourneyStatus.completed:
        return AppColors.success;
      case JourneyStatus.inProgress:
        return AppColors.warning;
      case JourneyStatus.cancelled:
        return AppColors.error;
      case JourneyStatus.notStarted:
        return AppColors.secondary;
    }
  }

  Widget _buildQuickEditOptions(BuildContext context, JourneyStage stage) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => onStageTap(stage),
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 6),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Quick status update
              if (stage.status == JourneyStatus.notStarted) {
                onStatusUpdate(stage, JourneyStatus.inProgress);
              } else if (stage.status == JourneyStatus.inProgress) {
                onStatusUpdate(stage, JourneyStatus.completed);
              }
            },
            icon: Icon(
              stage.status == JourneyStatus.notStarted ? Icons.play_arrow : Icons.check,
              size: 16,
            ),
            label: Text(stage.status == JourneyStatus.notStarted ? 'Start' : 'Complete'),
            style: OutlinedButton.styleFrom(
              foregroundColor: stage.status == JourneyStatus.notStarted 
                  ? AppColors.warning 
                  : AppColors.success,
              side: BorderSide(
                color: stage.status == JourneyStatus.notStarted 
                    ? AppColors.warning 
                    : AppColors.success,
              ),
              padding: const EdgeInsets.symmetric(vertical: 6),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 