import 'package:flutter/material.dart';
import '../../../models/medical_service.dart';
import '../../../models/service_provider.dart';

class ComparisonTable extends StatelessWidget {
  final bool sortByCost;
  final String selectedService;
  final Set<String> selectedFilters;
  final List<ServiceProvider> providers;
  final List<MedicalService> allServices;
  final List<ServiceProvider>? directProviders;
  final MedicalService? directService;
  final List<Map<String, dynamic>>? comparisonData;
  final List<Map<String, dynamic>>? servicesData;
  final Map<String, dynamic>? comparisonStats;
  
  const ComparisonTable({
    Key? key,
    this.sortByCost = false,
    required this.selectedService,
    required this.selectedFilters,
    required this.providers,
    required this.allServices,
    this.directProviders,
    this.directService,
    this.comparisonData,
    this.servicesData,
    this.comparisonStats,
  }) : super(key: key);

  double _parseDistance(double? distance) {
    return distance ?? 9999;
  }

  void _showContactDialog(BuildContext context, ServiceProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Provider: ${provider.name}'),
            const SizedBox(height: 8),
            Text('Location: ${provider.location.fullAddress}'),
            const SizedBox(height: 8),
            Text('Type: ${provider.type}'),
            const SizedBox(height: 8),
            Text('Working Hours: ${provider.workingHours}'),
            const SizedBox(height: 8),
            Text('Rating: ${provider.rating}/5 (${provider.reviewCount} reviews)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();
    // If comparisonData is provided (from /comparison/multiple), use it directly
    if (comparisonData?.isNotEmpty ?? false) {
      // Use the new structure for the table
      // Each item in comparisonData is a provider with nested services, etc.
      // You can further customize the table as needed
      // For now, just show a simple table with provider name, rating, and first service name/price
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Comparison Results', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Provider')),
                    DataColumn(label: Text('Rating')),
                    DataColumn(label: Text('Service')),
                    DataColumn(label: Text('Price')),
                  ],
                  rows: comparisonData?.map((provider) {
                    final services = provider['services'] as List?;
                    final firstService = (services != null && services.isNotEmpty) ? services[0] : null;
                    return DataRow(cells: [
                      DataCell(Text(provider['name'] ?? '')),
                      DataCell(Text(provider['rating']?.toString() ?? '')),
                      DataCell(Text(firstService != null ? (firstService['serviceName'] ?? '') : '')),
                      DataCell(Text(firstService != null ? (firstService['price']?.toString() ?? '') : '')),
                    ]);
                  })?.toList() ?? [],
                ),
              ),

              ),

              if (comparisonStats != null) ...[
                const SizedBox(height: 16),
                Text('Price Range: Min: ${comparisonStats!['priceRange']?['min']}, Max: ${comparisonStats!['priceRange']?['max']}, Avg: ${comparisonStats!['priceRange']?['average']}'),
                Text('Rating Range: Min: ${comparisonStats!['ratingRange']?['min']}, Max: ${comparisonStats!['ratingRange']?['max']}, Avg: ${comparisonStats!['ratingRange']?['average']}'),
                Text('Distance Range: Min: ${comparisonStats!['distanceRange']?['min']}, Max: ${comparisonStats!['distanceRange']?['max']}, Avg: ${comparisonStats!['distanceRange']?['average']}'),
              ]

            ],
          ),
        ),
      );
    }

    // Fallback to previous logic
    // If directProviders/directService are provided, use them for the table
    final useDirect = directProviders != null && directService != null;
    final serviceProviders = useDirect ? directProviders! : providers.where((provider) {
      return allServices.any((service) =>
        service.name == selectedService &&
        (service.provider == provider.name || service.provider == provider.id)
      );
    }).toList();

    if (serviceProviders.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No providers found for "$selectedService"',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try selecting a different service or category',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Create comparison data for each provider
    final List<Map<String, dynamic>> fallbackComparisonData = serviceProviders.map((provider) {
      final service = useDirect
          ? directService!
          : allServices.firstWhere(
              (s) => s.name == selectedService && (s.provider == provider.name || s.provider == provider.id),
              orElse: () => MedicalService(
                id: '', name: '', description: '', category: '', price: 0, duration: 0,
              ),
            );

      return {
        'provider': provider,
        'name': provider.name,
        'accreditation': provider.specialties.isNotEmpty ? provider.specialties.first : 'N/A',
        'location': provider.location.shortAddress,
        'distance': provider.location.distance,
        'contact': provider.type,
        'website': provider.name.toLowerCase().replaceAll(' ', '') + '.com',
        'cost': service.price > 0 ? service.price.toString() : (provider.averagePrice > 0 ? provider.averagePrice.toString() : 'N/A'),
        'insurance': service.insuranceCoverage ? 'Covered' : 'Not covered',
        'availability': service.isAvailable ? 'Available' : 'Not available',
        'doctor': 'Dr. ${provider.name.split(' ').last} (${provider.reviewCount} reviews)',
        'facilities': provider.facilities.take(3).join(', '),
        'rating': provider.rating.toString(),
        'reviews': '${provider.reviewCount} reviews',
        'waiting': service.duration > 0 ? '${service.duration} min' : 'N/A',
        'duration': service.duration > 0 ? '${service.duration} min' : 'N/A',
        'homeVisit': service.requiresAppointment ? 'Appointment required' : 'Walk-in',
        'teleconsult': service.requiresPrescription ? 'Prescription required' : 'No prescription',
        'success': provider.rating > 0 ? '${(provider.rating * 20).toInt()}%' : 'N/A',
        'service': service,
      };
    }).toList();

    // Sorting logic based on filters
    final sortedProviders = List<Map<String, dynamic>>.from(fallbackComparisonData);
    if (selectedFilters.contains('Nearest')) {
      sortedProviders.sort((a, b) => _parseDistance(a['distance']).compareTo(_parseDistance(b['distance'])));
    } else if (selectedFilters.contains('Low Cost')) {
      sortedProviders.sort((a, b) => double.tryParse(a['cost'])?.compareTo(double.tryParse(b['cost']) ?? 9999) ?? 9999);
    } else if (selectedFilters.contains('Top Rated')) {
      sortedProviders.sort((a, b) => double.parse(b['rating']).compareTo(double.parse(a['rating'])));
    }

    final parameters = [
      {'label': 'Service Cost', 'key': 'cost'},
      {'label': 'Name', 'key': 'name'},
      {'label': 'Accreditation', 'key': 'accreditation'},
      {'label': 'Location', 'key': 'location'},
      {'label': 'Contact', 'key': 'contact'},
      {'label': 'Doctor Experience', 'key': 'doctor'},
      {'label': 'Facilities', 'key': 'facilities'},
      {'label': 'Customer Ratings', 'key': 'rating'},
    ];

    // Add Book Now row
    final bookNowRow = {
      'label': '',
      'key': '__book_now__',
    };
    final allParameters = [...parameters, bookNowRow];

    // Move Scrollbar outside the Card
    return Scrollbar(
      thumbVisibility: true,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 600),
              child: DataTable(
                columnSpacing: 32,
                headingRowHeight: 48,
                dataRowHeight: 48,
                columns: [
                  const DataColumn(label: Text('Parameter', style: TextStyle(fontWeight: FontWeight.bold))),
                  ...sortedProviders.map((p) => DataColumn(label: Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)))),
                ],
                rows: List.generate(allParameters.length, (rowIdx) {
                  final param = allParameters[rowIdx];
                  final isCost = param['key'] == 'cost';
                  final isBookNow = param['key'] == '__book_now__';
                  final isStriped = rowIdx % 2 == 1;
                  return DataRow(
                    color: isCost
                        ? MaterialStateProperty.all(Colors.yellow.withOpacity(0.2))
                        : isStriped && !isBookNow
                            ? MaterialStateProperty.all(Colors.grey.withOpacity(0.07))
                            : null,
                    cells: [
                      DataCell(
                        isBookNow
                            ? const Text('')
                            : Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                                child: Text(
                                  param['label'] as String,
                                  style: isCost
                                      ? const TextStyle(fontWeight: FontWeight.bold)
                                      : null,
                                ),
                              ),
                      ),
                      ...sortedProviders.map((p) {
                        if (isBookNow) {
                          return DataCell(
                            ElevatedButton.icon(
                              icon: const Icon(Icons.medical_services, size: 18),
                              label: const Text('Book Now'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                _showContactDialog(context, p['provider'] as ServiceProvider);
                              },
                            ),
                          );
                        }
                        final value = p[param['key']];
                        if (param['key'] == 'cost') {
                          return DataCell(
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                              child: Text(
                                value == 'N/A' ? 'N/A' : ' 24${value.toString()}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                              ),
                            ),
                          );
                        }
                        return DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                            child: Text(value.toString()),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 