import 'package:flutter/material.dart';
import '../../../models/hospital.dart';
import '../../../core/theme/app_colors.dart';
import 'package:medico/views/home/hospital_detail_screen.dart';
import 'package:medico/views/home/hospital_map_screen.dart';
import 'package:provider/provider.dart';
// import 'package:medico/views/home/home_view_model.dart';

import '../../../viewmodels/home_view_model.dart';

class HospitalCard extends StatelessWidget {
  final Hospital hospital;
  final VoidCallback? onTap;
  final Function(Hospital)? onMapTap;

  const HospitalCard({
    Key? key,
    required this.hospital,
    this.onTap,
    this.onMapTap,
  }) : super(key: key);

  Color _getCostCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'premium':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _openMap(BuildContext context) {
    if (onMapTap != null) {
      onMapTap!(hospital);
    } else {
      // Use API-fetched hospitals from HomeViewModel
      final hospitals = Provider.of<HomeViewModel>(context, listen: false).hospitals;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HospitalMapScreen(
            selectedHospital: hospital,
            hospitals: hospitals,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HospitalDetailScreen(hospital: hospital),
                ),
              );
            },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hospital Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  hospital.imageUrl != null && hospital.imageUrl!.isNotEmpty
                      ? Image.network(
                          hospital.imageUrl!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 160,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.local_hospital,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 160,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.local_hospital,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: hospital.isOpen ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        hospital.isOpen ? 'OPEN' : 'CLOSED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Hospital Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hospital.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textBlack,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hospital.rating.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBlack,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Address/Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hospital.location,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Distance and Available Doctors
                  Row(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.directions_walk,
                            color: AppColors.textSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${hospital.distance} km',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.people,
                            color: AppColors.textSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${hospital.availableDoctors} doctors',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Specialties
                  if (hospital.specialties.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: hospital.specialties.take(3).map((specialty) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            specialty,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 12),

                  // Cost Information
                  if (hospital.consultationFee != null ||
                      hospital.costCategory != null)
                    Row(
                      children: [
                        if (hospital.consultationFee != null)
                          Row(
                            children: [

                              Text(
                                '₹${hospital.consultationFee!.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Text(
                                ' consultation',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        if (hospital.consultationFee != null &&
                            hospital.costCategory != null)
                          const SizedBox(width: 16),
                        if (hospital.costCategory != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  _getCostCategoryColor(hospital.costCategory!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              hospital.costCategory!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),

                  const SizedBox(height: 12),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HospitalDetailScreen(hospital: hospital),
                              ),
                            );
                          },
                          icon: const Icon(Icons.info_outline, size: 16),
                          label: const Text('Details'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openMap(context),
                          icon: const Icon(Icons.map_outlined, size: 16),
                          label: const Text('Map'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
