import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/journey_stage.dart';

class JourneyProgressTracker extends StatelessWidget {
  final MedicalJourney journey;
  final Function(JourneyStage)? onStageTap;

  const JourneyProgressTracker({
    Key? key,
    required this.journey,
    this.onStageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalStages = journey.stages.length;
    final completedStages = journey.stages
        .where((stage) => stage.status == JourneyStatus.completed)
        .length;
    final inProgressStages = journey.stages
        .where((stage) => stage.status == JourneyStatus.inProgress)
        .length;
    final notStartedStages = journey.stages
        .where((stage) => stage.status == JourneyStatus.notStarted)
        .length;
    final cancelledStages = journey.stages
        .where((stage) => stage.status == JourneyStatus.cancelled)
        .length;

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
            // Header
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Progress Overview',
                  style: TextStyle(
                    color: AppColors.textBlack,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getOverallStatusColor(journey.overallStatus),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getOverallStatusLabel(journey.overallStatus),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Progress Bar
            _buildProgressBar(completedStages, totalStages),
            
            const SizedBox(height: 16),
            
            // Progress Statistics
            _buildProgressStats(
              totalStages,
              completedStages,
              inProgressStages,
              notStartedStages,
              cancelledStages,
            ),
            
            const SizedBox(height: 20),
            
            // Stage Breakdown
            _buildStageBreakdown(),
            
            const SizedBox(height: 16),
            
            // Timeline Summary
            _buildTimelineSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int completed, int total) {
    final progress = total > 0 ? completed / total : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overall Progress',
              style: TextStyle(
                color: AppColors.textBlack,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            progress >= 1.0 ? AppColors.success : AppColors.primary,
          ),
          minHeight: 8,
        ),
        const SizedBox(height: 4),
        Text(
          '$completed of $total stages completed',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStats(
    int total,
    int completed,
    int inProgress,
    int notStarted,
    int cancelled,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'Completed',
            completed.toString(),
            AppColors.success,
            Icons.check_circle,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'In Progress',
            inProgress.toString(),
            AppColors.warning,
            Icons.pending,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'Not Started',
            notStarted.toString(),
            AppColors.info,
            Icons.schedule,
          ),
        ),
        if (cancelled > 0)
          Expanded(
            child: _buildStatItem(
              'Cancelled',
              cancelled.toString(),
              AppColors.error,
              Icons.cancel,
            ),
          ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStageBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stage Breakdown',
          style: TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ...journey.stages.asMap().entries.map((entry) {
          final index = entry.key;
          final stage = entry.value;
          return _buildStageItem(stage, index + 1);
        }).toList(),
      ],
    );
  }

  Widget _buildStageItem(JourneyStage stage, int stageNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStageBorderColor(stage.status),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Stage Number
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _getStageStatusColor(stage.status),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stageNumber.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Stage Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        stage.title,
                        style: TextStyle(
                          color: AppColors.textBlack,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    _buildStatusChip(stage.status),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _getStageTypeLabel(stage.type),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (stage.startDate != null || stage.completedDate != null) ...[
                  const SizedBox(height: 4),
                  _buildStageDates(stage),
                ],
              ],
            ),
          ),
          
          // Action Button
          if (onStageTap != null)
            IconButton(
              onPressed: () => onStageTap!(stage),
              icon: const Icon(Icons.edit, size: 16),
              tooltip: 'Edit Stage',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.secondary.withOpacity(0.1),
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.all(4),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStageDates(JourneyStage stage) {
    return Row(
      children: [
        if (stage.startDate != null) ...[
          Icon(
            Icons.schedule,
            size: 12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 2),
          Text(
            'Started: ${_formatDate(stage.startDate!)}',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
        if (stage.startDate != null && stage.completedDate != null) ...[
          const SizedBox(width: 8),
        ],
        if (stage.completedDate != null) ...[
          Icon(
            Icons.check_circle,
            size: 12,
            color: AppColors.success,
          ),
          const SizedBox(width: 2),
          Text(
            'Completed: ${_formatDate(stage.completedDate!)}',
            style: TextStyle(
              color: AppColors.success,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimelineSummary() {
    final completedStages = journey.stages
        .where((stage) => stage.status == JourneyStatus.completed)
        .toList();
    
    if (completedStages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.secondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No stages completed yet. Start your journey by beginning the first stage.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final firstCompleted = completedStages.first;
    final lastCompleted = completedStages.last;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.celebration,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Journey Progress',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'First completed: ${firstCompleted.title}',
            style: TextStyle(
              color: AppColors.textBlack,
              fontSize: 12,
            ),
          ),
          Text(
            'Latest completed: ${lastCompleted.title}',
            style: TextStyle(
              color: AppColors.textBlack,
              fontSize: 12,
            ),
          ),
          if (firstCompleted.completedDate != null && lastCompleted.completedDate != null) ...[
            const SizedBox(height: 4),
            Text(
              'Duration: ${_calculateDuration(firstCompleted.completedDate!, lastCompleted.completedDate!)}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStageStatusColor(JourneyStatus status) {
    switch (status) {
      case JourneyStatus.completed:
        return AppColors.success;
      case JourneyStatus.inProgress:
        return AppColors.warning;
      case JourneyStatus.cancelled:
        return AppColors.error;
      case JourneyStatus.notStarted:
        return AppColors.info;
    }
  }

  Color _getStageBorderColor(JourneyStatus status) {
    switch (status) {
      case JourneyStatus.completed:
        return AppColors.success.withOpacity(0.3);
      case JourneyStatus.inProgress:
        return AppColors.warning.withOpacity(0.3);
      case JourneyStatus.cancelled:
        return AppColors.error.withOpacity(0.3);
      case JourneyStatus.notStarted:
        return AppColors.info.withOpacity(0.3);
    }
  }

  Color _getOverallStatusColor(JourneyStatus status) {
    switch (status) {
      case JourneyStatus.completed:
        return AppColors.success;
      case JourneyStatus.inProgress:
        return AppColors.warning;
      case JourneyStatus.cancelled:
        return AppColors.error;
      case JourneyStatus.notStarted:
        return AppColors.info;
    }
  }

  String _getOverallStatusLabel(JourneyStatus status) {
    switch (status) {
      case JourneyStatus.completed:
        return 'Completed';
      case JourneyStatus.inProgress:
        return 'In Progress';
      case JourneyStatus.cancelled:
        return 'Cancelled';
      case JourneyStatus.notStarted:
        return 'Not Started';
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _calculateDuration(DateTime start, DateTime end) {
    final difference = end.difference(start);
    final days = difference.inDays;
    
    if (days == 0) {
      return 'Same day';
    } else if (days == 1) {
      return '1 day';
    } else if (days < 30) {
      return '$days days';
    } else {
      final months = (days / 30).round();
      return '$months month${months > 1 ? 's' : ''}';
    }
  }
} 