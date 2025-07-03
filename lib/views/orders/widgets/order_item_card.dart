import 'package:flutter/material.dart';
import '../../../models/order.dart';
import '../../../core/theme/app_colors.dart';

class OrderItemCard extends StatelessWidget {
  final OrderItem orderItem;

  const OrderItemCard({
    Key? key,
    required this.orderItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service name and price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  orderItem.service.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '₹${orderItem.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Service description
          if (orderItem.service.description.isNotEmpty) ...[
            Text(
              orderItem.service.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
          ],

          // Service details row
          Row(
            children: [
              // Category
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  orderItem.service.category,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Duration
              if (orderItem.service.duration > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${orderItem.service.duration} min',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Quantity
              if (orderItem.quantity > 1) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Qty: ${orderItem.quantity}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Unit price (if quantity > 1)
          if (orderItem.quantity > 1) ...[
            const SizedBox(height: 8),
            Text(
              '₹${orderItem.unitPrice.toStringAsFixed(2)} each',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          // Notes (if any)
          if (orderItem.notes != null && orderItem.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.amber[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.note,
                    size: 14,
                    color: Colors.amber[700],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      orderItem.notes!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.amber[800],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
} 