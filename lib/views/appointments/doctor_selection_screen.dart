import 'package:flutter/material.dart';
import 'package:medico/core/theme/app_colors.dart';
import 'package:medico/models/doctor.dart';
import 'package:medico/viewmodels/doctors_view_model.dart';
import 'package:medico/core/views/base_view.dart';
import 'package:medico/views/doctors/widgets/doctor_card.dart';

class DoctorSelectionScreen extends StatefulWidget {
  final String? selectedSpecialty;
  final Function(Doctor) onDoctorSelected;

  const DoctorSelectionScreen({
    Key? key,
    this.selectedSpecialty,
    required this.onDoctorSelected,
  }) : super(key: key);

  @override
  State<DoctorSelectionScreen> createState() => _DoctorSelectionScreenState();
}

class _DoctorSelectionScreenState extends State<DoctorSelectionScreen> {
  String _selectedSpecialty = 'All';

  final List<String> _specialties = [
    'All',
    'Cardiologist',
    'Dentist',
    'Dermatologist',
    'General Physician',
    'Pediatrician',
    'Orthopedic Surgeon',
    'Gynecologist',
    'Neurologist',
    'Psychiatrist',
    'Pulmonologist',
    'Urologist',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.selectedSpecialty != null) {
      _selectedSpecialty = widget.selectedSpecialty!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<DoctorsViewModel>(
      viewModelBuilder: () => DoctorsViewModel(),
      onModelReady: (model) => model.init(),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text(
              'Find a Doctor',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Column(
            children: [
              _buildSearchAndFilters(model),
              Expanded(
                child: _buildDoctorsList(model),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchAndFilters(DoctorsViewModel model) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) {
              if (value.isEmpty) {
                model.loadDoctors(refresh: true);
              } else {
                model.searchDoctors(value);
              }
            },
            decoration: InputDecoration(
              hintText: 'Search doctor or symptoms',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterDialog(model),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          const SizedBox(height: 16),
          
          // Specialty Filter Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _specialties.length,
              itemBuilder: (context, index) {
                final specialty = _specialties[index];
                final isSelected = _selectedSpecialty == specialty;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(specialty),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedSpecialty = specialty;
                      });
                      if (specialty == 'All') {
                        model.loadDoctors(refresh: true);
                      } else {
                        model.loadDoctorsBySpecialty(specialty);
                      }
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList(DoctorsViewModel model) {
    if (model.isLoading && model.allDoctors.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (model.errorMessage != null && model.allDoctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load doctors',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => model.loadDoctors(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => model.loadDoctors(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: model.allDoctors.length + (model.hasMoreDoctors ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == model.allDoctors.length) {
            // Loading more indicator
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final doctor = model.allDoctors[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DoctorCard(
              doctor: doctor,
              onTap: () => widget.onDoctorSelected(doctor),
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog(DoctorsViewModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Doctors'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Doctors'),
              onTap: () {
                Navigator.pop(context);
                model.loadDoctors(refresh: true);
              },
            ),
            ListTile(
              title: const Text('Online Only'),
              onTap: () {
                Navigator.pop(context);
                // Filter for online doctors
                model.loadDoctors(refresh: true);
              },
            ),
            ListTile(
              title: const Text('Top Rated'),
              onTap: () {
                Navigator.pop(context);
                model.loadTopRatedDoctors();
              },
            ),
          ],
        ),
      ),
    );
  }
} 