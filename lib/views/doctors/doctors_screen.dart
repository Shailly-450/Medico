import 'package:flutter/material.dart';
import '../../core/views/base_view.dart';
import '../../viewmodels/doctors_view_model.dart';
import '../../core/theme/app_colors.dart';
import '../../models/doctor.dart';
import 'widgets/doctor_card.dart';
import 'doctor_detail_screen.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({Key? key}) : super(key: key);

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<DoctorsViewModel>(
      viewModelBuilder: () => DoctorsViewModel(),
      onModelReady: (model) => model.init(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Doctors'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(context, model),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchAndFilters(context, model),
            Expanded(
              child: _buildDoctorsList(context, model),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, DoctorsViewModel model) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: model.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search doctors, specialties, hospitals...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        model.setSearchQuery('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),

          // Specialty Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: model.availableSpecialties.map((specialty) {
                final isSelected = model.selectedSpecialty == specialty;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(specialty),
                    selected: isSelected,
                    onSelected: (selected) {
                      model.setSpecialty(specialty);
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.grey[700],
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList(BuildContext context, DoctorsViewModel model) {
    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (model.filteredDoctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No doctors found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => model.clearFilters(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: model.filteredDoctors.length,
      itemBuilder: (context, index) {
        final doctor = model.filteredDoctors[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DoctorCard(
            doctor: doctor,
            onTap: () => _navigateToDoctorDetail(context, doctor),
          ),
        );
      },
    );
  }

  void _navigateToDoctorDetail(BuildContext context, Doctor doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorDetailScreen(doctor: doctor),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, DoctorsViewModel model) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Doctors'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption(
                context,
                'All Doctors',
                DoctorFilter.all,
                model.selectedFilter,
                (filter) => model.setFilter(filter),
              ),
              _buildFilterOption(
                context,
                'Online Now',
                DoctorFilter.online,
                model.selectedFilter,
                (filter) => model.setFilter(filter),
              ),
              _buildFilterOption(
                context,
                'Nearby',
                DoctorFilter.nearby,
                model.selectedFilter,
                (filter) => model.setFilter(filter),
              ),
              _buildFilterOption(
                context,
                'Top Rated',
                DoctorFilter.topRated,
                model.selectedFilter,
                (filter) => model.setFilter(filter),
              ),
              _buildFilterOption(
                context,
                'Lowest Price',
                DoctorFilter.lowPrice,
                model.selectedFilter,
                (filter) => model.setFilter(filter),
              ),
              _buildFilterOption(
                context,
                'Highest Price',
                DoctorFilter.highPrice,
                model.selectedFilter,
                (filter) => model.setFilter(filter),
              ),
              _buildFilterOption(
                context,
                'Verified Only',
                DoctorFilter.verified,
                model.selectedFilter,
                (filter) => model.setFilter(filter),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                model.clearFilters();
                Navigator.of(context).pop();
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    String title,
    DoctorFilter filter,
    DoctorFilter selectedFilter,
    Function(DoctorFilter) onTap,
  ) {
    final isSelected = selectedFilter == filter;
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : Colors.grey[700],
        ),
      ),
      leading: Radio<DoctorFilter>(
        value: filter,
        groupValue: selectedFilter,
        onChanged: (value) {
          onTap(value!);
          Navigator.of(context).pop();
        },
        activeColor: AppColors.primary,
      ),
      onTap: () {
        onTap(filter);
        Navigator.of(context).pop();
      },
    );
  }
}
