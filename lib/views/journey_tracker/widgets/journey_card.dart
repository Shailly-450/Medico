import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/journey_stage.dart';

class JourneyCard extends StatelessWidget {
  final MedicalJourney journey;
  final bool isSelected;
  final VoidCallback onTap;

  const JourneyCard({
    Key? key,
    required this.journey,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        height: 110, // Reduced height for compactness
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.secondary,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8), // Reduced padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Icon and Status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5), // Reduced padding
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.white.withOpacity(0.18) 
                          : AppColors.secondary.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getJourneyIcon(),
                      color: isSelected ? Colors.white : AppColors.primary,
                      size: 16, // Smaller icon
                    ),
                  ),
                  const Spacer(),
                  _buildStatusChip(),
                ],
              ),
              // Title
              Text(
                journey.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isSelected ? Colors.white : AppColors.textBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: 13, // Smaller font
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Progress and Stages Row
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: journey.progressPercentage,
                      backgroundColor: isSelected 
                          ? Colors.white.withOpacity(0.2) 
                          : AppColors.secondary.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isSelected ? Colors.white : AppColors.primary,
                      ),
                      minHeight: 4, // Thinner progress bar
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${(journey.progressPercentage * 100).toInt()}%',
                    style: TextStyle(
                      color: isSelected 
                          ? Colors.white.withOpacity(0.8) 
                          : AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // Stage count
              Text(
                '${journey.stages.length} stages',
                style: TextStyle(
                  color: isSelected 
                      ? Colors.white.withOpacity(0.7) 
                      : AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getJourneyIcon() {
    if (journey.stages.any((stage) => stage.type == JourneyStageType.surgery)) {
      return Icons.medical_services;
    } else if (journey.stages.any((stage) => stage.type == JourneyStageType.test)) {
      return Icons.science;
    } else {
      return Icons.medical_information;
    }
  }

  Widget _buildStatusChip() {
    Color chipColor;
    Color textColor;
    String statusText;
    
    switch (journey.overallStatus) {
      case JourneyStatus.completed:
        chipColor = AppColors.success;
        textColor = Colors.white;
        statusText = 'Done';
        break;
      case JourneyStatus.inProgress:
        chipColor = AppColors.warning;
        textColor = AppColors.textBlack;
        statusText = 'Active';
        break;
      case JourneyStatus.cancelled:
        chipColor = AppColors.error;
        textColor = Colors.white;
        statusText = 'Cancelled';
        break;
      case JourneyStatus.notStarted:
        chipColor = AppColors.info;
        textColor = Colors.white;
        statusText = 'New';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(8),
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
} 