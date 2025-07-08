import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/journey_stage.dart';

class StageEditDialog extends StatefulWidget {
  final MedicalJourney journey;
  final JourneyStage stage;
  final Function(JourneyStage) onStageUpdate;
  final Function(String, String) onStageDelete;

  const StageEditDialog({
    Key? key,
    required this.journey,
    required this.stage,
    required this.onStageUpdate,
    required this.onStageDelete,
  }) : super(key: key);

  @override
  State<StageEditDialog> createState() => _StageEditDialogState();
}

class _StageEditDialogState extends State<StageEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  late JourneyStatus _selectedStatus;
  DateTime? _startDate;
  DateTime? _completedDate;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.stage.title);
    _descriptionController = TextEditingController(text: widget.stage.description);
    _notesController = TextEditingController(text: widget.stage.notes ?? '');
    _selectedStatus = widget.stage.status;
    _startDate = widget.stage.startDate;
    _completedDate = widget.stage.completedDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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
        constraints: const BoxConstraints(maxHeight: 700),
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
                    // Edit Toggle
                    _buildEditToggle(),
                    
                    const SizedBox(height: 20),
                    
                    // Stage Information
                    _buildStageInfo(),
                    
                    const SizedBox(height: 20),
                    
                    // Status Selection
                    _buildStatusSelection(),
                    
                    const SizedBox(height: 20),
                    
                    // Date Selection
                    _buildDateSelection(),
                    
                    const SizedBox(height: 20),
                    
                    // Notes Section
                    _buildNotesSection(),
                    
                    const SizedBox(height: 20),
                    
                    // Progress Information
                    _buildProgressInfo(),
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
                  _isEditing ? 'Edit Stage' : 'Stage Details',
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

  Widget _buildEditToggle() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Edit Mode',
            style: TextStyle(
              color: AppColors.textBlack,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Switch(
          value: _isEditing,
          onChanged: (value) {
            setState(() {
              _isEditing = value;
            });
          },
          activeColor: AppColors.primary,
        ),
      ],
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
              'Stage Information',
              style: TextStyle(
                color: AppColors.textBlack,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: !_isEditing,
                fillColor: _isEditing ? null : Colors.grey[100],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              enabled: _isEditing,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: !_isEditing,
                fillColor: _isEditing ? null : Colors.grey[100],
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
              'Status',
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
                  onSelected: _isEditing ? (selected) {
                    if (selected) {
                      setState(() {
                        _selectedStatus = status;
                        // Auto-update dates based on status
                        if (status == JourneyStatus.inProgress && _startDate == null) {
                          _startDate = DateTime.now();
                        } else if (status == JourneyStatus.completed && _completedDate == null) {
                          _completedDate = DateTime.now();
                        }
                      });
                    }
                  } : null,
                  backgroundColor: Colors.grey[200],
                  selectedColor: _getStatusColor(status),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textBlack,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
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
              'Dates',
              style: TextStyle(
                color: AppColors.textBlack,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    label: 'Start Date',
                    date: _startDate,
                    onDateSelected: _isEditing ? (date) {
                      setState(() {
                        _startDate = date;
                      });
                    } : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField(
                    label: 'Completed Date',
                    date: _completedDate,
                    onDateSelected: _isEditing ? (date) {
                      setState(() {
                        _completedDate = date;
                      });
                    } : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required Function(DateTime?)? onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onDateSelected != null ? () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (selectedDate != null) {
              onDateSelected(selectedDate);
            }
          } : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: onDateSelected != null ? Colors.white : Colors.grey[100],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null ? _formatDate(date) : 'Not set',
                    style: TextStyle(
                      color: date != null ? AppColors.textBlack : AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (onDateSelected != null && date != null)
                  IconButton(
                    onPressed: () => onDateSelected(null),
                    icon: const Icon(Icons.clear, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
      ],
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
              enabled: _isEditing,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add notes about this stage...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: !_isEditing,
                fillColor: _isEditing ? null : Colors.grey[100],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressInfo() {
    final totalStages = widget.journey.stages.length;
    final completedStages = widget.journey.stages
        .where((stage) => stage.status == JourneyStatus.completed)
        .length;
    final currentStageIndex = widget.journey.stages
        .indexWhere((stage) => stage.id == widget.stage.id);
    
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
              'Progress Information',
              style: TextStyle(
                color: AppColors.textBlack,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildProgressItem(
                    'Stage',
                    '${currentStageIndex + 1} of $totalStages',
                    Icons.format_list_numbered,
                  ),
                ),
                Expanded(
                  child: _buildProgressItem(
                    'Completed',
                    '$completedStages/$totalStages',
                    Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _buildProgressItem(
                    'Progress',
                    '${((completedStages / totalStages) * 100).round()}%',
                    Icons.trending_up,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
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
          if (_isEditing) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showDeleteConfirmation(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                child: const Text('Delete'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: _isEditing ? _saveChanges : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(_isEditing ? 'Save Changes' : 'Close'),
            ),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    final updatedStage = widget.stage.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _selectedStatus,
      startDate: _startDate,
      completedDate: _completedDate,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    widget.onStageUpdate(updatedStage);
    Navigator.of(context).pop();
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Stage'),
        content: const Text('Are you sure you want to delete this stage? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onStageDelete(widget.journey.id, widget.stage.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
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

  String _getStatusLabel(JourneyStatus status) {
    switch (status) {
      case JourneyStatus.notStarted:
        return 'Not Started';
      case JourneyStatus.inProgress:
        return 'In Progress';
      case JourneyStatus.completed:
        return 'Completed';
      case JourneyStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(JourneyStatus status) {
    switch (status) {
      case JourneyStatus.notStarted:
        return AppColors.info;
      case JourneyStatus.inProgress:
        return AppColors.warning;
      case JourneyStatus.completed:
        return AppColors.success;
      case JourneyStatus.cancelled:
        return AppColors.error;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 