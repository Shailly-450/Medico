import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/consent.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConsentDetailDialog extends StatelessWidget {
  final ConsentItem consent;

  const ConsentDetailDialog({
    Key? key,
    required this.consent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDescription(),
                    const SizedBox(height: 16),
                    _buildStatusSection(),
                    const SizedBox(height: 16),
                    _buildTimelineSection(),
                    const SizedBox(height: 16),
                    _buildMetadataSection(),
                  ],
                ),
              ),
            ),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getConsentIcon(),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  consent.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getCategoryLabel(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textBlack,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          consent.detailedDescription,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textBlack,
          ),
        ),
        const SizedBox(height: 12),
        _buildStatusRow('Current Status', _getStatusText(), _getStatusColor()),
        if (consent.grantedAt != null)
          _buildStatusRow('Granted', timeago.format(consent.grantedAt!), Colors.green),
        if (consent.revokedAt != null)
          _buildStatusRow('Revoked', timeago.format(consent.revokedAt!), Colors.red),
        if (consent.expiresAt != null)
          _buildStatusRow(
            'Expires',
            timeago.format(consent.expiresAt!),
            consent.isExpired ? Colors.red : Colors.orange,
          ),
        if (consent.grantedBy != null)
          _buildStatusRow('Granted By', consent.grantedBy!, AppColors.textSecondary),
        if (consent.revokedBy != null)
          _buildStatusRow('Revoked By', consent.revokedBy!, AppColors.textSecondary),
        _buildStatusRow('Required', consent.isRequired ? 'Yes' : 'No', 
          consent.isRequired ? Colors.red : Colors.green),
        _buildStatusRow('Can Revoke', consent.canRevoke ? 'Yes' : 'No',
          consent.canRevoke ? Colors.green : Colors.grey),
        _buildStatusRow('Auto Renew', consent.autoRenew ? 'Yes' : 'No',
          consent.autoRenew ? Colors.blue : Colors.grey),
      ],
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Timeline',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textBlack,
          ),
        ),
        const SizedBox(height: 12),
        _buildTimelineItem(
          'Created',
          timeago.format(consent.createdAt),
          Icons.add_circle,
          Colors.blue,
        ),
        if (consent.grantedAt != null)
          _buildTimelineItem(
            'Granted',
            timeago.format(consent.grantedAt!),
            Icons.check_circle,
            Colors.green,
          ),
        if (consent.revokedAt != null)
          _buildTimelineItem(
            'Revoked',
            timeago.format(consent.revokedAt!),
            Icons.cancel,
            Colors.red,
          ),
        if (consent.expiresAt != null)
          _buildTimelineItem(
            consent.isExpired ? 'Expired' : 'Expires',
            timeago.format(consent.expiresAt!),
            consent.isExpired ? Icons.warning : Icons.timer,
            consent.isExpired ? Colors.red : Colors.orange,
          ),
        _buildTimelineItem(
          'Last Updated',
          timeago.format(consent.updatedAt),
          Icons.update,
          AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildTimelineItem(String label, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textBlack,
              ),
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection() {
    if (consent.metadata == null || consent.metadata!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textBlack,
          ),
        ),
        const SizedBox(height: 12),
        ...consent.metadata!.entries.map((entry) => _buildStatusRow(
          entry.key,
          entry.value.toString(),
          AppColors.textSecondary,
        )),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          if (consent.status == ConsentStatus.notRequested || 
              consent.status == ConsentStatus.denied) ...[
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, 'grant');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Grant Consent'),
              ),
            ),
          ],
          if (consent.status == ConsentStatus.granted && consent.canRevoke) ...[
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context, 'revoke');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Revoke Consent'),
              ),
            ),
          ],
          if (consent.needsRenewal) ...[
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, 'renew');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Renew Consent'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getConsentIcon() {
    switch (consent.type) {
      case ConsentType.dataCollection:
        return Icons.collections;
      case ConsentType.dataSharing:
        return Icons.share;
      case ConsentType.marketing:
        return Icons.campaign;
      case ConsentType.analytics:
        return Icons.analytics;
      case ConsentType.location:
        return Icons.location_on;
      case ConsentType.camera:
        return Icons.camera_alt;
      case ConsentType.microphone:
        return Icons.mic;
      case ConsentType.notifications:
        return Icons.notifications;
      case ConsentType.healthData:
        return Icons.health_and_safety;
      case ConsentType.thirdPartyServices:
        return Icons.business;
      case ConsentType.aiProcessing:
        return Icons.psychology;
      case ConsentType.emergencyContacts:
        return Icons.emergency;
      case ConsentType.familyMembers:
        return Icons.family_restroom;
      case ConsentType.insurance:
        return Icons.security;
      case ConsentType.payment:
        return Icons.payment;
      case ConsentType.biometric:
        return Icons.fingerprint;
      case ConsentType.cloudStorage:
        return Icons.cloud;
      case ConsentType.research:
        return Icons.science;
      case ConsentType.advertising:
        return Icons.campaign;
      case ConsentType.personalizedContent:
        return Icons.person;
      case ConsentType.storage:
        return Icons.sd_storage;
      case ConsentType.socialMedia:
        return Icons.public;
      case ConsentType.familyAccess:
        return Icons.group;
      case ConsentType.cloudBackup:
        return Icons.backup;
      case ConsentType.dataExport:
        return Icons.file_upload;
      case ConsentType.telemedicine:
        return Icons.video_call;
      case ConsentType.medicationTracking:
        return Icons.medication;
      default:
        return Icons.help_outline;
    }
  }

  String _getCategoryLabel() {
    switch (consent.category) {
      case ConsentCategory.essential:
        return 'Essential';
      case ConsentCategory.functional:
        return 'Functional';
      case ConsentCategory.analytics:
        return 'Analytics';
      case ConsentCategory.marketing:
        return 'Marketing';
      case ConsentCategory.thirdParty:
        return 'Third Party';
      case ConsentCategory.health:
        return 'Health';
      case ConsentCategory.privacy:
        return 'Privacy';
      case ConsentCategory.research:
        return 'Research';
      default:
        return 'Other';
    }
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

  Color _getStatusColor() {
    switch (consent.status) {
      case ConsentStatus.granted:
        return consent.isActive ? Colors.green : Colors.red;
      case ConsentStatus.denied:
        return Colors.red;
      case ConsentStatus.pending:
        return Colors.orange;
      case ConsentStatus.expired:
        return Colors.red;
      case ConsentStatus.revoked:
        return Colors.grey;
      case ConsentStatus.notRequested:
        return Colors.grey;
    }
  }
} 