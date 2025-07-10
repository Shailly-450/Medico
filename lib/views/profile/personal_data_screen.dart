import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // Not needed for this screen
import '../../core/views/base_view.dart';
import '../../viewmodels/personal_data_view_model.dart';
import '../../core/theme/app_colors.dart';
import '../../models/personal_data.dart';
import 'widgets/data_item_card.dart';
import 'widgets/export_dialog.dart';
import 'widgets/delete_dialog.dart';
import 'widgets/data_summary_card.dart';

class PersonalDataScreen extends StatelessWidget {
  const PersonalDataScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<PersonalDataViewModel>(
      viewModelBuilder: () => PersonalDataViewModel(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Personal Data Management',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: model.refreshData,
              tooltip: 'Refresh',
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showInfoDialog(context),
              tooltip: 'Information',
            ),
          ],
        ),
        body: model.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Summary Card
                  if (model.summary != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: DataSummaryCard(summary: model.summary!),
                    ),

                  // Error Message
                  if (model.errorMessage != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              model.errorMessage!,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red[700], size: 20),
                            onPressed: model.clearError,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),

                  // Progress Indicators
                  if (model.isExporting || model.isDeleting)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                model.isExporting ? Icons.download : Icons.delete,
                                color: model.isExporting ? AppColors.primary : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                model.isExporting ? 'Exporting Data...' : 'Deleting Data...',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: model.isExporting 
                                ? model.exportProgress 
                                : model.deletionProgress,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              model.isExporting ? AppColors.primary : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${((model.isExporting ? model.exportProgress : model.deletionProgress) * 100).toInt()}%',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: model.hasSelectedItems
                                ? () => _showExportDialog(context, model)
                                : null,
                            icon: const Icon(Icons.download),
                            label: const Text('Export Selected'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: model.hasSelectedItems
                                ? () => _showDeleteDialog(context, model)
                                : null,
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete Selected'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Selection Controls
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        TextButton.icon(
                          onPressed: model.selectAllItems,
                          icon: const Icon(Icons.select_all),
                          label: const Text('Select All'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: model.deselectAllItems,
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Clear Selection'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Data Items List
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: model.refreshData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: model.dataItems.length,
                        itemBuilder: (context, index) {
                          final item = model.dataItems[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: DataItemCard(
                              item: item,
                              onToggleSelection: () => model.toggleItemSelection(item.id),
                              categoryIcon: model.getCategoryIcon(item.category),
                              categoryColor: model.getCategoryColor(item.category),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showBulkActionsDialog(context, model),
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.more_vert),
          label: const Text('More Actions'),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Personal Data Management'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This feature allows you to:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Export your personal data in various formats'),
            Text('• Delete specific data categories'),
            Text('• View data usage and storage information'),
            Text('• Manage your privacy preferences'),
            SizedBox(height: 8),
            Text(
              'Note: Required data categories cannot be deleted.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, PersonalDataViewModel model) {
    showDialog(
      context: context,
      builder: (context) => ExportDialog(
        selectedFormat: model.selectedFormat,
        availableFormats: model.availableFormats,
        onFormatChanged: model.setExportFormat,
        onExport: (format) async {
          Navigator.pop(context);
          final request = await model.exportSelectedData();
          if (request != null && context.mounted) {
            _showExportSuccessDialog(context, request);
          }
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, PersonalDataViewModel model) {
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(
        selectedItems: model.selectedItems,
        onDelete: (reason) async {
          Navigator.pop(context);
          final request = await model.deleteSelectedData(reason);
          if (request != null && context.mounted) {
            _showDeleteSuccessDialog(context, request);
          }
        },
      ),
    );
  }

  void _showBulkActionsDialog(BuildContext context, PersonalDataViewModel model) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bulk Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.download, color: AppColors.primary),
              title: const Text('Export All Data'),
              subtitle: const Text('Export all your personal data'),
              onTap: () {
                Navigator.pop(context);
                _showExportAllDialog(context, model);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete All Data'),
              subtitle: const Text('Permanently delete all your data'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteAllDialog(context, model);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.orange),
              title: const Text('View Export History'),
              subtitle: const Text('Check previous export requests'),
              onTap: () {
                Navigator.pop(context);
                _showExportHistoryDialog(context, model);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.red),
              title: const Text('View Deletion History'),
              subtitle: const Text('Check previous deletion requests'),
              onTap: () {
                Navigator.pop(context);
                _showDeletionHistoryDialog(context, model);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showExportAllDialog(BuildContext context, PersonalDataViewModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export All Data'),
        content: const Text(
          'This will export all your personal data. This process may take several minutes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final request = await model.exportAllData();
              if (request != null && context.mounted) {
                _showExportSuccessDialog(context, request);
              }
            },
            child: const Text('Export All'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context, PersonalDataViewModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
          'This will permanently delete all your personal data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final request = await model.deleteAllData('User requested complete data deletion');
              if (request != null && context.mounted) {
                _showDeleteSuccessDialog(context, request);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _showExportSuccessDialog(BuildContext context, DataExportRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Completed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your data has been exported successfully.'),
            const SizedBox(height: 8),
            Text('Format: ${request.format.name.toUpperCase()}'),
            Text('Categories: ${request.categories.length}'),
            if (request.downloadUrl != null) ...[
              const SizedBox(height: 8),
              Text('File: ${request.downloadUrl}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeleteSuccessDialog(BuildContext context, DataDeletionRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletion Completed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selected data has been deleted successfully.'),
            const SizedBox(height: 8),
            Text('Categories: ${request.categories.length}'),
            Text('Reason: ${request.reason}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showExportHistoryDialog(BuildContext context, PersonalDataViewModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export History'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: model.exportRequests.isEmpty
              ? const Center(
                  child: Text('No export history found'),
                )
              : ListView.builder(
                  itemCount: model.exportRequests.length,
                  itemBuilder: (context, index) {
                    final request = model.exportRequests[index];
                    return ListTile(
                      title: Text('Export ${request.format.name.toUpperCase()}'),
                      subtitle: Text(
                        '${request.categories.length} categories • ${model.formatDateTime(request.requestedAt)}',
                      ),
                      trailing: Icon(
                        request.isCompleted
                            ? Icons.check_circle
                            : request.isFailed
                                ? Icons.error
                                : Icons.pending,
                        color: request.isCompleted
                            ? Colors.green
                            : request.isFailed
                                ? Colors.red
                                : Colors.orange,
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              model.clearExportRequests();
              Navigator.pop(context);
            },
            child: const Text('Clear History'),
          ),
        ],
      ),
    );
  }

  void _showDeletionHistoryDialog(BuildContext context, PersonalDataViewModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletion History'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: model.deletionRequests.isEmpty
              ? const Center(
                  child: Text('No deletion history found'),
                )
              : ListView.builder(
                  itemCount: model.deletionRequests.length,
                  itemBuilder: (context, index) {
                    final request = model.deletionRequests[index];
                    return ListTile(
                      title: Text('${request.categories.length} categories deleted'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reason: ${request.reason}'),
                          Text('Date: ${model.formatDateTime(request.requestedAt)}'),
                        ],
                      ),
                      trailing: Icon(
                        request.isCompleted
                            ? Icons.check_circle
                            : request.isFailed
                                ? Icons.error
                                : Icons.pending,
                        color: request.isCompleted
                            ? Colors.green
                            : request.isFailed
                                ? Colors.red
                                : Colors.orange,
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              model.clearDeletionRequests();
              Navigator.pop(context);
            },
            child: const Text('Clear History'),
          ),
        ],
      ),
    );
  }
} 