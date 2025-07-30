import 'package:flutter/material.dart';
import '../../core/views/base_view.dart';
import '../../viewmodels/doctors_view_model.dart';
import '../../core/theme/app_colors.dart';
import '../../models/doctor.dart';

class DoctorApiTestScreen extends StatefulWidget {
  const DoctorApiTestScreen({Key? key}) : super(key: key);

  @override
  State<DoctorApiTestScreen> createState() => _DoctorApiTestScreenState();
}

class _DoctorApiTestScreenState extends State<DoctorApiTestScreen> {
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
        appBar: AppBar(
          title: const Text('Doctor API Test'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => model.loadDoctors(refresh: true),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildTestControls(context, model),
            Expanded(
              child: _buildTestResults(context, model),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestControls(BuildContext context, DoctorsViewModel model) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          // Search
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search doctors...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (query) {
              if (query.isNotEmpty) {
                model.searchDoctors(query);
              } else {
                model.loadDoctors(refresh: true);
              }
            },
          ),
          const SizedBox(height: 16),

          // Test Buttons
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton(
                onPressed: () => model.loadDoctors(refresh: true),
                child: const Text('Load All'),
              ),
              ElevatedButton(
                onPressed: () => model.loadTopRatedDoctors(),
                child: const Text('Top Rated'),
              ),
              ElevatedButton(
                onPressed: () => model.loadDoctorsBySpecialty('Dentist'),
                child: const Text('Dentists'),
              ),
              ElevatedButton(
                onPressed: () => model.loadDoctorsBySpecialty('Dermatologist'),
                child: const Text('Dermatologists'),
              ),
              ElevatedButton(
                onPressed: () => model.loadDoctorsBySpecialty('General Physician'),
                child: const Text('General Physicians'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestResults(BuildContext context, DoctorsViewModel model) {
    if (model.busy && model.allDoctors.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (model.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(fontSize: 18, color: Colors.red[600]),
            ),
            const SizedBox(height: 8),
            Text(
              model.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[500]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => model.loadDoctors(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Statistics
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'API Test Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              _buildStatRow('Total Doctors', '${model.allDoctors.length}'),
              _buildStatRow('Filtered Doctors', '${model.filteredDoctors.length}'),
              _buildStatRow('Online Doctors', '${model.getDoctorsByStatus('online').length}'),
              _buildStatRow('Verified Doctors', '${model.getDoctorsByStatus('verified').length}'),
              if (model.pagination != null) ...[
                _buildStatRow('Current Page', '${model.pagination!['currentPage']}'),
                _buildStatRow('Total Pages', '${model.pagination!['totalPages']}'),
                _buildStatRow('Total Doctors (API)', '${model.pagination!['totalDoctors']}'),
              ],
            ],
          ),
        ),

        // Doctor List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: model.filteredDoctors.length,
            itemBuilder: (context, index) {
              final doctor = model.filteredDoctors[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: doctor.profileImage.isNotEmpty
                        ? NetworkImage(doctor.profileImage)
                        : null,
                    child: doctor.profileImage.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(doctor.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${doctor.specialty} • ${doctor.experience} years exp'),
                      Text('${doctor.ratingFormatted} ⭐ (${doctor.reviewCount} reviews)'),
                      Text('${doctor.consultationFeeFormatted} • ${doctor.languagesString}'),
                      if (doctor.isOnline)
                        Text('🟢 Online', style: TextStyle(color: Colors.green)),
                      if (doctor.isVerified)
                        Text('✅ Verified', style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
} 