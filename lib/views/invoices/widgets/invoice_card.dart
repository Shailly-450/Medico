import 'package:flutter/material.dart';
import '../../../models/invoice.dart';
import '../../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final VoidCallback? onMarkAsPaid;

  const InvoiceCard({
    Key? key,
    required this.invoice,
    this.onTap,
    this.onDownload,
    this.onMarkAsPaid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with invoice number and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invoice #${invoice.invoiceNumber}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textBlack,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          invoice.typeDisplayName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatusChip(context),
                      const SizedBox(height: 8),
                      // Tax and claim flags
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (invoice.isTaxDeductible)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.receipt, size: 12, color: Colors.green[700]),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Tax',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          if (invoice.isTaxDeductible && invoice.isClaimable)
                            const SizedBox(width: 4),
                          if (invoice.isClaimable)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.medical_services, size: 12, color: Colors.blue[700]),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Claim',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Provider and amount info
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.providerName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textBlack,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(invoice.issueDate),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${invoice.currency} ${invoice.total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      if (invoice.daysUntilDue > 0)
                        Text(
                          'Due in ${invoice.daysUntilDue} days',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: invoice.isDueSoon ? Colors.orange : AppColors.textSecondary,
                                fontWeight: invoice.isDueSoon ? FontWeight.w600 : FontWeight.normal,
                              ),
                        )
                      else if (invoice.isOverdue)
                        Text(
                          'Overdue by ${invoice.daysUntilDue.abs()} days',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                        )
                      else if (invoice.isPaid)
                        Text(
                          'Paid on ${DateFormat('MMM dd, yyyy').format(invoice.paidDate!)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Items summary
              if (invoice.items.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Items (${invoice.items.length})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...invoice.items.take(2).map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '• ${item.description}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textBlack,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${invoice.currency} ${item.totalPrice.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      )),
                      if (invoice.items.length > 2)
                        Text(
                          '+${invoice.items.length - 2} more items',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Action buttons
              Row(
                children: [
                  if (!invoice.isPaid && !invoice.isCancelled) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onMarkAsPaid,
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Mark as Paid'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onDownload,
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color chipColor;
    Color textColor;
    IconData? icon;

    switch (invoice.status) {
      case InvoiceStatus.paid:
        chipColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        icon = Icons.check_circle;
        break;
      case InvoiceStatus.overdue:
        chipColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        icon = Icons.warning;
        break;
      case InvoiceStatus.sent:
        chipColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        icon = Icons.send;
        break;
      case InvoiceStatus.draft:
        chipColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        icon = Icons.edit;
        break;
      case InvoiceStatus.cancelled:
        chipColor = Colors.grey[200]!;
        textColor = Colors.grey[600]!;
        icon = Icons.cancel;
        break;
      case InvoiceStatus.refunded:
        chipColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        icon = Icons.refresh;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            invoice.statusDisplayName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
} 