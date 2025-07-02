import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/hospital.dart';

/// A widget that displays a hospital location on an interactive map using OpenStreetMap.
/// 
/// Features:
/// - Interactive map with OpenStreetMap tiles
/// - Custom hospital marker with hospital name
/// - Location info overlay
/// - "Get Directions" button that opens directions in external browser
/// 
/// Usage:
/// ```dart
/// HospitalMapWidget(
///   hospital: hospital,
///   height: 250,
/// )
/// ```

class HospitalMapWidget extends StatelessWidget {
  final Hospital hospital;
  final double height;

  const HospitalMapWidget({
    Key? key,
    required this.hospital,
    this.height = 300,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Default coordinates for New York if hospital coordinates are not available
    final lat = hospital.latitude ?? 40.7128;
    final lng = hospital.longitude ?? -74.0060;
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Map
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(lat, lng),
                initialZoom: 15.0,
                minZoom: 10.0,
                maxZoom: 18.0,
              ),
              children: [
                // OpenStreetMap tiles
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.medico',
                  maxZoom: 18,
                ),
                // Hospital marker
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(lat, lng),
                      width: 80,
                      height: 80,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.local_hospital,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              hospital.name,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Get Directions Button
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.extended(
                onPressed: () => _openDirections(context),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.directions),
                label: const Text(
                  'Get Directions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Hospital Info Overlay
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 200,
                      child: Text(
                        hospital.location,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDirections(BuildContext context) async {
    final lat = hospital.latitude ?? 40.7128;
    final lng = hospital.longitude ?? -74.0060;
    
    // Try multiple URL formats for better compatibility
    final List<String> urls = [
      // OpenStreetMap directions
      'https://www.openstreetmap.org/directions?from=&to=$lat,$lng',
      // Google Maps directions
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
      // Simple Google Maps search
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      // Fallback to just coordinates
      'geo:$lat,$lng?q=$lat,$lng(${hospital.name})',
    ];
    
    bool launched = false;
    
    for (String url in urls) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          final result = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (result) {
            launched = true;
            break;
          }
        }
      } catch (e) {
        // Continue to next URL if this one fails
        continue;
      }
    }
    
    if (!launched && context.mounted) {
      _showErrorSnackBar(context);
    }
  }

  void _showErrorSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not open directions. Please try again.'),
        backgroundColor: Colors.red,
      ),
    );
  }
} 