import 'package:flutter/material.dart';
import '../../../models/insurance.dart';
import '../../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class InsuranceCard extends StatelessWidget {
  final Insurance insurance;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const InsuranceCard({
    Key? key,
    required this.insurance,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with provider name and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insurance.insuranceProvider,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textBlack,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Policy #${insurance.policyNumber}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),
              const SizedBox(height: 16),

              // Policy holder info
              Text(
                'Policy Holder',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                insurance.policyHolderName,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),

              // Validity dates
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDateInfo(
                    context,
                    'Valid From',
                    insurance.validFrom,
                    Icons.calendar_today,
                  ),
                  _buildDateInfo(
                    context,
                    'Valid To',
                    insurance.validTo,
                    Icons.event,
                    isExpired: !insurance.isValid,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onEdit != null)
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit',
                      color: AppColors.primary,
                    ),
                  if (onDelete != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete),
                      tooltip: 'Delete',
                      color: Colors.red,
                    ),
                  ],
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
    String text;
    IconData icon;

    if (insurance.isValid) {
      if (insurance.isExpiringSoon) {
        chipColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        text = 'Expiring Soon';
        icon = Icons.warning;
      } else {
        chipColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        text = 'Valid';
        icon = Icons.check_circle;
      }
    } else {
      chipColor = Colors.red[100]!;
      textColor = Colors.red[800]!;
      text = 'Expired';
      icon = Icons.error;
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
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo(
    BuildContext context,
    String label,
    DateTime date,
    IconData icon, {
    bool isExpired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isExpired ? Colors.red : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              DateFormat('MMM dd, yyyy').format(date),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isExpired ? Colors.red : AppColors.textBlack,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
