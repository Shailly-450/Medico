import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/journey_stage.dart';

class StageReorderDialog extends StatefulWidget {
  final MedicalJourney journey;
  final Function(List<JourneyStage>) onStagesReordered;

  const StageReorderDialog({
    Key? key,
    required this.journey,
    required this.onStagesReordered,
  }) : super(key: key);

  @override
  State<StageReorderDialog> createState() => _StageReorderDialogState();
}

class _StageReorderDialogState extends State<StageReorderDialog> {
  late List<JourneyStage> _stages;

  @override
  void initState() {
    super.initState();
    _stages = List.from(widget.journey.stages);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),
            
            // Content
            Flexible(
              child: Column(
                children: [
                  // Instructions
                  _buildInstructions(),
                  
                  // Reorderable List
                  Expanded(
                    child: _buildReorderableList(),
                  ),
                ],
              ),
            ),
            
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.swap_vert,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reorder Stages',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.journey.title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Drag and drop stages to reorder them. The order will affect the treatment flow.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReorderableList() {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _stages.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final item = _stages.removeAt(oldIndex);
          _stages.insert(newIndex, item);
        });
      },
      itemBuilder: (context, index) {
        final stage = _stages[index];
        return _buildStageItem(stage, index);
      },
    );
  }

  Widget _buildStageItem(JourneyStage stage, int index) {
    return Container(
      key: ValueKey(stage.id),
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getStageBorderColor(stage.status),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Drag Handle
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.drag_handle,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Stage Number
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Stage Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            stage.title,
                            style: const TextStyle(
                              color: AppColors.textBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusChip(stage.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStageTypeLabel(stage.type),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stage.description,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Stage Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStageIconBackground(stage.status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getStageTypeIcon(stage.type),
                  color: _getStageIconColor(stage.status),
                  size: 20,
                ),
              ),
            ],
          ),
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

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _stages = List.from(widget.journey.stages);
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: const Text('Reset'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Order'),
            ),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    widget.onStagesReordered(_stages);
    Navigator.of(context).pop();
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

  Color _getStageIconBackground(JourneyStatus status) {
    switch (status) {
      case JourneyStatus.completed:
        return AppColors.success.withOpacity(0.2);
      case JourneyStatus.inProgress:
        return AppColors.warning.withOpacity(0.2);
      case JourneyStatus.cancelled:
        return AppColors.error.withOpacity(0.2);
      case JourneyStatus.notStarted:
        return AppColors.secondary.withOpacity(0.2);
    }
  }

  Color _getStageIconColor(JourneyStatus status) {
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
} 