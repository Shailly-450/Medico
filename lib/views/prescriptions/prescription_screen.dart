import 'package:flutter/material.dart';
import '../../../models/prescription.dart';
import '../../../viewmodels/prescriptions_view_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/views/base_view.dart';
import './prescription_detail_screen.dart';
import './create_prescription_screen.dart';

class PrescriptionsScreen extends StatelessWidget {
  const PrescriptionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<PrescriptionsViewModel>(
      viewModelBuilder: () => PrescriptionsViewModel()..initialize(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Prescriptions'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            if (model.prescriptions.any((p) => p.id.startsWith('mock')))
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Text(
                  'Demo Mode (${model.prescriptions.where((p) => p.id.startsWith('mock')).length})',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => model.loadPrescriptions(),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchAndFilterSection(model),
            Expanded(child: _buildBody(context, model)),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _createPrescription(context),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterSection(PrescriptionsViewModel model) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: model.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search prescriptions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: model.statusFilter,
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All')),
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
              DropdownMenuItem(value: 'expired', child: Text('Expired')),
            ],
            onChanged: (value) {
              if (value != null) {
                model.setStatusFilter(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, PrescriptionsViewModel model) {
    if (model.isBusy) {
      return const LoadingIndicator();
    }

    if (model.error != null) {
      return ErrorView(
        error: model.error!,
        onRetry: () => model.loadPrescriptions(),
      );
    }

    final prescriptions = model.filteredPrescriptions;

    if (prescriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.note_alt_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No prescriptions found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              model.searchQuery.isEmpty
                  ? 'Your prescriptions will appear here'
                  : 'Try adjusting your search or filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: prescriptions.length,
      itemBuilder: (context, index) {
        final prescription = prescriptions[index];
        return _PrescriptionCard(
          prescription: prescription,
          onView: () => _viewPrescription(context, prescription),
          onEdit: () => _editPrescription(context, prescription),
          onDelete: () => _deletePrescription(context, model, prescription),
        );
      },
    );
  }

  void _createPrescription(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreatePrescriptionScreen(),
      ),
    );
  }

  void _viewPrescription(BuildContext context, Prescription prescription) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PrescriptionDetailScreen(prescription: prescription),
      ),
    );
  }

  void _editPrescription(BuildContext context, Prescription prescription) {
    // TODO: Implement edit prescription screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit prescription feature coming soon!'),
      ),
    );
  }

  void _deletePrescription(BuildContext context, PrescriptionsViewModel model, Prescription prescription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Prescription'),
        content: const Text('Are you sure you want to delete this prescription?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await model.deletePrescription(prescription.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Prescription deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  final Prescription prescription;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PrescriptionCard({
    Key? key,
    required this.prescription,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Dr. ${prescription.doctorName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(prescription),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                prescription.doctorSpecialty,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const Divider(height: 24),
              Text(
                'Diagnosis:',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                prescription.diagnosis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${prescription.medications.length} medications',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: onEdit,
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                        onPressed: onDelete,
                        tooltip: 'Delete',
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('View PDF'),
                        onPressed: onView,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(Prescription prescription) {
    Color color;
    String text;

    if (prescription.isExpired()) {
      color = Colors.red;
      text = 'Expired';
    } else if (prescription.isCompleted()) {
      color = Colors.green;
      text = 'Completed';
    } else {
      color = Colors.blue;
      text = 'Active';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Removed unused _formatDate method
}
