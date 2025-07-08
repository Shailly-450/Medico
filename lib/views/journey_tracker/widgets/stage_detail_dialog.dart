import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/journey_stage.dart';

class StageDetailDialog extends StatefulWidget {
  final MedicalJourney journey;
  final JourneyStage stage;
  final Function(JourneyStatus) onStatusUpdate;
  final Function(String) onNoteUpdate;

  const StageDetailDialog({
    Key? key,
    required this.journey,
    required this.stage,
    required this.onStatusUpdate,
    required this.onNoteUpdate,
  }) : super(key: key);

  @override
  State<StageDetailDialog> createState() => _StageDetailDialogState();
}

class _StageDetailDialogState extends State<StageDetailDialog> {
  late TextEditingController _notesController;
  late JourneyStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.stage.notes ?? '');
    _selectedStatus = widget.stage.status;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stage Information
                    _buildStageInfo(),
                    
                    const SizedBox(height: 20),
                    
                    // Status Selection
                    _buildStatusSelection(),
                    
                    const SizedBox(height: 20),
                    
                    // Notes Section
                    _buildNotesSection(),
                    
                    const SizedBox(height: 20),
                    
                    // Dates Information
                    _buildDatesSection(),
                  ],
                ),
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
            child: Icon(
              _getStageTypeIcon(widget.stage.type),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.stage.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getStageTypeLabel(widget.stage.type),
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

  Widget _buildStageInfo() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stage Description',
              style: TextStyle(
                color: AppColors.textBlack,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.stage.description,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSelection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Status',
              style: TextStyle(
                color: AppColors.textBlack,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: JourneyStatus.values.map((status) {
                final isSelected = _selectedStatus == status;
                return ChoiceChip(
                  label: Text(_getStatusLabel(status)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedStatus = status;
                      });
                    }
                  },
                  selectedColor: _getStatusColor(status),
                  backgroundColor: AppColors.secondary.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textBlack,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: TextStyle(
                color: AppColors.textBlack,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add notes about this stage...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.secondary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatesSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timeline',
              style: TextStyle(
                color: AppColors.textBlack,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            if (widget.stage.startDate != null) ...[
              _buildDateRow('Started', widget.stage.startDate!, Icons.schedule),
              const SizedBox(height: 8),
            ],
            if (widget.stage.completedDate != null) ...[
              _buildDateRow('Completed', widget.stage.completedDate!, Icons.check_circle),
            ] else ...[
              Text(
                'Not yet completed',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime date, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ${_formatDate(date)}',
          style: TextStyle(
            color: AppColors.textBlack,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: BorderSide(color: AppColors.secondary),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    // Update status if changed
    if (_selectedStatus != widget.stage.status) {
      widget.onStatusUpdate(_selectedStatus);
    }
    
    // Update notes if changed
    if (_notesController.text != (widget.stage.notes ?? '')) {
      widget.onNoteUpdate(_notesController.text);
    }
    
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

  String _getStatusLabel(JourneyStatus status) {
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

  Color _getStatusColor(JourneyStatus status) {
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 