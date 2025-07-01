import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/hospital.dart';
import '../../models/review.dart';
import 'widgets/star_rating_widget.dart';
import 'widgets/hospital_charts_widget.dart';
import 'widgets/review_card_widget.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.hospital.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Statistics'),
            Tab(text: 'Reviews'),
            Tab(text: 'Services'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.white,
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildStatisticsTab(),
          _buildReviewsTab(),
          _buildServicesTab(),
        ],
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Available Services'),
          const SizedBox(height: 16),
          _buildServiceCategory(
            'Emergency Services',
            [
              'Emergency Room',
              'Trauma Care',
              'Ambulance Service',
              'Critical Care',
            ],
            Icons.local_hospital,
          ),
          _buildServiceCategory(
            'Diagnostic Services',
            [
              'X-Ray',
              'MRI Scan',
              'CT Scan',
              'Blood Tests',
              'ECG',
            ],
            Icons.medical_services,
          ),
          _buildServiceCategory(
            'Specialty Care',
            [
              'Cardiology',
              'Neurology',
              'Orthopedics',
              'Pediatrics',
              'Gynecology',
            ],
            Icons.healing,
          ),
          _buildServiceCategory(
            'Support Services',
            [
              'Pharmacy',
              'Cafeteria',
              'Parking',
              'Wi-Fi',
              'Patient Rooms',
            ],
            Icons.support,
          ),
        ],
      ),
    );
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

  Widget _buildServiceCategory(
    String title,
    List<String> services,
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: services
                  .map((service) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          service,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
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
