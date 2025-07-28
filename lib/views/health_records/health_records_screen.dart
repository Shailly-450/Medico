import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/health_record.dart';
import '../../viewmodels/health_records_view_model.dart';
import '../../core/services/health_record_service.dart';

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({Key? key}) : super(key: key);

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeViewModel();
  }

  Future<void> _initializeViewModel() async {
    developer.log('🔍 HealthRecordsScreen: _initializeViewModel called',
        name: 'HealthRecordsScreen');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    developer.log(
        '🔍 HealthRecordsScreen: Token from SharedPreferences: ${token != null ? '${token.substring(0, 10)}...' : 'null'}',
        name: 'HealthRecordsScreen');

    if (token == null) {
      developer.log(
          '❌ HealthRecordsScreen: No token found, showing authentication error',
          name: 'HealthRecordsScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication required')));
      }
      return;
    }

    if (mounted) {
      developer.log(
          '🔍 HealthRecordsScreen: Initializing HealthRecordService with token',
          name: 'HealthRecordsScreen');
      final viewModel = context.read<HealthRecordsViewModel>();
      viewModel.init(HealthRecordService(token));
      developer.log('🔍 HealthRecordsScreen: Calling loadHealthRecords',
          name: 'HealthRecordsScreen');
      viewModel.loadHealthRecords();
    } else {
      developer.log(
          '❌ HealthRecordsScreen: Widget not mounted, cannot initialize',
          name: 'HealthRecordsScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              final viewModel = context.read<HealthRecordsViewModel>();
              viewModel.debugPrintState();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Debug info printed to console')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddRecordDialog(context),
          ),
        ],
      ),
      body: Consumer<HealthRecordsViewModel>(
        builder: (context, viewModel, child) {
          developer.log(
              '🔍 HealthRecordsScreen: Consumer rebuild - isLoading: ${viewModel.isLoading}, error: ${viewModel.error}, records: ${viewModel.filteredRecords.length}',
              name: 'HealthRecordsScreen');

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search records...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        viewModel.setSearchQuery('');
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: viewModel.setSearchQuery,
                ),
              ),
              _buildFilterRow(viewModel),
              if (viewModel.isLoading)
                const Expanded(
                    child: Center(child: CircularProgressIndicator()))
              else if (viewModel.error != null)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        viewModel.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                )
              else if (viewModel.filteredRecords.isEmpty)
                const Expanded(
                  child: Center(child: Text('No records found')),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = viewModel.filteredRecords[index];
                      return _buildHealthRecordCard(
                        context,
                        record,
                        () => _showRecordDetails(context, record),
                        () => viewModel.deleteRecord(record.id),
                        (isImportant) =>
                            viewModel.markAsImportant(record.id, isImportant),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterRow(HealthRecordsViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: viewModel.selectedCategory,
              isExpanded: true,
              items: viewModel.categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) => viewModel.setCategory(value!),
            ),
          ),
          IconButton(
            icon: Icon(
              viewModel.showImportantOnly ? Icons.star : Icons.star_border,
              color: viewModel.showImportantOnly ? Colors.amber : null,
            ),
            onPressed: viewModel.toggleImportantOnly,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRecordCard(
    BuildContext context,
    HealthRecord record,
    VoidCallback onTap,
    VoidCallback onDelete,
    Function(bool) onToggleImportant,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    context
                        .read<HealthRecordsViewModel>()
                        .getCategoryIcon(record.category),
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      record.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      record.isImportant ? Icons.star : Icons.star_border,
                      color: record.isImportant ? Colors.amber : null,
                    ),
                    onPressed: () => onToggleImportant(!record.isImportant),
                  ),
                ],
              ),
              if (record.description != null) ...[
                const SizedBox(height: 4.0),
                Text(
                  record.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    record.category,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.0,
                    ),
                  ),
                  TextButton(
                    onPressed: onDelete,
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
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

  void _showRecordDetails(BuildContext context, HealthRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(record.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Date: ${context.read<HealthRecordsViewModel>().formatDate(record.date)}'),
              if (record.description != null) ...[
                const SizedBox(height: 8.0),
                Text(record.description!),
              ],
              if (record.provider != null) ...[
                const SizedBox(height: 8.0),
                Text('Provider: ${record.provider}'),
              ],
              if (record.status != null) ...[
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    const Text('Status: '),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: context
                            .read<HealthRecordsViewModel>()
                            .getStatusColor(record.status!)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        record.status!,
                        style: TextStyle(
                          color: context
                              .read<HealthRecordsViewModel>()
                              .getStatusColor(record.status!),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddRecordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Health Record'),
        content: const AddRecordForm(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Handle form submission
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class AddRecordForm extends StatelessWidget {
  const AddRecordForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text('Implement record form here');
  }
}
