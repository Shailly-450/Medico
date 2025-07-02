import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
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
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.local_hospital,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              hospital.name,
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.extended(
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
                  const SizedBox(height: 8),
                  // Debug button for testing URL launching
                  if (kDebugMode)
                    FloatingActionButton.small(
                      onPressed: () => _testUrlLaunching(context),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      child: const Icon(Icons.bug_report),
                    ),
                ],
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

    final googleMapsAppUrl = Uri.parse('google.navigation:q=$lat,$lng');
    final googleMapsWebUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    final osmUrl = Uri.parse('https://www.openstreetmap.org/directions?from=&to=$lat,$lng');

    try {
      // Try to launch Google Maps app (Android only)
      if (Platform.isAndroid && await canLaunchUrl(googleMapsAppUrl)) {
        await launchUrl(googleMapsAppUrl, mode: LaunchMode.externalApplication);
        return;
      }
      // Fallback to Google Maps web directions
      if (await canLaunchUrl(googleMapsWebUrl)) {
        await launchUrl(googleMapsWebUrl, mode: LaunchMode.externalApplication);
        return;
      }
      // Fallback to OpenStreetMap
      if (await canLaunchUrl(osmUrl)) {
        await launchUrl(osmUrl, mode: LaunchMode.externalApplication);
        return;
      }
      // Show error if none work
      if (context.mounted) {
        _showErrorSnackBar(context);
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context);
      }
    }
  }

  void _showErrorSnackBar(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Directions Unavailable'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Could not open directions automatically. Please ensure you have a browser or maps app installed.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Hospital Address:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                hospital.location,
                style: const TextStyle(fontSize: 14),
              ),
              if (hospital.latitude != null && hospital.longitude != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Coordinates: ${hospital.latitude}, ${hospital.longitude}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Try to open a simple web search
                _tryWebSearch(context);
              },
              child: const Text('Search Web'),
            ),
          ],
        );
      },
    );
  }

  void _tryWebSearch(BuildContext context) async {
    final searchQuery = '${hospital.name} ${hospital.location}';
    final searchUrl = 'https://www.google.com/search?q=${Uri.encodeComponent(searchQuery)}';
    
    try {
      final uri = Uri.parse(searchUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // If even web search fails, show a simple message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open any external app. Please search manually.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _testUrlLaunching(BuildContext context) async {
    print('=== URL Launching Debug Test ===');
    print('Platform: ${Platform.operatingSystem}');
    
    // Test simple URLs
    final testUrls = [
      'https://www.google.com',
      'https://maps.google.com',
      'tel:+1234567890',
      'mailto:test@example.com',
    ];
    
    for (String url in testUrls) {
      try {
        final uri = Uri.parse(url);
        final canLaunch = await canLaunchUrl(uri);
        print('Can launch $url: $canLaunch');
        
        if (canLaunch) {
          final result = await launchUrl(uri, mode: LaunchMode.externalApplication);
          print('Launch result for $url: $result');
        }
      } catch (e) {
        print('Error testing $url: $e');
      }
    }
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check console for URL launching debug info'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }
} 