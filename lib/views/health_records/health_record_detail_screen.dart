import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/health_record.dart';
import '../../models/family_member.dart';
import '../../viewmodels/family_members_view_model.dart';
import '../../core/theme/app_colors.dart';

class HealthRecordDetailScreen extends StatelessWidget {
  final HealthRecord record;
  final Function()? onDelete;
  final Function()? onToggleImportant;
  final Function()? onEdit;

  const HealthRecordDetailScreen({
    Key? key,
    required this.record,
    this.onDelete,
    this.onToggleImportant,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final familyVM =
        Provider.of<FamilyMembersViewModel>(context, listen: false);
    final familyMember = familyVM.members.firstWhere(
      (member) => member.id == record.familyMemberId,
      orElse: () =>
          FamilyMember(id: '', name: 'Unknown', role: '', imageUrl: ''),
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          record.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              record.isImportant ? Icons.star : Icons.star_border,
              color: record.isImportant ? Colors.amber : Colors.white,
            ),
            onPressed: onToggleImportant,
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handlePopupSelection(context, value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: const [
                    Icon(Icons.edit, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: const [
                    Icon(Icons.share, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Share',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: const [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            _buildHeaderSection(context),

            const SizedBox(height: 16),

            // Record Details Section
            _buildDetailsSection(context, familyMember),

            const SizedBox(height: 16),

            // Data Section (conditionally shown)
            if (_hasDataContent(record)) _buildDataSection(context),

            const SizedBox(height: 16),

            // Provider Section
            if (record.provider != null) _buildProviderSection(context),

            const SizedBox(height: 16),

            // Attachments Section (conditionally shown)
            if (record.attachments != null && record.attachments!.isNotEmpty)
              _buildAttachmentsSection(context),

            const SizedBox(height: 16),

            // Actions Section
            _buildActionsSection(context),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper Methods

  bool _hasDataContent(HealthRecord record) {
    return (record.medicalHistory != null &&
            record.medicalHistory!.isNotEmpty) ||
        (record.allergies != null && record.allergies!.isNotEmpty) ||
        (record.medications != null && record.medications!.isNotEmpty) ||
        (record.labResults != null && record.labResults!.isNotEmpty) ||
        (record.imaging != null && record.imaging!.isNotEmpty) ||
        (record.surgery != null && record.surgery!.isNotEmpty) ||
        (record.familyHistory != null && record.familyHistory!.isNotEmpty);
  }

  void _handlePopupSelection(BuildContext context, String value) {
    switch (value) {
      case 'edit':
        if (onEdit != null) onEdit!();
        break;
      case 'share':
        _shareRecord(context);
        break;
      case 'delete':
        _showDeleteConfirmation(context);
        break;
    }
  }

  // Section Builders

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(record.category),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.category,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.title,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (record.description != null && record.description!.isNotEmpty)
              Text(
                record.description!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(record.date),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const Spacer(),
                if (record.status != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      record.status!.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(
      BuildContext context, FamilyMember? familyMember) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Record Details',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            if (familyMember != null)
              _buildDetailRowWithIcon(
                icon: Icons.family_restroom,
                label: 'Family Member',
                value: familyMember.name,
                valueColor: AppColors.primary,
              ),
            if (familyMember != null) const SizedBox(height: 16),
            _buildDetailRow('Category', record.category),
            if (record.status != null)
              _buildDetailRow('Status', record.status!),
            _buildDetailRow('Date', _formatDate(record.date)),
            if (record.isImportant)
              _buildDetailRow('Priority', 'Important', valueColor: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Record Data',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            if (record.recordType == 'medical_history' &&
                record.medicalHistory != null)
              _buildMedicalHistoryData(record.medicalHistory!),
            if (record.recordType == 'allergies' && record.allergies != null)
              _buildAllergiesData(record.allergies!),
            if (record.recordType == 'medications' &&
                record.medications != null)
              _buildMedicationsData(record.medications!),
            if (record.recordType == 'lab_results' && record.labResults != null)
              _buildLabResultsData(record.labResults!),
            if (record.recordType == 'imaging' && record.imaging != null)
              _buildImagingData(record.imaging!),
            if (record.recordType == 'surgery' && record.surgery != null)
              _buildSurgeryData(record.surgery!),
            if (record.recordType == 'family_history' &&
                record.familyHistory != null)
              _buildFamilyHistoryData(record.familyHistory!),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Healthcare Provider',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: record.providerImage != null
                      ? NetworkImage(record.providerImage!)
                      : null,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: record.providerImage == null
                      ? const Icon(Icons.medical_services,
                          color: AppColors.primary)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.provider!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Healthcare Provider',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _contactProvider(context),
                  icon: const Icon(Icons.message, color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attachments',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: record.attachments!.map((attachment) {
                return InkWell(
                  onTap: () => _viewAttachment(context, attachment),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getAttachmentIcon(attachment['fileType']),
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          attachment['fileName'],
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Edit',
                    Icons.edit,
                    AppColors.primary,
                    onEdit ?? () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Share',
                    Icons.share,
                    Colors.blue,
                    () => _shareRecord(context),
                  ),
                ),
              ],
            ),
            if (record.attachments != null &&
                record.attachments!.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: _buildActionButton(
                  context,
                  'View Attachments',
                  Icons.attachment,
                  Colors.green,
                  () => _viewAllAttachments(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Data Type Specific Builders

  Widget _buildMedicalHistoryData(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Condition', data['condition'] ?? 'Not specified'),
        if (data['severity'] != null)
          _buildDetailRow('Severity', data['severity']),
        if (data['status'] != null) _buildDetailRow('Status', data['status']),
        if (data['treatment'] != null)
          _buildDetailRow('Treatment', data['treatment']),
        if (data['notes'] != null) _buildDetailRow('Notes', data['notes']),
      ],
    );
  }

  Widget _buildAllergiesData(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Allergen', data['allergen'] ?? 'Not specified'),
        if (data['reaction'] != null)
          _buildDetailRow('Reaction', data['reaction']),
        if (data['severity'] != null)
          _buildDetailRow('Severity', data['severity']),
        if (data['medications'] != null && data['medications'].isNotEmpty)
          _buildDetailRow('Medications', data['medications'].join(', ')),
      ],
    );
  }

  Widget _buildMedicationsData(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Medication', data['name'] ?? 'Not specified'),
        if (data['dosage'] != null) _buildDetailRow('Dosage', data['dosage']),
        if (data['frequency'] != null)
          _buildDetailRow('Frequency', data['frequency']),
        if (data['reason'] != null) _buildDetailRow('Reason', data['reason']),
        if (data['sideEffects'] != null && data['sideEffects'].isNotEmpty)
          _buildDetailRow('Side Effects', data['sideEffects'].join(', ')),
      ],
    );
  }

  Widget _buildLabResultsData(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Test Name', data['testName'] ?? 'Not specified'),
        _buildDetailRow('Result', '${data['result']} ${data['unit'] ?? ''}'),
        _buildDetailRow(
            'Normal Range', data['referenceRange'] ?? 'Not specified'),
        _buildDetailRow('Status', data['status'] ?? 'Not specified'),
        if (data['labName'] != null)
          _buildDetailRow('Lab Name', data['labName']),
      ],
    );
  }

  Widget _buildImagingData(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Type', data['type'] ?? 'Not specified'),
        _buildDetailRow('Body Part', data['bodyPart'] ?? 'Not specified'),
        if (data['findings'] != null)
          _buildDetailRow('Findings', data['findings']),
        if (data['radiologist'] != null)
          _buildDetailRow('Radiologist', data['radiologist']),
      ],
    );
  }

