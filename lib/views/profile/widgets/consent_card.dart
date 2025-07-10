import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/consent.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConsentCard extends StatelessWidget {
  final ConsentItem consent;
  final VoidCallback? onTap;
  final VoidCallback? onGrant;
  final VoidCallback? onRevoke;
  final VoidCallback? onRenew;

  const ConsentCard({
    Key? key,
    required this.consent,
    this.onTap,
    this.onGrant,
    this.onRevoke,
    this.onRenew,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatusIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          consent.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          consent.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildCategoryChip(),
                ],
              ),
              const SizedBox(height: 12),
              _buildStatusInfo(),
              const SizedBox(height: 12),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;

    switch (consent.status) {
      case ConsentStatus.granted:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case ConsentStatus.denied:
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case ConsentStatus.pending:
        icon = Icons.pending;
        color = Colors.orange;
        break;
      case ConsentStatus.expired:
        icon = Icons.warning;
        color = Colors.red;
        break;
      case ConsentStatus.revoked:
        icon = Icons.block;
        color = Colors.grey;
        break;
      case ConsentStatus.notRequested:
        icon = Icons.help_outline;
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildCategoryChip() {
    Color color;
    String label;

    switch (consent.category) {
      case ConsentCategory.essential:
        color = Colors.red;
        label = 'Essential';
        break;
      case ConsentCategory.functional:
        color = Colors.blue;
        label = 'Functional';
        break;
      case ConsentCategory.analytics:
        color = Colors.purple;
        label = 'Analytics';
        break;
      case ConsentCategory.marketing:
        color = Colors.orange;
        label = 'Marketing';
        break;
      case ConsentCategory.thirdParty:
        color = Colors.indigo;
        label = 'Third Party';
        break;
      case ConsentCategory.health:
        color = Colors.teal;
        label = 'Health';
        break;
      case ConsentCategory.privacy:
        color = Colors.grey;
        label = 'Privacy';
        break;
      case ConsentCategory.research:
        color = Colors.green;
        label = 'Research';
        break;
      default:
        color = Colors.black;
        label = 'Other';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatusInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              _getStatusText(),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        if (consent.grantedAt != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Granted ${timeago.format(consent.grantedAt!)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
        if (consent.expiresAt != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                consent.isExpired ? Icons.warning : Icons.timer,
                size: 16,
                color: consent.isExpired ? Colors.red : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                consent.isExpired
                    ? 'Expired ${timeago.format(consent.expiresAt!)}'
                    : 'Expires ${timeago.format(consent.expiresAt!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: consent.isExpired ? Colors.red : AppColors.textSecondary,
                  fontWeight: consent.isExpired ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
        if (consent.isRequired) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.lock,
                size: 16,
                color: Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                'Required for app functionality',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (consent.status == ConsentStatus.notRequested || 
            consent.status == ConsentStatus.denied) ...[
          Expanded(
            child: ElevatedButton(
              onPressed: onGrant,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Grant'),
            ),
          ),
        ],
        if (consent.status == ConsentStatus.granted && consent.canRevoke) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: onRevoke,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Revoke'),
            ),
          ),
        ],
        if (consent.needsRenewal) ...[
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: onRenew,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Renew'),
            ),
          ),
        ],
        if (consent.status == ConsentStatus.pending) ...[
          Expanded(
            child: ElevatedButton(
              onPressed: onGrant,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Review'),
            ),
          ),
        ],
      ],
    );
  }

  String _getStatusText() {
    switch (consent.status) {
      case ConsentStatus.granted:
        return consent.isActive ? 'Active' : 'Expired';
      case ConsentStatus.denied:
        return 'Denied';
      case ConsentStatus.pending:
        return 'Pending Review';
      case ConsentStatus.expired:
        return 'Expired';
      case ConsentStatus.revoked:
        return 'Revoked';
      case ConsentStatus.notRequested:
        return 'Not Requested';
    }
  }
} 