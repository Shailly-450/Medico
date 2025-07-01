import 'package:flutter/material.dart';

class ComparisonTable extends StatelessWidget {
  final bool sortByCost;
  final String selectedService;
  final Set<String> selectedFilters;
  const ComparisonTable({Key? key, this.sortByCost = false, required this.selectedService, required this.selectedFilters}) : super(key: key);

  double _parseDistance(String location) {
    // Extracts the distance in km from a string like '2.3 km, Downtown'
    final match = RegExp(r'([\d.]+)\s*km').firstMatch(location);
    if (match != null) {
      return double.tryParse(match.group(1) ?? '') ?? 9999;
    }
    return 9999;
  }

  void _showContactDialog(BuildContext context, Map<String, dynamic> hospital) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hospital: ${hospital['name']}'),
            const SizedBox(height: 8),
            Text('Contact: ${hospital['contact']}'),
            const SizedBox(height: 8),
            Text('Website: ${hospital['website']}'),
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
    // Dummy data for each service (at least two hospitals per service)
    final Map<String, List<Map<String, dynamic>>> serviceHospitals = {
      'MRI Scan': [
        {
          'name': 'City General Hospital',
          'accreditation': 'NABH',
          'location': '2.3 km, Downtown',
          'contact': '123-456-7890',
          'website': 'www.citygen.com',
          'cost': '3500',
          'insurance': 'Max, HDFC, ICICI',
          'availability': 'Today, 3:00 PM',
          'doctor': 'Dr. A. Kumar (15 yrs, Radiology)',
          'facilities': 'ICU, MRI, 24x7 ER',
          'rating': '4.7',
          'reviews': '“Quick MRI, good staff”',
          'waiting': '20 min',
          'duration': '1 hour',
          'homeVisit': 'No',
          'teleconsult': 'Yes',
          'success': '98%',
        },
        {
          'name': 'Premium Health Center',
          'accreditation': 'NABH, JCI',
          'location': '3.1 km, Uptown',
          'contact': '555-123-4567',
          'website': 'www.premiumhc.com',
          'cost': '5000',
          'insurance': 'All major',
          'availability': 'Today, 5:00 PM',
          'doctor': 'Dr. R. Singh (20 yrs, Neuro)',
          'facilities': 'Private Rooms, 3T MRI',
          'rating': '4.9',
          'reviews': '“Luxury MRI experience!”',
          'waiting': '5 min',
          'duration': '1.5 hours',
          'homeVisit': 'No',
          'teleconsult': 'Yes',
          'success': '99%',
        },
      ],
      'CT Scan': [
        {
          'name': 'Sunrise Diagnostics',
          'accreditation': 'NABL',
          'location': '1.2 km, Main Road',
          'contact': '111-222-3333',
          'website': 'www.sunrisedx.com',
          'cost': '2500',
          'insurance': 'Star, Bajaj',
          'availability': 'Tomorrow, 10:00 AM',
          'doctor': 'Dr. P. Mehta (12 yrs, Radiology)',
          'facilities': 'CT, X-Ray, Lab',
          'rating': '4.5',
          'reviews': '“Fast CT scan”',
          'waiting': '15 min',
          'duration': '45 min',
          'homeVisit': 'No',
          'teleconsult': 'No',
          'success': '97%',
        },
        {
          'name': 'City General Hospital',
          'accreditation': 'NABH',
          'location': '2.3 km, Downtown',
          'contact': '123-456-7890',
          'website': 'www.citygen.com',
          'cost': '3200',
          'insurance': 'Max, HDFC, ICICI',
          'availability': 'Today, 2:00 PM',
          'doctor': 'Dr. A. Kumar (15 yrs, Radiology)',
          'facilities': 'ICU, CT, 24x7 ER',
          'rating': '4.6',
          'reviews': '“Good CT scan”',
          'waiting': '18 min',
          'duration': '1 hour',
          'homeVisit': 'No',
          'teleconsult': 'Yes',
          'success': '98%',
        },
      ],
      'X-Ray': [
        {
          'name': 'Community Clinic',
          'accreditation': 'JCI',
          'location': '1.8 km, Westside',
          'contact': '987-654-3210',
          'website': 'www.commclinic.com',
          'cost': '600',
          'insurance': 'Star, Bajaj',
          'availability': 'Tomorrow, 11:00 AM',
          'doctor': 'Dr. S. Mehta (10 yrs, Gen Med)',
          'facilities': 'Lab, X-Ray',
          'rating': '4.3',
          'reviews': '“Quick service!”',
          'waiting': '10 min',
          'duration': '20 min',
          'homeVisit': 'Yes',
          'teleconsult': 'No',
          'success': '95%',
        },
        {
          'name': 'Sunrise Diagnostics',
          'accreditation': 'NABL',
          'location': '1.2 km, Main Road',
          'contact': '111-222-3333',
          'website': 'www.sunrisedx.com',
          'cost': '800',
          'insurance': 'Star, Bajaj',
          'availability': 'Today, 9:00 AM',
          'doctor': 'Dr. P. Mehta (12 yrs, Radiology)',
          'facilities': 'CT, X-Ray, Lab',
          'rating': '4.4',
          'reviews': '“Accurate X-Ray”',
          'waiting': '8 min',
          'duration': '15 min',
          'homeVisit': 'No',
          'teleconsult': 'No',
          'success': '96%',
        },
      ],
      'Ultrasound': [
        {
          'name': 'City Ultrasound Center',
          'accreditation': 'NABL',
          'location': '2.0 km, Market Road',
          'contact': '222-333-4444',
          'website': 'www.cityultrasound.com',
          'cost': '1200',
          'insurance': 'Max, HDFC',
          'availability': 'Today, 1:00 PM',
          'doctor': 'Dr. L. Verma (8 yrs, Radiology)',
          'facilities': 'Ultrasound, Lab',
          'rating': '4.2',
          'reviews': '“Quick and accurate”',
          'waiting': '12 min',
          'duration': '30 min',
          'homeVisit': 'No',
          'teleconsult': 'No',
          'success': '97%',
        },
        {
          'name': 'Premium Health Center',
          'accreditation': 'NABH, JCI',
          'location': '3.1 km, Uptown',
          'contact': '555-123-4567',
          'website': 'www.premiumhc.com',
          'cost': '1800',
          'insurance': 'All major',
          'availability': 'Tomorrow, 3:00 PM',
          'doctor': 'Dr. R. Singh (20 yrs, Radiology)',
          'facilities': 'Private Rooms, Ultrasound',
          'rating': '4.8',
          'reviews': '“Very comfortable”',
          'waiting': '7 min',
          'duration': '25 min',
          'homeVisit': 'No',
          'teleconsult': 'Yes',
          'success': '99%',
        },
      ],
      'Root Canal Treatment': [
        {
          'name': 'Smile Dental Clinic',
          'accreditation': 'ISO',
          'location': '0.8 km, Main Street',
          'contact': '333-444-5555',
          'website': 'www.smiledental.com',
          'cost': '4500',
          'insurance': 'None',
          'availability': 'Today, 4:00 PM',
          'doctor': 'Dr. S. Gupta (10 yrs, Endodontics)',
          'facilities': 'Dental X-Ray, Surgery',
          'rating': '4.6',
          'reviews': '“Painless root canal”',
          'waiting': '15 min',
          'duration': '1 hour',
          'homeVisit': 'No',
          'teleconsult': 'No',
          'success': '97%',
        },
        {
          'name': 'City Dental Care',
          'accreditation': 'ISO',
          'location': '1.5 km, Downtown',
          'contact': '444-555-6666',
          'website': 'www.citydental.com',
          'cost': '4000',
          'insurance': 'None',
          'availability': 'Tomorrow, 11:00 AM',
          'doctor': 'Dr. A. Mehra (8 yrs, Endodontics)',
          'facilities': 'Dental X-Ray, Surgery',
          'rating': '4.4',
          'reviews': '“Very gentle”',
          'waiting': '10 min',
          'duration': '50 min',
          'homeVisit': 'No',
          'teleconsult': 'No',
          'success': '96%',
        },
      ],
      'Dental Implants': [
        {
          'name': 'Smile Dental Clinic',
          'accreditation': 'ISO',
          'location': '0.8 km, Main Street',
          'contact': '333-444-5555',
          'website': 'www.smiledental.com',
          'cost': '25000',
          'insurance': 'None',
          'availability': 'Today, 4:00 PM',
          'doctor': 'Dr. S. Gupta (10 yrs, Implantology)',
          'facilities': 'Dental X-Ray, Implants',
          'rating': '4.7',
          'reviews': '“Great results!”',
          'waiting': '20 min',
          'duration': '2 hours',
          'homeVisit': 'No',
          'teleconsult': 'No',
          'success': '98%',
        },
        {
          'name': 'City Dental Care',
          'accreditation': 'ISO',
          'location': '1.5 km, Downtown',
          'contact': '444-555-6666',
          'website': 'www.citydental.com',
          'cost': '23000',
          'insurance': 'None',
          'availability': 'Tomorrow, 11:00 AM',
          'doctor': 'Dr. A. Mehra (8 yrs, Implantology)',
          'facilities': 'Dental X-Ray, Implants',
          'rating': '4.5',
          'reviews': '“Very professional”',
          'waiting': '15 min',
          'duration': '1.5 hours',
          'homeVisit': 'No',
          'teleconsult': 'No',
          'success': '97%',
        },
      ],
      'Braces / Invisalign': [
        {
          'name': 'Ortho Smile Clinic',
          'accreditation': 'ISO',
          'location': '2.0 km, City Center',
          'contact': '555-666-7777',
          'website': 'www.orthosmile.com',
          'cost': '35000',
          'insurance': 'None',
          'availability': 'Today, 2:00 PM',
          'doctor': 'Dr. R. Jain (12 yrs, Orthodontics)',
          'facilities': 'Braces, Invisalign',
          'rating': '4.8',
          'reviews': '“Perfect smile!”',
          'waiting': '10 min',
          'duration': '2 hours',
          'homeVisit': 'No',
          'teleconsult': 'Yes',
          'success': '99%',
        },
        {
          'name': 'City Dental Care',
          'accreditation': 'ISO',
          'location': '1.5 km, Downtown',
          'contact': '444-555-6666',
          'website': 'www.citydental.com',
          'cost': '32000',
          'insurance': 'None',
          'availability': 'Tomorrow, 11:00 AM',
          'doctor': 'Dr. A. Mehra (8 yrs, Orthodontics)',
          'facilities': 'Braces, Invisalign',
          'rating': '4.6',
          'reviews': '“Very happy”',
          'waiting': '12 min',
          'duration': '1.5 hours',
          'homeVisit': 'No',
          'teleconsult': 'No',
          'success': '98%',
        },
      ],
      'Wisdom Tooth Extraction': [
        {
          'name': 'Smile Dental Clinic',
          'accreditation': 'ISO',
          'location': '0.8 km, Main Street',
          'contact': '333-444-5555',
          'website': 'www.smiledental.com',
          'cost': '6000',
          'insurance': 'None',
          'availability': 'Today, 4:00 PM',
          'doctor': 'Dr. S. Gupta (10 yrs, Oral Surgery)',
          'facilities': 'Dental X-Ray, Surgery',
          'rating': '4.5',
          'reviews': '“Painless extraction”',
          'waiting': '18 min',
          'duration': '1 hour',
          'homeVisit': 'No',
          'teleconsult': 'No',
          'success': '97%',
        },
        {
          'name': 'City Dental Care',
          'accreditation': 'ISO',
          'location': '1.5 km, Downtown',
          'contact': '444-555-6666',
          'website': 'www.citydental.com',
          'cost': '5500',
          'insurance': 'None',
          'availability': 'Tomorrow, 11:00 AM',
          'doctor': 'Dr. A. Mehra (8 yrs, Oral Surgery)',
          'facilities': 'Dental X-Ray, Surgery',
          'rating': '4.3',
          'reviews': '“Very gentle”',
          'waiting': '14 min',
          'duration': '50 min',
          'homeVisit': 'No',
          'teleconsult': 'No',
          'success': '96%',
        },
      ],
      'LASIK Surgery': [
        {
          'name': 'Vision Eye Center',
          'accreditation': 'NABH',
          'location': '2.5 km, Eye Street',
          'contact': '777-888-9999',
          'website': 'www.visioneyecenter.com',
          'cost': '40000',
          'insurance': 'Max, HDFC',
          'availability': 'Today, 3:00 PM',
          'doctor': 'Dr. K. Sharma (15 yrs, Ophthalmology)',
          'facilities': 'LASIK, Eye Surgery',
          'rating': '4.9',
          'reviews': '“Clear vision!”',
          'waiting': '10 min',
          'duration': '1 hour',
          'homeVisit': 'No',
          'teleconsult': 'Yes',
          'success': '99%',
        },
        {
          'name': 'City Eye Hospital',
          'accreditation': 'NABH',
          'location': '1.7 km, Downtown',
          'contact': '888-999-0000',
          'website': 'www.cityeyehospital.com',
          'cost': '38000',
          'insurance': 'Max, HDFC',
          'availability': 'Tomorrow, 10:00 AM',
          'doctor': 'Dr. S. Patel (10 yrs, Ophthalmology)',
          'facilities': 'LASIK, Eye Surgery',
          'rating': '4.7',
          'reviews': '“Very professional”',
          'waiting': '12 min',
          'duration': '1 hour',
          'homeVisit': 'No',
          'teleconsult': 'No',
          'success': '98%',
        },
      ],
      // ...repeat for all other services with at least two hospitals each...
    };

