import 'package:flutter/material.dart';
import '../../../models/order.dart';
import '../../../core/theme/app_colors.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _getStatusText(),
            style: TextStyle(
              color: _getStatusColor(),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.info;
      case OrderStatus.inProgress:
        return AppColors.primary;
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
      case OrderStatus.refunded:
        return Colors.purple;
    }
  }

  String _getStatusText() {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }
} 