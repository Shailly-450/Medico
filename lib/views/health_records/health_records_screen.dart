import 'package:flutter/material.dart';
import '../../core/views/base_view.dart';
import '../../viewmodels/health_records_view_model.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/health_record_card.dart';
import 'widgets/search_filter_bar.dart';
import 'widgets/category_filter_chips.dart';
import 'health_record_detail_screen.dart';
import '../shared/profile_header.dart';

class HealthRecordsScreen extends StatelessWidget {
  const HealthRecordsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<HealthRecordsViewModel>(
      viewModelBuilder: () => HealthRecordsViewModel(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: Column(
            children: [
              // Header
              ProfileHeader(
                name: 'Health Records',
                location: 'Your medical history',
                subtitle: '${model.allRecords.length} records available',
                notificationCount: 0,
                onNotificationTap: () {},
              ),

              // Search and Filter Bar
              SearchFilterBar(
                searchQuery: model.searchQuery,
                showImportantOnly: model.showImportantOnly,
                onSearchChanged: model.setSearchQuery,
                onImportantToggle: model.toggleImportantOnly,
              ),

              // Category Filter Chips
              CategoryFilterChips(
                categories: model.categories,
                selectedCategory: model.selectedCategory,
                onCategorySelected: model.setCategory,
              ),

              // Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    // Refresh data
                    model.init();
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Records Section
                        _buildRecordsSection(context, model),

                        const SizedBox(height: 20),

                        // Quick Actions
                        _buildQuickActions(context, model),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddRecordDialog(context, model);
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildRecordsSection(BuildContext context, HealthRecordsViewModel model) {
    if (model.filteredRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_information_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No records found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Medical Records',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
            ),
            Text(
              '${model.filteredRecords.length} records',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: model.filteredRecords.length,
          itemBuilder: (context, index) {
            final record = model.filteredRecords[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: HealthRecordCard(
                record: record,
                onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => HealthRecordDetailScreen(record: record),
                      ),
                    ),
                onImportantToggle: () => model.markAsImportant(record.id),
                onDelete: () => _showDeleteConfirmation(context, model, record.id),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, HealthRecordsViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildQuickActionCard(
              context,
              'Add Vital Signs',
              Icons.favorite,
              AppColors.primary,
              () => _showAddVitalSignsDialog(context, model),
            ),
            _buildQuickActionCard(
              context,
              'Upload Document',
              Icons.upload_file,
              AppColors.accent,
              () => _showUploadDialog(context),
            ),
            _buildQuickActionCard(
              context,
              'Export Records',
              Icons.download,
              Colors.blue,
              () => _showExportDialog(context),
            ),
            _buildQuickActionCard(
              context,
              'Share Records',
              Icons.share,
              Colors.green,
              () => _showShareDialog(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddRecordDialog(BuildContext context, HealthRecordsViewModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Health Record'),
        content: const Text('This feature will allow you to add new health records.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddVitalSignsDialog(BuildContext context, HealthRecordsViewModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Vital Signs'),
        content: const Text('This feature will allow you to manually enter vital signs.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Document'),
        content: const Text('This feature will allow you to upload medical documents.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Records'),
        content: const Text('This feature will allow you to export your health records.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Records'),
        content: const Text('This feature will allow you to share your health records with healthcare providers.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, HealthRecordsViewModel model, String recordId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this health record? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              model.deleteRecord(recordId);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 