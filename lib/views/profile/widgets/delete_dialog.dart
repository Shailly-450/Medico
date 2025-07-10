import 'package:flutter/material.dart';
import '../../../models/personal_data.dart';
import '../../../core/theme/app_colors.dart';

class DeleteDialog extends StatefulWidget {
  final List<PersonalDataItem> selectedItems;
  final Function(String) onDelete;

  const DeleteDialog({
    Key? key,
    required this.selectedItems,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  final TextEditingController _reasonController = TextEditingController();
  String _selectedReason = '';
  bool _isCustomReason = false;

  final List<String> _predefinedReasons = [
    'No longer needed',
    'Privacy concerns',
    'Data accuracy issues',
    'Switching to another service',
    'Account closure',
    'Other',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning, color: Colors.red, size: 24),
          const SizedBox(width: 8),
          const Text('Delete Personal Data'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You are about to delete ${widget.selectedItems.length} data category(ies):',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...widget.selectedItems.map((item) => _buildSelectedItem(item)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.red[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This action cannot be undone. Deleted data will be permanently removed.',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Reason for deletion:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (!_isCustomReason) ...[
            ..._predefinedReasons.map((reason) => _buildReasonOption(reason)),
          ] else ...[
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                hintText: 'Enter your reason for deletion...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                setState(() {
                  _selectedReason = value;
                });
              },
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _canDelete() ? () => _handleDelete() : null,
          icon: const Icon(Icons.delete),
          label: const Text('Delete'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedItem(PersonalDataItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(
            Icons.delete,
            color: Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '${item.recordCount} records',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonOption(String reason) {
    final isSelected = _selectedReason == reason;
    final isCustom = reason == 'Other';

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.red[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isSelected ? Colors.red[300]! : Colors.grey[300]!,
        ),
      ),
      child: RadioListTile<String>(
        value: reason,
        groupValue: _selectedReason,
        onChanged: (value) {
          setState(() {
            _selectedReason = value!;
            if (isCustom) {
              _isCustomReason = true;
            } else {
              _isCustomReason = false;
              _reasonController.clear();
            }
          });
        },
        title: Text(
          reason,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.red[700] : Colors.black,
          ),
        ),
        activeColor: Colors.red,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  bool _canDelete() {
    if (_isCustomReason) {
      return _reasonController.text.trim().isNotEmpty;
    }
    return _selectedReason.isNotEmpty && _selectedReason != 'Other';
  }

  void _handleDelete() {
    String reason;
    if (_isCustomReason) {
      reason = _reasonController.text.trim();
    } else {
      reason = _selectedReason;
    }
    
    widget.onDelete(reason);
  }
} 