    final providers = serviceHospitals[selectedService] ?? [
      {
        'name': 'Sample Hospital',
        'accreditation': 'NABH',
        'location': '2.0 km, City Center',
        'contact': '000-000-0000',
        'website': 'www.sample.com',
        'cost': '1000',
        'insurance': 'All major',
        'availability': 'Today, 12:00 PM',
        'doctor': 'Dr. Sample (10 yrs, Gen Med)',
        'facilities': 'Lab, X-Ray',
        'rating': '4.0',
        'reviews': '“Sample review”',
        'waiting': '10 min',
        'duration': '30 min',
        'homeVisit': 'No',
        'teleconsult': 'No',
        'success': '90%',
      },
    ];

    // Sorting logic based on filters
    final sortedProviders = List<Map<String, dynamic>>.from(providers);
    if (selectedFilters.contains('Nearest')) {
      sortedProviders.sort((a, b) => _parseDistance(a['location']).compareTo(_parseDistance(b['location'])));
    } else if (selectedFilters.contains('Low Cost')) {
      sortedProviders.sort((a, b) => int.parse(a['cost']).compareTo(int.parse(b['cost'])));
    } else if (selectedFilters.contains('Top Rated')) {
      sortedProviders.sort((a, b) => double.parse(b['rating']).compareTo(double.parse(a['rating'])));
    }

    final parameters = [
      {'label': 'Service Cost', 'key': 'cost'},
      {'label': 'Name', 'key': 'name'},
      {'label': 'Accreditation', 'key': 'accreditation'},
      {'label': 'Location', 'key': 'location'},
      {'label': 'Contact', 'key': 'contact'},
      {'label': 'Website', 'key': 'website'},
      {'label': 'Insurance Coverage', 'key': 'insurance'},
      {'label': 'Availability', 'key': 'availability'},
      {'label': 'Doctor Experience', 'key': 'doctor'},
      {'label': 'Facilities', 'key': 'facilities'},
      {'label': 'Customer Ratings', 'key': 'rating'},
      {'label': 'Reviews', 'key': 'reviews'},
      {'label': 'Waiting Time', 'key': 'waiting'},
      {'label': 'Service Duration', 'key': 'duration'},
      {'label': 'Home Visit', 'key': 'homeVisit'},
      {'label': 'Teleconsultation', 'key': 'teleconsult'},
      {'label': 'Success Rate', 'key': 'success'},
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
                                _showContactDialog(context, p);
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
                                '₹${value.toString()}',
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