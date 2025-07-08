import 'package:flutter/material.dart';
import '../../../models/order.dart';
import '../../../core/theme/app_colors.dart';

class OrderStatusFilter extends StatelessWidget {
  final OrderStatus selectedStatus;
  final Function(OrderStatus) onStatusChanged;

  const OrderStatusFilter({
    Key? key,
    required this.selectedStatus,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('All', OrderStatus.pending, isSelected: selectedStatus == OrderStatus.pending),
          const SizedBox(width: 8),
          _buildFilterChip('Pending', OrderStatus.pending, isSelected: selectedStatus == OrderStatus.pending),
          const SizedBox(width: 8),
          _buildFilterChip('Confirmed', OrderStatus.confirmed, isSelected: selectedStatus == OrderStatus.confirmed),
          const SizedBox(width: 8),
          _buildFilterChip('In Progress', OrderStatus.inProgress, isSelected: selectedStatus == OrderStatus.inProgress),
          const SizedBox(width: 8),
          _buildFilterChip('Completed', OrderStatus.completed, isSelected: selectedStatus == OrderStatus.completed),
          const SizedBox(width: 8),
          _buildFilterChip('Cancelled', OrderStatus.cancelled, isSelected: selectedStatus == OrderStatus.cancelled),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, OrderStatus status, {required bool isSelected}) {
    return GestureDetector(
      onTap: () => onStatusChanged(status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
} 