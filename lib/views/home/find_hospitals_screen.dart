import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../models/hospital.dart';
import '../../viewmodels/home_view_model.dart';
import 'hospital_detail_screen.dart';
import 'widgets/hospital_card.dart';

class FindHospitalsScreen extends StatefulWidget {
  const FindHospitalsScreen({Key? key}) : super(key: key);

  @override
  State<FindHospitalsScreen> createState() => _FindHospitalsScreenState();
}

class _FindHospitalsScreenState extends State<FindHospitalsScreen> {
  String _searchQuery = '';
  late List<Hospital> _filteredHospitals;
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // Optionally trigger refreshHospitals here if needed
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<HomeViewModel>(context, listen: false).refreshHospitals();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, homeVM, child) {
        if (homeVM.isBusy) {
          return Scaffold(
            appBar: AppBar(title: const Text('Find Hospitals')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (homeVM.hospitalsError != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Find Hospitals')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(homeVM.hospitalsError!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: homeVM.refreshHospitals,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        final hospitals = homeVM.hospitals;
        print('DEBUG: _searchQuery = "$_searchQuery"');
        print('DEBUG: homeVM.hospitals.length = ${homeVM.hospitals.length}');
        _filteredHospitals = _searchQuery.trim().isEmpty
            ? hospitals
            : hospitals.where((h) {
      final q = _searchQuery.toLowerCase();
                final address = h.contactInfo ?? {};
                // If you have h.address, use that instead of h.contactInfo
      return h.name.toLowerCase().contains(q) ||
          h.location.toLowerCase().contains(q) ||
                    h.specialties.any((s) => s.toLowerCase().contains(q)) ||
                    (address['country']?.toLowerCase().contains(q) ?? false) ||
                    (address['city']?.toLowerCase().contains(q) ?? false) ||
                    (address['state']?.toLowerCase().contains(q) ?? false) ||
                    (address['zipCode']?.toLowerCase().contains(q) ?? false);
    }).toList();
        print('DEBUG: _filteredHospitals.length = ${_filteredHospitals.length}');

    // Center map on first hospital or default to New York
    final double defaultLat = _filteredHospitals.isNotEmpty
        ? _filteredHospitals[0].latitude ?? 40.7128
        : 40.7128;
    final double defaultLng = _filteredHospitals.isNotEmpty
        ? _filteredHospitals[0].longitude ?? -74.0060
        : -74.0060;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Hospitals'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, specialty, or location',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Map
          SizedBox(
            height: 250,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(defaultLat, defaultLng),
                initialZoom: 12.0,
                minZoom: 10.0,
                maxZoom: 18.0,
                onTap: (_, __) {},
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.medico',
                  maxZoom: 18,
                ),
                MarkerLayer(
                  markers: _filteredHospitals.map((hospital) {
                    final lat = hospital.latitude ?? 40.7128;
                    final lng = hospital.longitude ?? -74.0060;
                    return Marker(
                      point: LatLng(lat, lng),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HospitalDetailScreen(hospital: hospital),
                            ),
                          );
                        },
                        child: Tooltip(
                          message: hospital.name,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.local_hospital, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: _filteredHospitals.isEmpty
                ? const Center(child: Text('No hospitals found.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredHospitals.length,
                    itemBuilder: (context, index) {
                      final hospital = _filteredHospitals[index];
                      return HospitalCard(
                        hospital: hospital,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HospitalDetailScreen(hospital: hospital),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
        );
      },
    );
  }
} 