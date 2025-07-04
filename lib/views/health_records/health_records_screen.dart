import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/views/base_view.dart';
import '../../viewmodels/health_records_view_model.dart';
import '../../viewmodels/family_members_view_model.dart';
import '../../core/theme/app_colors.dart';
import '../../models/family_member.dart';
import 'widgets/health_record_card.dart';
import 'widgets/search_filter_bar.dart';
import 'widgets/category_filter_chips.dart';
import 'health_record_detail_screen.dart';
import '../shared/profile_header.dart';

class HealthRecordsScreen extends StatelessWidget {
  const HealthRecordsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final familyVM = context.watch<FamilyMembersViewModel>();
    final currentProfile = familyVM.currentProfile;

    return BaseView<HealthRecordsViewModel>(
      viewModelBuilder: () {
        final viewModel = HealthRecordsViewModel();
        // Set the current family member based on the current profile
        if (currentProfile != null) {
          viewModel.setCurrentFamilyMember(currentProfile.id);
        }
        return viewModel;
      },
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: Column(
            children: [
              // Header with Family Member Selector
              _buildHeader(context, model, familyVM, currentProfile),

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
                    if (currentProfile != null) {
                      model.setCurrentFamilyMember(currentProfile.id);
                    }
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Family Summary Section
                        _buildFamilySummarySection(context, model, familyVM),

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
            _showAddRecordDialog(context, model, currentProfile);
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFamilySummarySection(BuildContext context, HealthRecordsViewModel model, FamilyMembersViewModel familyVM) {
    final recordCounts = model.getFamilyMemberRecordCounts();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Family Health Summary',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
        ),
        const SizedBox(height: 12), // slightly reduced
        SizedBox(
          height: 100, // reduced from 100
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: familyVM.members.length,
            itemBuilder: (context, index) {
              final member = familyVM.members[index];
              final recordCount = recordCounts[member.id] ?? 0;
              final isCurrentProfile = familyVM.currentProfile?.id == member.id;
              
              return Container(
                width: 150, // reduced from 120

                margin: const EdgeInsets.only(right: 8), // reduced
                child: Card(
                  elevation: isCurrentProfile ? 4 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: isCurrentProfile 
                      ? BorderSide(color: AppColors.primary, width: 2)
                      : BorderSide.none,
                  ),
                  child: InkWell(
                    onTap: () {
                      familyVM.switchProfile(member);
                      model.setCurrentFamilyMember(member.id);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0), // reduced from 12
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 16, // reduced from 20
                            backgroundImage: member.imageUrl.isNotEmpty 
                              ? NetworkImage(member.imageUrl) 
                              : null,
                            backgroundColor: AppColors.primary.withOpacity(0.2),
                            child: member.imageUrl.isEmpty 
                              ? Text(
                                  member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12, // reduced from 16
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                          ),
                          const SizedBox(height: 4), // reduced from 8
                          Text(
                            member.name,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              fontSize: 12, // smaller font
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '$recordCount records',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11, // smaller font
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, HealthRecordsViewModel model, FamilyMembersViewModel familyVM, FamilyMember? currentProfile) {
    final textTheme = Theme.of(context).textTheme;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title and Family Member Selector
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Records',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentProfile != null 
                        ? '${model.getRecordsCountForFamilyMember(currentProfile.id)} records for ${currentProfile.name}'
                        : 'Select a family member',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Family Member Selector
              if (familyVM.members.isNotEmpty)
                PopupMenuButton<FamilyMember>(
                  offset: const Offset(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (currentProfile != null) ...[
                          CircleAvatar(
                            radius: 12,
                            backgroundImage: currentProfile.imageUrl.isNotEmpty 
                              ? NetworkImage(currentProfile.imageUrl) 
                              : null,
                            backgroundColor: AppColors.primary.withOpacity(0.2),
                            child: currentProfile.imageUrl.isEmpty 
                              ? Text(
                                  currentProfile.name.isNotEmpty ? currentProfile.name[0].toUpperCase() : '?',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            currentProfile.name,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ] else ...[
                          Icon(Icons.person, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Select Member',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, color: AppColors.primary),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => familyVM.members.map((member) {
                    final isSelected = currentProfile?.id == member.id;
                    return PopupMenuItem<FamilyMember>(
                      value: member,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: member.imageUrl.isNotEmpty 
                              ? NetworkImage(member.imageUrl) 
                              : null,
                            backgroundColor: AppColors.primary.withOpacity(0.2),
                            child: member.imageUrl.isEmpty 
                              ? Text(
                                  member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.name,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${model.getRecordsCountForFamilyMember(member.id)} records',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                        ],
                      ),
                    );
                  }).toList(),
                  onSelected: (member) {
                    familyVM.switchProfile(member);
                    model.setCurrentFamilyMember(member.id);
                  },
                ),
            ],
          ),
        ],
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
    final familyVM = context.watch<FamilyMembersViewModel>();
    final currentProfile = familyVM.currentProfile;
    
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
              () => _showAddVitalSignsDialog(context, model, currentProfile),
            ),
            _buildQuickActionCard(
              context,
              'Upload Document',
              Icons.upload_file,
              AppColors.accent,
              () => _showUploadDialog(context, currentProfile),
            ),
            _buildQuickActionCard(
              context,
              'Export Records',
              Icons.download,
              Colors.blue,
              () => _showExportDialog(context, currentProfile),
            ),
            _buildQuickActionCard(
              context,
              'Share Records',
              Icons.share,
              Colors.green,
              () => _showShareDialog(context, currentProfile),
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

  void _showAddRecordDialog(BuildContext context, HealthRecordsViewModel model, FamilyMember? currentProfile) {
    if (currentProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a family member first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Health Record for ${currentProfile.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This feature will allow you to add new health records for ${currentProfile.name}.'),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: currentProfile.imageUrl.isNotEmpty 
                    ? NetworkImage(currentProfile.imageUrl) 
                    : null,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: currentProfile.imageUrl.isEmpty 
                    ? Text(
                        currentProfile.name.isNotEmpty ? currentProfile.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
                ),
                const SizedBox(width: 12),
                Text(
                  currentProfile.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
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

  void _showAddVitalSignsDialog(BuildContext context, HealthRecordsViewModel model, FamilyMember? currentProfile) {
    if (currentProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a family member first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Vital Signs for ${currentProfile.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This feature will allow you to manually enter vital signs for ${currentProfile.name}.'),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: currentProfile.imageUrl.isNotEmpty 
                    ? NetworkImage(currentProfile.imageUrl) 
                    : null,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: currentProfile.imageUrl.isEmpty 
                    ? Text(
                        currentProfile.name.isNotEmpty ? currentProfile.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
                ),
                const SizedBox(width: 12),
                Text(
                  currentProfile.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
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

  void _showUploadDialog(BuildContext context, FamilyMember? currentProfile) {
    if (currentProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a family member first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upload Document for ${currentProfile.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This feature will allow you to upload medical documents for ${currentProfile.name}.'),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: currentProfile.imageUrl.isNotEmpty 
                    ? NetworkImage(currentProfile.imageUrl) 
                    : null,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: currentProfile.imageUrl.isEmpty 
                    ? Text(
                        currentProfile.name.isNotEmpty ? currentProfile.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
                ),
                const SizedBox(width: 12),
                Text(
                  currentProfile.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
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

  void _showExportDialog(BuildContext context, FamilyMember? currentProfile) {
    if (currentProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a family member first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Records for ${currentProfile.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This feature will allow you to export health records for ${currentProfile.name}.'),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: currentProfile.imageUrl.isNotEmpty 
                    ? NetworkImage(currentProfile.imageUrl) 
                    : null,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: currentProfile.imageUrl.isEmpty 
                    ? Text(
                        currentProfile.name.isNotEmpty ? currentProfile.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
                ),
                const SizedBox(width: 12),
                Text(
                  currentProfile.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
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

  void _showShareDialog(BuildContext context, FamilyMember? currentProfile) {
    if (currentProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a family member first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Share Records for ${currentProfile.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This feature will allow you to share health records for ${currentProfile.name} with healthcare providers.'),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: currentProfile.imageUrl.isNotEmpty 
                    ? NetworkImage(currentProfile.imageUrl) 
                    : null,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: currentProfile.imageUrl.isEmpty 
                    ? Text(
                        currentProfile.name.isNotEmpty ? currentProfile.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
                ),
                const SizedBox(width: 12),
                Text(
                  currentProfile.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
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