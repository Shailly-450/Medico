import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class HospitalDetailScreen extends StatelessWidget {
  final String name;
  final String address;
  final String imageUrl;
  final String description;
  final List<String> specialties;
  final String phone;

  const HospitalDetailScreen({
    Key? key,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.description,
    required this.specialties,
    required this.phone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textBlack,
        elevation: 0.5,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: 18),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    address,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Specialties',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: specialties
                  .map((s) => Chip(
                label: Text(s),
                backgroundColor: AppColors.secondary.withOpacity(0.2),
                labelStyle: TextStyle(color: AppColors.primary),
              ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.phone, color: AppColors.primary, size: 18),
                const SizedBox(width: 4),
                Text(
                  phone,
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // You can add call functionality here
                },
                icon: const Icon(Icons.phone),
                label: const Text('Call Hospital/Clinic'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}