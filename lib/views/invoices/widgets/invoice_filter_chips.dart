import 'package:flutter/material.dart';
import '../../../models/invoice.dart';
import '../../../core/theme/app_colors.dart';

class InvoiceFilterChips extends StatelessWidget {
  final InvoiceStatus? selectedStatus;
  final String? selectedType;
  final Function(InvoiceStatus?) onStatusChanged;
  final Function(String?) onTypeChanged;

  const InvoiceFilterChips({
    Key? key,
    required this.selectedStatus,
    required this.selectedType,
    required this.onStatusChanged,
    required this.onTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Status',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('All'),
              selected: selectedStatus == null,
              onSelected: (selected) {
                if (selected) {
                  onStatusChanged(null);
                }
              },
            ),
            ...InvoiceStatus.values.map((status) {
              return FilterChip(
                label: Text(status.toString().split('.').last),
                selected: selectedStatus == status,
                onSelected: (selected) {
                  onStatusChanged(selected ? status : null);
                },
                backgroundColor: _getStatusColor(status).withOpacity(0.1),
                selectedColor: _getStatusColor(status).withOpacity(0.2),
                labelStyle: TextStyle(
                  color: _getStatusColor(status),
                  fontWeight: selectedStatus == status ? FontWeight.bold : null,
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Filter by Type',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('All'),
              selected: selectedType == null,
              onSelected: (selected) {
                if (selected) {
                  onTypeChanged(null);
                }
              },
            ),
            ...['Consultation', 'Prescription'].map((type) {
              return FilterChip(
                label: Text(type),
                selected: selectedType == type,
                onSelected: (selected) {
                  onTypeChanged(selected ? type : null);
                },
                backgroundColor: Colors.blue[50],
                selectedColor: Colors.blue[100],
                labelStyle: TextStyle(
                  color: Colors.blue[900],
                  fontWeight: selectedType == type ? FontWeight.bold : null,
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.Paid:
        return Colors.green[700]!;
      case InvoiceStatus.Pending:
        return Colors.blue[700]!;
      case InvoiceStatus.Overdue:
        return Colors.red[700]!;
    }
  }
}