  Widget _buildSurgeryData(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Procedure', data['procedure'] ?? 'Not specified'),
        if (data['surgeon'] != null)
          _buildDetailRow('Surgeon', data['surgeon']),
        if (data['hospital'] != null)
          _buildDetailRow('Hospital', data['hospital']),
        if (data['complications'] != null)
          _buildDetailRow('Complications', data['complications']),
        if (data['recoveryNotes'] != null)
          _buildDetailRow('Recovery Notes', data['recoveryNotes']),
      ],
    );
  }

  Widget _buildFamilyHistoryData(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Relation', data['relation'] ?? 'Not specified'),
        _buildDetailRow('Condition', data['condition'] ?? 'Not specified'),
        if (data['ageOfOnset'] != null)
          _buildDetailRow('Age of Onset', data['ageOfOnset'].toString()),
      ],
    );
  }

  // UI Components

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithIcon({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: iconColor ?? AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  // Utility Methods

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Vital Signs':
        return Icons.favorite;
      case 'Lab Results':
        return Icons.science;
      case 'Medications':
        return Icons.medication;
      case 'Appointments':
        return Icons.calendar_today;
      case 'Procedures':
        return Icons.medical_services;
      case 'Immunizations':
        return Icons.vaccines;
      case 'Allergies':
        return Icons.warning;
      case 'Conditions':
        return Icons.health_and_safety;
      default:
        return Icons.medical_information;
    }
  }

  IconData _getAttachmentIcon(String fileType) {
    if (fileType.contains('image')) return Icons.image;
    if (fileType.contains('pdf')) return Icons.picture_as_pdf;
    if (fileType.contains('word')) return Icons.description;
    return Icons.insert_drive_file;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Action Handlers

  void _contactProvider(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Provider'),
        content: const Text(
            'Would you like to message or call the healthcare provider?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement message functionality
            },
            child: const Text('Message'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement call functionality
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _viewAttachment(BuildContext context, Map<String, dynamic> attachment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(attachment['fileName']),
        content:
            const Text('Would you like to view or download this attachment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement view functionality
            },
            child: const Text('View'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement download functionality
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _viewAllAttachments(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Attachments'),
          ),
          body: ListView.builder(
            itemCount: record.attachments?.length ?? 0,
            itemBuilder: (context, index) {
              final attachment = record.attachments![index];
              return ListTile(
                leading: Icon(_getAttachmentIcon(attachment['fileType'])),
                title: Text(attachment['fileName']),
                subtitle: Text(attachment['fileType']),
                onTap: () => _viewAttachment(context, attachment),
              );
            },
          ),
        ),
      ),
    );
  }

  void _shareRecord(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Record'),
        content: const Text(
            'Select how you would like to share this health record:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement email sharing
            },
            child: const Text('Email'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement other sharing options
            },
            child: const Text('Other Apps'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text(
            'Are you sure you want to delete this health record? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (onDelete != null) onDelete!();
              Navigator.pop(context); // Go back to previous screen
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
