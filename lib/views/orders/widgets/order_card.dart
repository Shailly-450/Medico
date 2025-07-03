import 'package:flutter/material.dart';
import '../../../models/order.dart';
import '../../../core/theme/app_colors.dart';
import 'order_status_badge.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  final Function(Order)? onRepeatOrder;

  const OrderCard({
    Key? key,
    required this.order,
    required this.onTap,
    this.onRepeatOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with order ID and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(order.id.length - 6)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                OrderStatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 12),

            // Service provider name
            Text(
              order.serviceProviderName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Order items summary
            Text(
              _getItemsSummary(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),

            // Bottom row with date and total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(order.orderDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  '₹${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            // Payment status indicator
            if (order.paymentStatus != PaymentStatus.paid) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPaymentStatusColor(order.paymentStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getPaymentStatusText(order.paymentStatus),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _getPaymentStatusColor(order.paymentStatus),
                  ),
                ),
              ),
            ],

            // Repeat order button for completed orders
            if (order.status == OrderStatus.completed) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => onRepeatOrder?.call(order),
                  icon: const Icon(Icons.replay, size: 16),
                  label: const Text('Repeat Order'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.success,
                    side: const BorderSide(color: AppColors.success),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getItemsSummary() {
    if (order.items.isEmpty) return 'No items';
    
    if (order.items.length == 1) {
      return order.items.first.service.name;
    }
    
    final itemNames = order.items.map((item) => item.service.name).toList();
    if (itemNames.length <= 2) {
      return itemNames.join(', ');
    }
    
    return '${itemNames.take(2).join(', ')} +${itemNames.length - 2} more';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return AppColors.success;
      case PaymentStatus.pending:
        return AppColors.warning;
      case PaymentStatus.failed:
        return AppColors.error;
      case PaymentStatus.refunded:
        return AppColors.info;
    }
  }

  String _getPaymentStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.pending:
        return 'Payment Pending';
      case PaymentStatus.failed:
        return 'Payment Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }
} 