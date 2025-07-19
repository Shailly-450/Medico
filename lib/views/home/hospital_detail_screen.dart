import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/hospital.dart';
import '../../models/review.dart';
import '../../models/medical_service.dart';
import 'widgets/star_rating_widget.dart';
import 'widgets/hospital_charts_widget.dart';
import 'widgets/review_card_widget.dart';
import 'widgets/hospital_map_widget.dart';

class HospitalDetailScreen extends StatefulWidget {
  final Hospital hospital;

  const HospitalDetailScreen({Key? key, required this.hospital})
      : super(key: key);

  @override
  State<HospitalDetailScreen> createState() => _HospitalDetailScreenState();
}

class _HospitalDetailScreenState extends State<HospitalDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late HospitalStats _hospitalStats;
  late List<Review> _reviews;
  late List<MedicalService> _medicalServices;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeDummyData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeDummyData() {
    // Initialize dummy hospital stats
    _hospitalStats = HospitalStats(
      ratingDistribution: {
        '5': 45,
        '4': 25,
        '3': 15,
        '2': 8,
        '1': 7,
      },
      averageRating: widget.hospital.rating,
      totalReviews: 100,
      serviceRatings: {
        'Medical Care': 4.5,
        'Staff Behavior': 4.2,
        'Cleanliness': 4.7,
        'Wait Time': 3.8,
        'Facilities': 4.3,
      },
      topFeatures: [
        'Emergency Care',
        'Online Booking',
        'Insurance Accepted',
        'Parking Available',
      ],
    );

    // Initialize dummy reviews
    _reviews = [
      Review(
        id: '1',
        userId: 'user1',
        userName: 'Dr. Sarah Johnson',
        userAvatarUrl:
            'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=150',
        rating: 5.0,
        comment:
            'Excellent hospital with state-of-the-art facilities. The medical staff is highly professional and caring. I had my surgery here and the recovery was smooth.',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        isVerified: true,
      ),
      Review(
        id: '2',
        userId: 'user2',
        userName: 'Michael Chen',
        userAvatarUrl:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
        rating: 4.0,
        comment:
            'Good hospital overall. Wait times can be a bit long but the medical care is top-notch. Clean facilities and helpful staff.',
        timestamp: DateTime.now().subtract(const Duration(days: 12)),
        isVerified: false,
      ),
      Review(
        id: '3',
        userId: 'user3',
        userName: 'Emma Rodriguez',
        userAvatarUrl:
            'https://images.unsplash.com/photo-1494790108755-2616b812b833?w=150',
        rating: 5.0,
        comment:
            'Outstanding experience! The doctors were thorough and explained everything clearly. Highly recommend this hospital for any medical needs.',
        timestamp: DateTime.now().subtract(const Duration(days: 18)),
        isVerified: true,
      ),
      Review(
        id: '4',
        userId: 'user4',
        userName: 'David Park',
        userAvatarUrl: '',
        rating: 3.0,
        comment:
            'Average experience. The facility is clean but the staff could be more attentive. Treatment was effective though.',
        timestamp: DateTime.now().subtract(const Duration(days: 25)),
        isVerified: false,
      ),
    ];

    // Initialize dummy medical services with pricing
    _medicalServices = [
      // Emergency Services
      MedicalService(
        id: 'emergency_1',
        name: 'Emergency Room Visit',
        description: '24/7 emergency care with immediate medical attention',
        category: 'Emergency Services',
        price: 150.0,
        currency: 'INR',
        duration: 60,
        includedTests: [
          'Vital Signs',
          'Initial Assessment',
          'Emergency Treatment'
        ],
        requirements: ['Emergency situation', 'Valid ID'],
        rating: 4.8,
        reviewCount: 234,
      ),
      MedicalService(
        id: 'ambulance_1',
        name: 'Ambulance Service',
        description: 'Emergency ambulance with paramedic support',
        category: 'Emergency Services',
        price: 200.0,
        currency: 'INR',
        duration: 30,
        includedTests: ['Emergency Transport', 'Basic Life Support'],
        requirements: ['Emergency situation', 'Valid insurance'],
        rating: 4.6,
        reviewCount: 156,
      ),
      MedicalService(
        id: 'trauma_1',
        name: 'Trauma Care',
        description: 'Specialized trauma treatment and surgery',
        category: 'Emergency Services',
        price: 500.0,
        currency: 'INR',
        duration: 120,
        includedTests: ['Trauma Assessment', 'Emergency Surgery if needed'],
        requirements: ['Trauma case', 'Emergency referral'],
        rating: 4.9,
        reviewCount: 89,
      ),

      // Diagnostic Services
      MedicalService(
        id: 'xray_1',
        name: 'X-Ray Imaging',
        description: 'Digital X-ray imaging for bone and chest examination',
        category: 'Diagnostic Services',
        price: 80.0,
        currency: 'INR',
        duration: 30,
        includedTests: ['X-Ray Images', 'Radiologist Report', 'Digital Copy'],
        requirements: ['Doctor referral', 'No metal objects'],
        rating: 4.5,
        reviewCount: 445,
      ),
      MedicalService(
        id: 'mri_1',
        name: 'MRI Scan',
        description: 'Magnetic Resonance Imaging for detailed body examination',
        category: 'Diagnostic Services',
        price: 350.0,
        currency: 'INR',
        duration: 45,
        includedTests: ['MRI Images', 'Specialist Report', '3D Reconstruction'],
        requirements: [
          'Doctor referral',
          'No metal objects',
          'Fasting if required'
        ],
        rating: 4.7,
        reviewCount: 223,
      ),
      MedicalService(
        id: 'ct_1',
        name: 'CT Scan',
        description:
            'Computed Tomography scan for detailed cross-sectional imaging',
        category: 'Diagnostic Services',
        price: 280.0,
        currency: 'INR',
        duration: 40,
        includedTests: ['CT Images', 'Radiologist Report', 'Digital Copy'],
        requirements: ['Doctor referral', 'Contrast dye if needed'],
        rating: 4.6,
        reviewCount: 178,
      ),
      MedicalService(
        id: 'blood_1',
        name: 'Complete Blood Count (CBC)',
        description: 'Comprehensive blood analysis including all cell counts',
        category: 'Diagnostic Services',
        price: 45.0,
        currency: 'INR',
        duration: 20,
        includedTests: [
          'RBC Count',
          'WBC Count',
          'Hemoglobin',
          'Platelet Count'
        ],
        requirements: ['Fasting for 8-12 hours', 'No medications 24h before'],
        rating: 4.4,
        reviewCount: 567,
      ),
      MedicalService(
        id: 'ecg_1',
        name: 'ECG/EKG Test',
        description: 'Electrocardiogram to check heart rhythm and function',
        category: 'Diagnostic Services',
        price: 65.0,
        currency: 'INR',
        duration: 25,
        includedTests: ['ECG Recording', 'Cardiologist Report', 'Digital Copy'],
        requirements: ['Clean chest area', 'No lotions or oils'],
        rating: 4.5,
        reviewCount: 334,
      ),

      // Specialty Care
      MedicalService(
        id: 'cardio_1',
        name: 'Cardiology Consultation',
        description: 'Specialist consultation for heart-related issues',
        category: 'Specialty Care',
        price: 120.0,
        currency: 'INR',
        duration: 45,
        includedTests: [
          'Physical Examination',
          'Heart Assessment',
          'Treatment Plan'
        ],
        requirements: ['Medical history', 'Previous test results'],
        rating: 4.8,
        reviewCount: 189,
      ),
      MedicalService(
        id: 'neuro_1',
        name: 'Neurology Consultation',
        description: 'Specialist consultation for neurological conditions',
        category: 'Specialty Care',
        price: 140.0,
        currency: 'INR',
        duration: 50,
        includedTests: [
          'Neurological Exam',
          'Brain Assessment',
          'Treatment Plan'
        ],
        requirements: ['Medical history', 'MRI/CT results if available'],
        rating: 4.7,
        reviewCount: 145,
      ),
      MedicalService(
        id: 'ortho_1',
        name: 'Orthopedic Consultation',
        description: 'Specialist consultation for bone and joint issues',
        category: 'Specialty Care',
        price: 110.0,
        currency: 'INR',
        duration: 40,
        includedTests: [
          'Physical Examination',
          'Joint Assessment',
          'Treatment Plan'
        ],
        requirements: ['Medical history', 'X-Ray results if available'],
        rating: 4.6,
        reviewCount: 267,
      ),
      MedicalService(
        id: 'pediatric_1',
        name: 'Pediatric Consultation',
        description: 'Specialist consultation for children\'s health',
        category: 'Specialty Care',
        price: 95.0,
        currency: 'INR',
        duration: 35,
        includedTests: [
          'Child Health Assessment',
          'Growth Monitoring',
          'Vaccination Check'
        ],
        requirements: ['Child\'s medical history', 'Parent/Guardian present'],
        rating: 4.9,
        reviewCount: 312,
      ),
      MedicalService(
        id: 'gyneco_1',
        name: 'Gynecology Consultation',
        description: 'Specialist consultation for women\'s health',
        category: 'Specialty Care',
        price: 100.0,
        currency: 'INR',
        duration: 40,
        includedTests: [
          'Women\'s Health Assessment',
          'Screening Tests',
          'Treatment Plan'
        ],
        requirements: ['Medical history', 'Previous gynecological records'],
        rating: 4.7,
        reviewCount: 198,
      ),

      // Support Services
      MedicalService(
        id: 'pharmacy_1',
        name: 'Pharmacy Services',
        description: 'In-house pharmacy with prescription medications',
        category: 'Support Services',
        price: 0.0, // Free consultation, only medication cost
        currency: 'INR',
        duration: 15,
        includedTests: [
          'Medication Review',
          'Prescription Filling',
          'Drug Interaction Check'
        ],
        requirements: ['Valid prescription', 'Insurance card if applicable'],
        rating: 4.3,
        reviewCount: 423,
      ),
      MedicalService(
        id: 'physio_1',
        name: 'Physiotherapy Session',
        description: 'Physical therapy session for rehabilitation',
        category: 'Support Services',
        price: 85.0,
        currency: 'INR',
        duration: 60,
        includedTests: [
          'Physical Assessment',
          'Therapy Session',
          'Exercise Plan'
        ],
        requirements: ['Doctor referral', 'Comfortable clothing'],
        rating: 4.6,
        reviewCount: 234,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          widget.hospital.name,
          style: const TextStyle(
            color: Color(0xFF2E7D32), // Dark green color for title
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            const Color(0xFFE8F5E8), // Light mint green from gradient
        elevation: 0,
        iconTheme: const IconThemeData(
            color: Color(0xFF2E7D32)), // Dark green for back button
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Statistics'),
            Tab(text: 'Reviews'),
            Tab(text: 'Services'),
          ],
          labelColor: Color(0xFF2E7D32), // Dark green for selected tab
          unselectedLabelColor:
              Color(0xFF81C784), // Lighter green for unselected tabs
          indicatorColor: Color(0xFF2E7D32), // Dark green for indicator
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5E8), // Light mint green
              Color(0xFFF0F8F0), // Very light sage
              Color(0xFFE6F3E6), // Soft green tint
              Color(0xFFF5F9F5), // Almost white with green tint
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildStatisticsTab(),
            _buildReviewsTab(),
            _buildServicesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hospital Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: widget.hospital.imageUrl != null
                  ? Image.network(
                      widget.hospital.imageUrl!,
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
                  widget.hospital.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
              ),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StarRatingWidget(
                        rating: widget.hospital.rating,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '${widget.hospital.rating.toStringAsFixed(1)} (${_hospitalStats.totalReviews})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Hospital Type
          Text(
            widget.hospital.type,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 16),

          // Quick Info Cards
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.access_time,
                  title: 'Status',
                  value: widget.hospital.isOpen ? 'Open Now' : 'Closed',
                  color: widget.hospital.isOpen ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.location_on,
                  title: 'Distance',
                  value: '${widget.hospital.distance} km',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.people,
                  title: 'Doctors',
                  value: '${widget.hospital.availableDoctors}',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Services Info Card
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.medical_services,
                  title: 'Services',
                  value: '${_medicalServices.length} Available',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.attach_money,
                  title: 'Avg. Price',
                  value:
                      '₹${(_medicalServices.map((s) => s.price).reduce((a, b) => a + b) / _medicalServices.length).toStringAsFixed(0)}',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.star,
                  title: 'Avg. Rating',
                  value:
                      '${(_medicalServices.map((s) => s.rating).reduce((a, b) => a + b) / _medicalServices.length).toStringAsFixed(1)}',
                  color: Colors.amber,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Location
          _buildSectionTitle('Location'),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.hospital.location,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Map
          HospitalMapWidget(
            hospital: widget.hospital,
            height: 250,
          ),

          const SizedBox(height: 20),

          // Description
          if (widget.hospital.description != null) ...[
            _buildSectionTitle('About'),
            const SizedBox(height: 8),
            Text(
              widget.hospital.description!,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
          ],

          // Specialties
          if (widget.hospital.specialties.isNotEmpty) ...[
            _buildSectionTitle('Specialties'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.hospital.specialties
                  .map((specialty) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          specialty,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Contact Info
          if (widget.hospital.contactInfo != null) ...[
            _buildSectionTitle('Contact'),
            const SizedBox(height: 12),
            if (widget.hospital.contactInfo!['phone'] != null)
              Row(
                children: [
                  Icon(Icons.phone, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    widget.hospital.contactInfo!['phone'],
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
          ],

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to booking
                    Navigator.pushNamed(context, '/book-appointment',
                        arguments: widget.hospital);
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Book Appointment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Call functionality
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('Call Now'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          RatingDistributionChart(
            ratingDistribution: _hospitalStats.ratingDistribution,
            totalReviews: _hospitalStats.totalReviews,
          ),
          const SizedBox(height: 16),
          ServiceRatingChart(
            serviceRatings: _hospitalStats.serviceRatings,
          ),
          const SizedBox(height: 16),
          _buildFeaturesCard(),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Review Summary
          Container(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            _hospitalStats.averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          StarRatingWidget(
                            rating: _hospitalStats.averageRating,
                            size: 20,
                            spacing: 1.0,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_hospitalStats.totalReviews} reviews',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: RatingBreakdown(
                        ratingDistribution: _hospitalStats.ratingDistribution,
                        totalReviews: _hospitalStats.totalReviews,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Write Review Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: WriteReviewWidget(
              onReviewSubmitted: (rating, comment) {
                // In a real app, you'd submit this to your backend
                final newReview = Review(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  userId: 'current_user',
                  userName: 'Current User',
                  userAvatarUrl: '',
                  rating: rating,
                  comment: comment,
                  timestamp: DateTime.now(),
                  isVerified: false,
                );

                setState(() {
                  _reviews.insert(0, newReview);
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          // Reviews List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _reviews.length,
            itemBuilder: (context, index) {
              final review = _reviews[index];
              // In a real app, you'd check if the current user is the owner of this review
              final canDelete =
                  review.userId == 'current_user'; // Mock condition

              return ReviewCard(
                review: review,
                canDelete: canDelete,
                onDelete: () => _deleteReview(index),
              );
            },
          ),

          const SizedBox(height: 100), // Extra space for keyboard
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    // Group services by category
    final Map<String, List<MedicalService>> servicesByCategory = {};
    for (final service in _medicalServices) {
      servicesByCategory.putIfAbsent(service.category, () => []).add(service);
    }

    // Calculate pricing statistics
    final totalServices = _medicalServices.length;
    final averagePrice =
        _medicalServices.map((s) => s.price).reduce((a, b) => a + b) /
            totalServices;
    final minPrice =
        _medicalServices.map((s) => s.price).reduce((a, b) => a < b ? a : b);
    final maxPrice =
        _medicalServices.map((s) => s.price).reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Available Services'),
          const SizedBox(height: 16),

          // Pricing summary card
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.attach_money,
                          color: AppColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Pricing Overview',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPricingStat(
                          'Total Services',
                          totalServices.toString(),
                          Icons.medical_services,
                        ),
                      ),
                      Expanded(
                        child: _buildPricingStat(
                          'Avg. Price',
                          '₹${averagePrice.toStringAsFixed(0)}',
                          Icons.trending_up,
                        ),
                      ),
                      Expanded(
                        child: _buildPricingStat(
                          'Price Range',
                          '₹${minPrice.toStringAsFixed(0)} - ₹${maxPrice.toStringAsFixed(0)}',
                          Icons.attach_money,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          ...servicesByCategory.entries.map(
            (entry) => _buildServiceCategoryWithPricing(
              entry.key,
              entry.value,
              _getCategoryIcon(entry.key),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Emergency Services':
        return Icons.local_hospital;
      case 'Diagnostic Services':
        return Icons.medical_services;
      case 'Specialty Care':
        return Icons.healing;
      case 'Support Services':
        return Icons.support;
      default:
        return Icons.medical_services;
    }
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
    );
  }

  Widget _buildFeaturesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Features',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _hospitalStats.topFeatures
                  .map((feature) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              feature,
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCategoryWithPricing(
    String title,
    List<MedicalService> services,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...services.map((service) => _buildServiceCard(service)),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(MedicalService service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service name and price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '₹${service.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            service.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),

          // Service details row
          Row(
            children: [
              // Duration
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${service.duration} min',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Rating
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${service.rating} (${service.reviewCount})',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Included tests
          if (service.includedTests.isNotEmpty) ...[
            Text(
              'Included:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: service.includedTests
                  .take(3) // Show only first 3 tests
                  .map((test) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          test,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green[700],
                          ),
                        ),
                      ))
                  .toList(),
            ),
            if (service.includedTests.length > 3)
              Text(
                '+${service.includedTests.length - 3} more',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 12),
          ],

          // Requirements
          if (service.requirements.isNotEmpty) ...[
            Text(
              'Requirements:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: service.requirements
                  .take(2) // Show only first 2 requirements
                  .map((req) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          req,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange[700],
                          ),
                        ),
                      ))
                  .toList(),
            ),
            if (service.requirements.length > 2)
              Text(
                '+${service.requirements.length - 2} more',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 12),
          ],

          // Book appointment button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navigate to booking screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Booking ${service.name}...'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Book Appointment',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteReview(int index) {
    final review = _reviews[index];

    setState(() {
      _reviews.removeAt(index);
    });

    // Show confirmation snackbar with undo option
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Review deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _reviews.insert(index, review);
            });
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
