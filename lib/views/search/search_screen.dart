import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../home/widgets/doctor_card.dart';
import '../../models/doctor.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy data for demonstration
    final List<String> recentSearches = [
      'Cardiologist', 'Dental', 'MRI', 'Pediatrician'
    ];
    final List<String> filters = [
      'All', 'Nearby', 'Top Rated', 'Lowest Price', 'Open Now'
    ];
    final List<Map<String, dynamic>> results = [
      {
        'name': 'Dr. Sarah Johnson',
        'specialty': 'Cardiologist',
        'hospital': 'Mount Sinai Hospital',
        'rating': 4.8,
        'reviews': 128,
        'price': 100.0,
        'isOnline': true,
        'imageUrl': 'https://img.freepik.com/free-photo/woman-doctor-wearing-lab-coat-with-stethoscope-isolated_1303-29791.jpg',
      },
      {
        'name': 'Dr. Michael Chen',
        'specialty': 'Dentist',
        'hospital': 'NYU Langone',
        'rating': 4.7,
        'reviews': 89,
        'price': 90.0,
        'isOnline': false,
        'imageUrl': 'https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.paleBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search doctors, clinics, services...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppColors.textSecondary),
          ),
          style: TextStyle(color: AppColors.textBlack, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Recent searches
          if (recentSearches.isNotEmpty) ...[
            Text('Recent Searches', style: TextStyle(color: AppColors.textBlack, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: recentSearches.map((s) => Chip(
                label: Text(s),
                backgroundColor: AppColors.secondary,
                labelStyle: TextStyle(color: AppColors.primary),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {},
              )).toList(),
            ),
            const SizedBox(height: 16),
          ],
          // Filters
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = index == 0;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    backgroundColor: isSelected ? AppColors.primary : AppColors.secondary,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.primary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    onSelected: (_) {},
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          // Results
          Text('Results', style: TextStyle(color: AppColors.textBlack, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...results.map((doc) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DoctorCard(
              doctor: Doctor.fromJson(doc),
            ),
          )),
          // Placeholder for comparison cards
          const SizedBox(height: 32),
          Center(
            child: Text('Side-by-side comparison coming soon!', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
} 