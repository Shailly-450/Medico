import 'package:flutter/material.dart';
import '../../core/views/base_view.dart';
import '../../viewmodels/prescriptions_view_model.dart';
import '../../core/theme/app_colors.dart';
import '../../models/prescription.dart';
import 'widgets/prescription_card.dart';
import 'widgets/prescription_detail_screen.dart';

class PrescriptionsScreen extends StatelessWidget {
  const PrescriptionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<PrescriptionsViewModel>(
      viewModelBuilder: () => PrescriptionsViewModel(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'E-Prescriptions',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: model.refreshPrescriptions,
              tooltip: 'Refresh',
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(context, model),
              tooltip: 'Filter',
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(model),
            _buildFilterChips(model),
            Expanded(child: _buildPrescriptionsList(model)),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Navigate to add new prescription screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Add new prescription feature coming soon!'),
                backgroundColor: Colors.blue,
              ),
            );
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
          tooltip: 'Add Prescription',
        ),
      ),
    );
  }

  Widget _buildSearchBar(PrescriptionsViewModel model) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: TextField(
        onChanged: model.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search prescriptions...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: model.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () => model.setSearchQuery(''),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips(PrescriptionsViewModel model) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: model.filterOptions.length,
        itemBuilder: (context, index) {
          final filter = model.filterOptions[index];
          final isSelected = model.selectedFilter == filter;
          final count = model.getPrescriptionCount(filter);

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(
                '$filter${count > 0 ? ' ($count)' : ''}',
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                model.setFilter(filter);
              },
              selectedColor: AppColors.primary,
              backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.grey[300]!,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrescriptionsList(PrescriptionsViewModel model) {
    // Debug information
    print('DEBUG: isLoading = ${model.isLoading}');
    print('DEBUG: prescriptions count = ${model.prescriptions.length}');
    print('DEBUG: selectedFilter = ${model.selectedFilter}');
    print('DEBUG: searchQuery = ${model.searchQuery}');

    if (model.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading prescriptions...'),
          ],
        ),
      );
    }

    if (model.prescriptions.isEmpty) {
      return _buildEmptyState(model);
    }

    return RefreshIndicator(
      onRefresh: () async {
        model.refreshPrescriptions();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: model.prescriptions.length,
        itemBuilder: (context, index) {
          final prescription = model.prescriptions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PrescriptionCard(
              prescription: prescription,
              onTap: () => _navigateToDetail(context, prescription),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(PrescriptionsViewModel model) {
    String message;
    IconData icon;

    if (model.searchQuery.isNotEmpty) {
      message = 'No prescriptions found for "${model.searchQuery}"';
      icon = Icons.search_off;
    } else if (model.selectedFilter != 'All') {
      message = 'No ${model.selectedFilter.toLowerCase()} prescriptions';
      icon = Icons.filter_list_off;
    } else {
      message = 'No prescriptions found';
      icon = Icons.medication_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            model.searchQuery.isNotEmpty || model.selectedFilter != 'All'
                ? 'Try adjusting your search or filter'
                : 'Your prescriptions will appear here',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (model.searchQuery.isNotEmpty ||
              model.selectedFilter != 'All') ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                model.setSearchQuery('');
                model.setFilter('All');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, PrescriptionsViewModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Prescriptions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: model.filterOptions.map((filter) {
            final isSelected = model.selectedFilter == filter;
            final count = model.getPrescriptionCount(filter);

            return ListTile(
              leading: Radio<String>(
                value: filter,
                groupValue: model.selectedFilter,
                onChanged: (value) {
                  model.setFilter(value!);
                  Navigator.pop(context);
                },
              ),
              title: Text(filter),
              subtitle: Text('$count prescriptions'),
              trailing: isSelected
                  ? Icon(Icons.check, color: AppColors.primary)
                  : null,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Prescription prescription) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PrescriptionDetailScreen(prescription: prescription),
      ),
    );
  }
}
