import 'package:flutter/material.dart';
import '../../../models/invoice.dart';
import '../../../core/theme/app_colors.dart';

class InvoiceFilterChips extends StatelessWidget {
  final InvoiceStatus? selectedStatus;
  final InvoiceType? selectedType;
  final Function(InvoiceStatus?)? onStatusChanged;
  final Function(InvoiceType?)? onTypeChanged;

  const InvoiceFilterChips({
    Key? key,
    this.selectedStatus,
    this.selectedType,
    this.onStatusChanged,
    this.onTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status filters
        Text(
          'Status',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                context,
                label: 'All',
                isSelected: selectedStatus == null,
                onTap: () => onStatusChanged?.call(null),
              ),
              const SizedBox(width: 8),
              ...InvoiceStatus.values.map((status) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(
                  context,
                  label: _getStatusLabel(status),
                  isSelected: selectedStatus == status,
                  onTap: () => onStatusChanged?.call(status),
                  color: _getStatusColor(status),
                ),
              )),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Type filters
        Text(
          'Type',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                context,
                label: 'All',
                isSelected: selectedType == null,
                onTap: () => onTypeChanged?.call(null),
              ),
              const SizedBox(width: 8),
              ...InvoiceType.values.map((type) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(
                  context,
                  label: _getTypeLabel(type),
                  isSelected: selectedType == type,
                  onTap: () => onTypeChanged?.call(type),
                  color: _getTypeColor(type),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppColors.primary)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (color ?? AppColors.primary)
                : Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (color ?? AppColors.primary).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? Colors.white : AppColors.textBlack,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
        ),
      ),
    );
  }

  String _getStatusLabel(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
      case InvoiceStatus.refunded:
        return 'Refunded';
    }
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.sent:
        return Colors.blue;
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.cancelled:
        return Colors.grey;
      case InvoiceStatus.refunded:
        return Colors.orange;
    }
  }

  String _getTypeLabel(InvoiceType type) {
    switch (type) {
      case InvoiceType.medicalService:
        return 'Medical Service';
      case InvoiceType.prescription:
        return 'Prescription';
      case InvoiceType.consultation:
        return 'Consultation';
      case InvoiceType.test:
        return 'Medical Test';
      case InvoiceType.procedure:
        return 'Procedure';
      case InvoiceType.other:
        return 'Other';
    }
  }

  Color _getTypeColor(InvoiceType type) {
    switch (type) {
      case InvoiceType.medicalService:
        return Colors.blue;
      case InvoiceType.prescription:
        return Colors.green;
      case InvoiceType.consultation:
        return Colors.purple;
      case InvoiceType.test:
        return Colors.orange;
      case InvoiceType.procedure:
        return Colors.red;
      case InvoiceType.other:
        return Colors.grey;
    }
  }
} 