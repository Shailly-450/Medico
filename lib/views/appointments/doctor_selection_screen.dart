import 'package:flutter/material.dart';
import '../../models/doctor.dart';
import '../../core/theme/app_colors.dart';

class DoctorSelectionScreen extends StatefulWidget {
  const DoctorSelectionScreen({Key? key}) : super(key: key);

  @override
  State<DoctorSelectionScreen> createState() => _DoctorSelectionScreenState();
}

class _DoctorSelectionScreenState extends State<DoctorSelectionScreen> {
  String _selectedSpecialty = 'All';
  String _searchQuery = '';
  
  final List<String> _specialties = [
    'All',
    'Cardiologist',
    'Dentist',
    'Dermatologist',
    'Endocrinologist',
    'Gastroenterologist',
    'General Physician',
    'Gynecologist',
    'Neurologist',
    'Oncologist',
    'Ophthalmologist',
    'Orthopedic',
    'Pediatrician',
    'Psychiatrist',
    'Pulmonologist',
    'Urologist',
  ];

  // Sample doctors data - in real app, this would come from API
  final List<Doctor> _doctors = [
    Doctor(
      id: 'doc_001',
      name: 'Dr. Sarah Johnson',
      specialty: 'Cardiologist',
      hospital: 'City Heart Hospital',
      imageUrl: 'https://img.freepik.com/free-photo/woman-doctor-wearing-lab-coat-with-stethoscope-isolated_1303-29791.jpg',
      rating: 4.8,
      reviews: 120,
      isAvailable: true,
      price: 500.0,
      isOnline: true,
      experience: 15,
      education: 'MBBS, MD - Cardiology',
      languages: ['English', 'Spanish'],
      specializations: ['Interventional Cardiology', 'Heart Failure'],
      about: 'Experienced cardiologist with expertise in interventional procedures.',
      availability: {'Monday': '9:00 AM - 5:00 PM', 'Tuesday': '9:00 AM - 5:00 PM'},
      awards: ['Best Cardiologist 2023', 'Excellence in Patient Care'],
      consultationFee: '₹500',
      acceptsInsurance: true,
      insuranceProviders: ['Blue Cross', 'Aetna'],
      location: 'Mumbai, Maharashtra',
      distance: 2.5,
      isVerified: true,
      phoneNumber: '+91 98765 43210',
      email: 'sarah.johnson@cityheart.com',
      symptoms: ['Chest Pain', 'Shortness of Breath', 'Irregular Heartbeat'],
      videoCall: true,
    ),
    Doctor(
      id: 'doc_002',
      name: 'Dr. Michael Chen',
      specialty: 'Dentist',
      hospital: 'Smile Dental Clinic',
      imageUrl: 'https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg',
      rating: 4.6,
      reviews: 98,
      isAvailable: true,
      price: 350.0,
      isOnline: false,
      experience: 12,
      education: 'BDS, MDS - Orthodontics',
      languages: ['English', 'Mandarin'],
      specializations: ['Orthodontics', 'Cosmetic Dentistry'],
      about: 'Specialized in orthodontics and cosmetic dental procedures.',
      availability: {'Monday': '10:00 AM - 6:00 PM', 'Wednesday': '10:00 AM - 6:00 PM'},
      awards: ['Dental Excellence Award 2022'],
      consultationFee: '₹350',
      acceptsInsurance: true,
      insuranceProviders: ['Delta Dental', 'Cigna'],
      location: 'Delhi, NCR',
      distance: 1.8,
      isVerified: true,
      phoneNumber: '+91 98765 43211',
      email: 'michael.chen@smiledental.com',
      symptoms: ['Tooth Pain', 'Gum Disease', 'Cavities'],
      videoCall: false,
    ),
    Doctor(
      id: 'doc_003',
      name: 'Dr. Priya Sharma',
      specialty: 'Dermatologist',
      hospital: 'Skin Care Specialists',
      imageUrl: 'https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg',
      rating: 4.9,
      reviews: 150,
      isAvailable: true,
      price: 450.0,
      isOnline: true,
      experience: 18,
      education: 'MBBS, MD - Dermatology',
      languages: ['English', 'Hindi', 'Marathi'],
      specializations: ['Cosmetic Dermatology', 'Skin Cancer'],
      about: 'Expert in treating various skin conditions and cosmetic procedures.',
      availability: {'Tuesday': '9:00 AM - 5:00 PM', 'Thursday': '9:00 AM - 5:00 PM'},
      awards: ['Dermatologist of the Year 2023'],
      consultationFee: '₹450',
      acceptsInsurance: true,
      insuranceProviders: ['Aetna', 'UnitedHealth'],
      location: 'Bangalore, Karnataka',
      distance: 3.2,
      isVerified: true,
      phoneNumber: '+91 98765 43212',
      email: 'priya.sharma@skincare.com',
      symptoms: ['Skin Rash', 'Acne', 'Eczema'],
      videoCall: true,
    ),
    Doctor(
      id: 'doc_004',
      name: 'Dr. Rajesh Kumar',
      specialty: 'General Physician',
      hospital: 'Family Health Center',
      imageUrl: 'https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg',
      rating: 4.7,
      reviews: 200,
      isAvailable: true,
      price: 300.0,
      isOnline: true,
      experience: 20,
      education: 'MBBS, MD - General Medicine',
      languages: ['English', 'Hindi', 'Tamil'],
      specializations: ['Primary Care', 'Preventive Medicine'],
      about: 'Experienced general physician providing comprehensive primary care.',
      availability: {'Monday': '8:00 AM - 6:00 PM', 'Wednesday': '8:00 AM - 6:00 PM'},
      awards: ['Best General Physician 2022'],
      consultationFee: '₹300',
      acceptsInsurance: true,
      insuranceProviders: ['Blue Cross', 'Aetna', 'Cigna'],
      location: 'Chennai, Tamil Nadu',
      distance: 1.5,
      isVerified: true,
      phoneNumber: '+91 98765 43213',
      email: 'rajesh.kumar@familyhealth.com',
      symptoms: ['Fever', 'Cough', 'Headache', 'Fatigue'],
      videoCall: true,
    ),
    Doctor(
      id: 'doc_005',
      name: 'Dr. Emily Brown',
      specialty: 'Pediatrician',
      hospital: 'Children\'s Medical Center',
      imageUrl: 'https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg',
      rating: 4.8,
      reviews: 180,
      isAvailable: true,
      price: 400.0,
      isOnline: true,
      experience: 16,
      education: 'MBBS, MD - Pediatrics',
      languages: ['English', 'Spanish'],
      specializations: ['Child Development', 'Vaccination'],
      about: 'Dedicated pediatrician with expertise in child health and development.',
      availability: {'Monday': '9:00 AM - 5:00 PM', 'Friday': '9:00 AM - 5:00 PM'},
      awards: ['Pediatric Excellence Award 2023'],
      consultationFee: '₹400',
      acceptsInsurance: true,
      insuranceProviders: ['Blue Cross', 'Aetna'],
      location: 'Hyderabad, Telangana',
      distance: 2.1,
      isVerified: true,
      phoneNumber: '+91 98765 43214',
      email: 'emily.brown@childrensmed.com',
      symptoms: ['Child Fever', 'Vaccination', 'Growth Issues'],
      videoCall: true,
    ),
  ];

