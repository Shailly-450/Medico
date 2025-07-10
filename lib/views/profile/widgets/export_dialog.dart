import 'package:flutter/material.dart';
import '../../../models/personal_data.dart';
import '../../../core/theme/app_colors.dart';

class ExportDialog extends StatefulWidget {
  final DataFormat selectedFormat;
  final List<DataFormat> availableFormats;
  final Function(DataFormat) onFormatChanged;
  final Function(DataFormat) onExport;

  const ExportDialog({
    Key? key,
    required this.selectedFormat,
    required this.availableFormats,
    required this.onFormatChanged,
    required this.onExport,
  }) : super(key: key);

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  late DataFormat _selectedFormat;

  @override
  void initState() {
    super.initState();
    _selectedFormat = widget.selectedFormat;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Personal Data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose the format for your exported data:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ...widget.availableFormats.map((format) => _buildFormatOption(format)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getFormatDescription(_selectedFormat),
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            widget.onFormatChanged(_selectedFormat);
            widget.onExport(_selectedFormat);
          },
          icon: const Icon(Icons.download),
          label: const Text('Export'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFormatOption(DataFormat format) {
    final isSelected = format == _selectedFormat;
    final displayName = _getFormatDisplayName(format);
    final description = _getFormatDescription(format);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<DataFormat>(
        value: format,
        groupValue: _selectedFormat,
        onChanged: (value) {
          setState(() {
            _selectedFormat = value!;
          });
        },
        title: Text(
          displayName,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.primary : Colors.black,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  String _getFormatDisplayName(DataFormat format) {
    switch (format) {
      case DataFormat.json:
        return 'JSON (JavaScript Object Notation)';
      case DataFormat.csv:
        return 'CSV (Comma-Separated Values)';
      case DataFormat.pdf:
        return 'PDF (Portable Document Format)';
      case DataFormat.xml:
        return 'XML (Extensible Markup Language)';
    }
  }

  String _getFormatDescription(DataFormat format) {
    switch (format) {
      case DataFormat.json:
        return 'Best for data processing and APIs. Human-readable and widely supported.';
      case DataFormat.csv:
        return 'Best for spreadsheet applications like Excel. Simple tabular format.';
      case DataFormat.pdf:
        return 'Best for printing and sharing. Professional document format.';
      case DataFormat.xml:
        return 'Best for structured data. Self-describing format with tags.';
    }
  }
} 