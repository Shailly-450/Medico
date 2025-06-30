import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/hospital.dart';

class HospitalDetailScreen extends StatelessWidget {
  final Hospital hospital;

  const HospitalDetailScreen({Key? key, required this.hospital}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hospital.name),

      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: hospital.imageUrl != null
                    ? Image.network(
                        hospital.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.local_hospital,
                            size: 80,
                            color: AppColors.primary,
                          );
                        },
                      )
                    : Icon(
                        Icons.local_hospital,
                        size: 80,
                        color: AppColors.primary,
                      ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Hospital Name and Rating
            Row(
              children: [
                Expanded(
                  child: Text(
                    hospital.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hospital.rating.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Hospital Type
            Text(
              hospital.type,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Status and Distance
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: hospital.isOpen ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    hospital.isOpen ? 'Open Now' : 'Closed',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${hospital.distance} km away',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: 18),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    hospital.location,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Available Doctors
            Row(
              children: [
                Icon(Icons.people, color: AppColors.primary, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${hospital.availableDoctors} doctors available',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (hospital.description != null) ...[
              Text(
                hospital.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ],
            
            if (hospital.specialties.isNotEmpty) ...[
              Text(
                'Specialties',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: hospital.specialties
                    .map((s) => Chip(
                  label: Text(s),
                  backgroundColor: AppColors.secondary.withOpacity(0.2),
                  labelStyle: TextStyle(color: AppColors.primary),
                ))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
            
            if (hospital.contactInfo != null && hospital.contactInfo!['phone'] != null) ...[
              Row(
                children: [
                  Icon(Icons.phone, color: AppColors.primary, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    hospital.contactInfo!['phone'],
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            
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