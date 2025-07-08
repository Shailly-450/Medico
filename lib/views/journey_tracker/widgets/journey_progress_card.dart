import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/journey_stage.dart';

class JourneyProgressCard extends StatelessWidget {
  final MedicalJourney journey;

  const JourneyProgressCard({
    Key? key,
    required this.journey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final completedStages = journey.stages.where((s) => 
        s.status == JourneyStatus.completed).length;
    final inProgressStages = journey.stages.where((s) => 
        s.status == JourneyStatus.inProgress).length;
    final notStartedStages = journey.stages.where((s) => 
        s.status == JourneyStatus.notStarted).length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.timeline,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        journey.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.textBlack,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        journey.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                _buildOverallStatusChip(),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Progress Section
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Progress',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textBlack,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: journey.progressPercentage,
                        backgroundColor: AppColors.secondary.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(journey.progressPercentage * 100).toInt()}% Complete',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: _buildProgressStats(
                    completedStages,
                    inProgressStages,
                    notStartedStages,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Stage Breakdown
            _buildStageBreakdown(
              completedStages,
              inProgressStages,
              notStartedStages,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatusChip() {
    Color chipColor;
    Color textColor;
    String statusText;
    IconData statusIcon;
    
    switch (journey.overallStatus) {
      case JourneyStatus.completed:
        chipColor = AppColors.success;
        textColor = Colors.white;
        statusText = 'Completed';
        statusIcon = Icons.check_circle;
        break;
      case JourneyStatus.inProgress:
        chipColor = AppColors.warning;
        textColor = AppColors.textBlack;
        statusText = 'In Progress';
        statusIcon = Icons.pending;
        break;
      case JourneyStatus.cancelled:
        chipColor = AppColors.error;
        textColor = Colors.white;
        statusText = 'Cancelled';
        statusIcon = Icons.cancel;
        break;
      case JourneyStatus.notStarted:
        chipColor = AppColors.info;
        textColor = Colors.white;
        statusText = 'Not Started';
        statusIcon = Icons.schedule;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            color: textColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStats(
    int completed,
    int inProgress,
    int notStarted,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stage Summary',
          style: TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        _buildStatRow('Completed', completed, AppColors.success),
        _buildStatRow('In Progress', inProgress, AppColors.warning),
        _buildStatRow('Not Started', notStarted, AppColors.info),
      ],
    );
  }

  Widget _buildStatRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: $count',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageBreakdown(
    int completed,
    int inProgress,
    int notStarted,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stage Breakdown',
          style: TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStageTypeCard(
                'Consult',
                _getConsultCount(),
                AppColors.info,
                Icons.medical_information,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStageTypeCard(
                'Test',
                _getTestCount(),
                AppColors.warning,
                Icons.science,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStageTypeCard(
                'Surgery',
                _getSurgeryCount(),
                AppColors.error,
                Icons.medical_services,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStageTypeCard(
    String title,
    int count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            count.toString(),
            style: TextStyle(
              color: AppColors.textBlack,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  int _getConsultCount() {
    return journey.stages.where((stage) => 
        stage.type == JourneyStageType.consult).length;
  }

  int _getTestCount() {
    return journey.stages.where((stage) => 
        stage.type == JourneyStageType.test).length;
  }

  int _getSurgeryCount() {
    return journey.stages.where((stage) => 
        stage.type == JourneyStageType.surgery).length;
  }
} 