  List<Doctor> get _filteredDoctors {
    return _doctors.where((doctor) {
      final matchesSpecialty = _selectedSpecialty == 'All' || doctor.specialty == _selectedSpecialty;
      final matchesSearch = doctor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           doctor.specialty.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           doctor.hospital.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSpecialty && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select Doctor'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search doctors, specialties, or hospitals...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Specialty Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _specialties.length,
                    itemBuilder: (context, index) {
                      final specialty = _specialties[index];
                      final isSelected = _selectedSpecialty == specialty;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSpecialty = specialty;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            specialty,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Doctors List
          Expanded(
            child: _filteredDoctors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No doctors found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = _filteredDoctors[index];
                      return _buildDoctorCard(doctor);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/create-appointment',
            arguments: doctor,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Doctor Image
              CircleAvatar(
                radius: 35,
                backgroundImage: NetworkImage(doctor.imageUrl),
                onBackgroundImageError: (exception, stackTrace) {
                  // Handle image loading error
                },
                child: doctor.imageUrl.isEmpty
                    ? const Icon(Icons.person, size: 35)
                    : null,
              ),
              const SizedBox(width: 16),
              
              // Doctor Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            doctor.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (doctor.isVerified)
                          Icon(
                            Icons.verified,
                            color: AppColors.primary,
                            size: 16,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialty,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.hospital,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Rating and Reviews
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${doctor.rating}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${doctor.reviews} reviews)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Availability and Price
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: doctor.isAvailable
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                doctor.isAvailable ? Icons.check_circle : Icons.cancel,
                                size: 12,
                                color: doctor.isAvailable ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                doctor.isAvailable ? 'Available' : 'Unavailable',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: doctor.isAvailable ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${doctor.price.toInt()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Action Button
              Column(
                children: [
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
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