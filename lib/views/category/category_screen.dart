import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CategoryScreen extends StatefulWidget {
  final String? categoryName;
  
  const CategoryScreen({Key? key, this.categoryName}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final List<String> categories = [
    'All', 'Dentist', 'Dermatologist', 'General Physician', 'Gynecologist', 'Pediatrician', 'Psychiatrist'
  ];
  late String selectedCategory;

  final List<Map<String, dynamic>> doctors = [
    {
      'name': 'Dr. John Doe',
      'specialty': 'Dentist',
      'imageUrl': 'https://randomuser.me/api/portraits/men/11.jpg',
      'rating': 4.8,
      'years': 5,
      'online': true,
      'verified': true,
    },
    {
      'name': 'Dr. Jane Doe',
      'specialty': 'Dermatologist',
      'imageUrl': 'https://randomuser.me/api/portraits/women/12.jpg',
      'rating': 4.9,
      'years': 7,
      'online': true,
      'verified': true,
    },
    {
      'name': 'Dr. Alex Doe',
      'specialty': 'General Physician',
      'imageUrl': 'https://randomuser.me/api/portraits/men/13.jpg',
      'rating': 4.7,
      'years': 10,
      'online': false,
      'verified': true,
    },
    // Add more dummy doctors as needed
  ];

  @override
  void initState() {
    super.initState();
    // Set the initial category based on the passed argument
    if (widget.categoryName != null && categories.contains(widget.categoryName)) {
      selectedCategory = widget.categoryName!;
    } else {
      selectedCategory = 'All';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredDoctors = selectedCategory == 'All'
        ? doctors
        : doctors.where((d) => d['specialty'] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Find a Doctor'),

      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search doctor or symptoms',
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                suffixIcon: Icon(Icons.tune, color: AppColors.secondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: AppColors.secondary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: AppColors.secondary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              ),
            ),
          ),
          // Category chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => setState(() => selectedCategory = cat),
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.grey[100],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.primary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                );
              },
            ),
          ),
          // Doctor count and map view
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${filteredDoctors.length} Doctors View on Map',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          // Doctor list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemCount: filteredDoctors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final doc = filteredDoctors[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  color: Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(doc['imageUrl'], width: 56, height: 56, fit: BoxFit.cover),
                    ),
                    title: Row(
                      children: [
                        Text(
                          doc['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (doc['verified'])
                          const Padding(
                            padding: EdgeInsets.only(left: 4.0),
                            child: Icon(Icons.verified, color: Colors.blue, size: 18),
                          ),
                        const Spacer(),
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        Text(
                          doc['rating'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doc['specialty'], style: TextStyle(color: Colors.grey[700])),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.lock_clock, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text('${doc['years']}+ yrs', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600)),
                            const SizedBox(width: 12),
                            Icon(Icons.videocam, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              doc['online'] ? 'Online Available' : 'Offline',
                              style: TextStyle(
                                color: doc['online'] ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      // You can navigate to doctor or hospital detail here
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}