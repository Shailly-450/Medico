import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/hospital.dart';
import '../../core/theme/app_colors.dart';

class HospitalMapScreen extends StatefulWidget {
  final Hospital? selectedHospital;
  final List<Hospital> hospitals;

  const HospitalMapScreen({
    Key? key,
    this.selectedHospital,
    required this.hospitals,
  }) : super(key: key);

  @override
  State<HospitalMapScreen> createState() => _HospitalMapScreenState();
}

class _HospitalMapScreenState extends State<HospitalMapScreen> {
  late MapController mapController;
  late LatLng centerLocation;

  @override
  void initState() {
    super.initState();
    mapController = MapController();

    // Set center location based on selected hospital or default to first hospital
    if (widget.selectedHospital != null &&
        widget.selectedHospital!.latitude != null &&
        widget.selectedHospital!.longitude != null) {
      centerLocation = LatLng(
        widget.selectedHospital!.latitude!,
        widget.selectedHospital!.longitude!,
      );
    } else if (widget.hospitals.isNotEmpty &&
        widget.hospitals.first.latitude != null &&
        widget.hospitals.first.longitude != null) {
      centerLocation = LatLng(
        widget.hospitals.first.latitude!,
        widget.hospitals.first.longitude!,
      );
    } else {
      // Default to New York coordinates
      centerLocation = const LatLng(40.7128, -74.0060);
    }
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.selectedHospital != null
              ? '${widget.selectedHospital!.name} - Map'
              : 'Hospital Map',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: centerLocation,
          zoom: widget.selectedHospital != null ? 15.0 : 12.0,
          minZoom: 10.0,
          maxZoom: 18.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.medico',
          ),
          MarkerLayer(
            markers: _buildMarkers(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Reset to center location
          mapController.move(centerLocation, 15.0);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    for (Hospital hospital in widget.hospitals) {
      if (hospital.latitude != null && hospital.longitude != null) {
        final isSelected = widget.selectedHospital?.id == hospital.id;

        markers.add(
          Marker(
            point: LatLng(hospital.latitude!, hospital.longitude!),
            width: isSelected ? 80 : 60,
            height: isSelected ? 80 : 60,
            child: GestureDetector(
              onTap: () => _showHospitalInfo(hospital),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : AppColors.primary,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.local_hospital,
                  color: isSelected ? Colors.white : AppColors.primary,
                  size: isSelected ? 30 : 24,
                ),
              ),
            ),
          ),
        );
      }
    }

    return markers;
  }

  void _showHospitalInfo(Hospital hospital) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Hospital name
              Text(
                hospital.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
              ),
              const SizedBox(height: 8),

              // Hospital type and rating
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hospital.type,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
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
              const SizedBox(height: 12),

              // Location
              Row(
                children: [
                  const Icon(Icons.location_on,
                      color: AppColors.textSecondary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hospital.location,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Distance and doctors
              Row(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.directions_walk,
                          color: AppColors.textSecondary, size: 16),
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
                      const Icon(Icons.people,
                          color: AppColors.textSecondary, size: 16),
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
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/hospital-detail',
                            arguments: hospital);
                      },
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: const Text('Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Center map on this hospital
                        if (hospital.latitude != null &&
                            hospital.longitude != null) {
                          mapController.move(
                            LatLng(hospital.latitude!, hospital.longitude!),
                            16.0,
                          );
                        }
                      },
                      icon: const Icon(Icons.center_focus_strong, size: 16),
                      label: const Text('Center'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
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
}
