import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/doctor.dart';
import '../models/doctor_review.dart';

enum DoctorFilter {
  all,
  online,
  nearby,
  topRated,
  lowPrice,
  highPrice,
  verified,
}

class DoctorsViewModel extends BaseViewModel {
  List<Doctor> _allDoctors = [];
  List<Doctor> _filteredDoctors = [];
  List<DoctorReview> _doctorReviews = [];
  String _searchQuery = '';
  DoctorFilter _selectedFilter = DoctorFilter.all;
  String _selectedSpecialty = 'All';
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Doctor> get allDoctors => _allDoctors;
  List<Doctor> get filteredDoctors => _filteredDoctors;
  List<DoctorReview> get doctorReviews => _doctorReviews;
  String get searchQuery => _searchQuery;
  DoctorFilter get selectedFilter => _selectedFilter;
  String get selectedSpecialty => _selectedSpecialty;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<String> get availableSpecialties {
    final specialties = _allDoctors.map((d) => d.specialty).toSet().toList();
    specialties.insert(0, 'All');
    return specialties;
  }

  @override
  void init() {
    _loadDummyData();
    _applyFilters();
    notifyListeners();
  }

  void _loadDummyData() {
    setBusy(true);

    // Load dummy doctors data
    _allDoctors = [
      Doctor(
        id: '1',
        name: 'Dr. Sarah Johnson',
        imageUrl:
            'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400',
        specialty: 'Cardiologist',
        hospital: 'Mount Sinai Hospital',
        rating: 4.8,
        reviews: 128,
        price: 1200.0,
        isOnline: true,
        isAvailable: true,
        experience: 15,
        education: 'MBBS, MD - Cardiology, Harvard Medical School',
        languages: ['English', 'Spanish'],
        specializations: [
          'Interventional Cardiology',
          'Heart Failure',
          'Preventive Cardiology'
        ],
        about:
            'Dr. Sarah Johnson is a board-certified cardiologist with over 15 years of experience in treating cardiovascular diseases. She specializes in interventional cardiology and has performed over 1000 successful procedures.',
        availability: {
          'Monday': '9:00 AM - 5:00 PM',
          'Tuesday': '9:00 AM - 5:00 PM',
          'Wednesday': '9:00 AM - 5:00 PM',
          'Thursday': '9:00 AM - 5:00 PM',
          'Friday': '9:00 AM - 5:00 PM',
          'Saturday': '9:00 AM - 2:00 PM',
          'Sunday': 'Closed',
        },
        awards: ['Best Cardiologist 2023', 'Excellence in Patient Care Award'],
        consultationFee: '₹1200',
        acceptsInsurance: true,
        insuranceProviders: ['Max Bupa', 'HDFC Health', 'ICICI Lombard'],
        location: 'Mumbai, Maharashtra',
        distance: 2.3,
        isVerified: true,
        phoneNumber: '+91 98765 43210',
        email: 'dr.sarah.johnson@hospital.com',
        symptoms: ['Chest Pain', 'Heart Palpitations', 'High Blood Pressure'],
        videoCall: true,
      ),
      Doctor(
        id: '2',
        name: 'Dr. Michael Chen',
        imageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        specialty: 'Dentist',
        hospital: 'NYU Langone',
        rating: 4.7,
        reviews: 89,
        price: 800.0,
        isOnline: false,
        isAvailable: true,
        experience: 12,
        education: 'BDS, MDS - Orthodontics, Delhi University',
        languages: ['English', 'Hindi', 'Mandarin'],
        specializations: [
          'Orthodontics',
          'Cosmetic Dentistry',
          'Root Canal Treatment'
        ],
        about:
            'Dr. Michael Chen is a skilled dentist with expertise in orthodontics and cosmetic dentistry. He has helped hundreds of patients achieve their perfect smile.',
        availability: {
          'Monday': '10:00 AM - 6:00 PM',
          'Tuesday': '10:00 AM - 6:00 PM',
          'Wednesday': '10:00 AM - 6:00 PM',
          'Thursday': '10:00 AM - 6:00 PM',
          'Friday': '10:00 AM - 6:00 PM',
          'Saturday': '9:00 AM - 3:00 PM',
          'Sunday': 'Closed',
        },
        awards: ['Best Dentist Award 2022', 'Patient Choice Award'],
        consultationFee: '₹800',
        acceptsInsurance: true,
        insuranceProviders: ['Max Bupa', 'Star Health'],
        location: 'Delhi, NCR',
        distance: 1.8,
        isVerified: true,
        phoneNumber: '+91 98765 43211',
        email: 'dr.michael.chen@dental.com',
        symptoms: ['Tooth Pain', 'Gum Problems', 'Teeth Whitening'],
        videoCall: false,
      ),
      Doctor(
        id: '3',
        name: 'Dr. Emily Brown',
        imageUrl:
            'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400',
        specialty: 'Pediatrician',
        hospital: 'Children\'s Hospital',
        rating: 4.9,
        reviews: 156,
        price: 1000.0,
        isOnline: true,
        experience: 18,
        education: 'MBBS, MD - Pediatrics, AIIMS Delhi',
        languages: ['English', 'Hindi'],
        specializations: [
          'General Pediatrics',
          'Child Development',
          'Vaccination'
        ],
        about:
            'Dr. Emily Brown is a compassionate pediatrician with 18 years of experience in child healthcare. She specializes in child development and preventive care.',
        availability: {
          'Monday': '8:00 AM - 4:00 PM',
          'Tuesday': '8:00 AM - 4:00 PM',
          'Wednesday': '8:00 AM - 4:00 PM',
          'Thursday': '8:00 AM - 4:00 PM',
          'Friday': '8:00 AM - 4:00 PM',
          'Saturday': '8:00 AM - 12:00 PM',
          'Sunday': 'Closed',
        },
        awards: ['Best Pediatrician 2023', 'Child Care Excellence Award'],
        consultationFee: '₹1000',
        acceptsInsurance: true,
        insuranceProviders: ['Max Bupa', 'HDFC Health', 'Star Health'],
        location: 'Bangalore, Karnataka',
        distance: 3.1,
        isVerified: true,
        phoneNumber: '+91 98765 43212',
        email: 'dr.emily.brown@children.com',
        symptoms: ['Fever', 'Cough', 'Growth Concerns', 'Vaccination'],
        videoCall: true,
        isAvailable: true,
      ),
      Doctor(
        id: '4',
        name: 'Dr. David Wilson',
        imageUrl:
            'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400',
        specialty: 'Neurologist',
        hospital: 'Johns Hopkins',
        rating: 4.6,
        reviews: 203,
        price: 1500.0,
        isOnline: false,
        isAvailable: true,
        experience: 20,
        education: 'MBBS, MD - Neurology, JIPMER',
        languages: ['English', 'Hindi', 'Tamil'],
        specializations: [
          'Stroke Management',
          'Epilepsy',
          'Movement Disorders'
        ],
        about:
            'Dr. David Wilson is a renowned neurologist specializing in stroke management and neurological disorders. He has published over 50 research papers.',
        availability: {
          'Monday': '9:00 AM - 6:00 PM',
          'Tuesday': '9:00 AM - 6:00 PM',
          'Wednesday': '9:00 AM - 6:00 PM',
          'Thursday': '9:00 AM - 6:00 PM',
          'Friday': '9:00 AM - 6:00 PM',
          'Saturday': '9:00 AM - 2:00 PM',
          'Sunday': 'Closed',
        },
        awards: ['Neurology Excellence Award', 'Research Achievement Award'],
        consultationFee: '₹1500',
        acceptsInsurance: true,
        insuranceProviders: ['Max Bupa', 'HDFC Health', 'ICICI Lombard'],
        location: 'Chennai, Tamil Nadu',
        distance: 4.2,
        isVerified: true,
        phoneNumber: '+91 98765 43213',
        email: 'dr.david.wilson@neuro.com',
        symptoms: ['Headaches', 'Seizures', 'Memory Problems'],
        videoCall: false,
      ),
      Doctor(
        id: '5',
        name: 'Dr. Lisa Rodriguez',
        imageUrl:
            'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=400',
        specialty: 'Dermatologist',
        hospital: 'Mayo Clinic',
        rating: 4.5,
        reviews: 94,
        price: 900.0,
        isOnline: true,
        experience: 14,
        education: 'MBBS, MD - Dermatology, PGIMER',
        languages: ['English', 'Hindi', 'Spanish'],
        specializations: [
          'Cosmetic Dermatology',
          'Skin Cancer',
          'Acne Treatment'
        ],
        about:
            'Dr. Lisa Rodriguez is a board-certified dermatologist with expertise in cosmetic procedures and skin cancer treatment.',
        availability: {
          'Monday': '10:00 AM - 7:00 PM',
          'Tuesday': '10:00 AM - 7:00 PM',
          'Wednesday': '10:00 AM - 7:00 PM',
          'Thursday': '10:00 AM - 7:00 PM',
          'Friday': '10:00 AM - 7:00 PM',
          'Saturday': '10:00 AM - 4:00 PM',
          'Sunday': 'Closed',
        },
        awards: ['Dermatology Excellence Award', 'Patient Satisfaction Award'],
        consultationFee: '₹900',
        acceptsInsurance: true,
        insuranceProviders: ['Max Bupa', 'Star Health'],
        location: 'Pune, Maharashtra',
        distance: 2.8,
        isVerified: true,
        phoneNumber: '+91 98765 43214',
        email: 'dr.lisa.rodriguez@derma.com',
        symptoms: ['Acne', 'Skin Rash', 'Moles'],
        videoCall: true,
        isAvailable: true,
      ),
    ];

    // Load dummy reviews data
    _doctorReviews = [
      DoctorReview(
        id: '1',
        doctorId: '1',
        userId: 'user1',
        userName: 'Rahul Sharma',
        userAvatarUrl:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
        rating: 5.0,
        comment:
            'Excellent doctor! Dr. Sarah was very thorough and explained everything clearly. Highly recommend for any heart-related issues.',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        isVerified: true,
        consultationType: 'In-person',
        treatmentOutcome: 'Significant improvement in heart condition',
        wouldRecommend: true,
        categoryRatings: {
          'Bedside Manner': 5.0,
          'Expertise': 5.0,
          'Communication': 4.8,
          'Treatment Effectiveness': 5.0,
        },
      ),
      DoctorReview(
        id: '2',
        doctorId: '1',
        userId: 'user2',
        userName: 'Priya Patel',
        userAvatarUrl:
            'https://images.unsplash.com/photo-1494790108755-2616b812b833?w=150',
        rating: 4.5,
        comment:
            'Very professional and caring doctor. The consultation was comprehensive and she took time to address all my concerns.',
        timestamp: DateTime.now().subtract(const Duration(days: 12)),
        isVerified: true,
        consultationType: 'Online',
        treatmentOutcome: 'Condition stabilized',
        wouldRecommend: true,
        categoryRatings: {
          'Bedside Manner': 4.5,
          'Expertise': 4.8,
          'Communication': 4.7,
          'Treatment Effectiveness': 4.5,
        },
      ),
      DoctorReview(
        id: '3',
        doctorId: '2',
        userId: 'user3',
        userName: 'Amit Kumar',
        userAvatarUrl: '',
        rating: 4.7,
        comment:
            'Great dentist! Very gentle and professional. The root canal treatment was painless and quick.',
        timestamp: DateTime.now().subtract(const Duration(days: 8)),
        isVerified: false,
        consultationType: 'In-person',
        treatmentOutcome: 'Complete recovery',
        wouldRecommend: true,
        categoryRatings: {
          'Bedside Manner': 4.8,
          'Expertise': 4.7,
          'Communication': 4.6,
          'Treatment Effectiveness': 4.8,
        },
      ),
    ];

    setBusy(false);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setFilter(DoctorFilter filter) {
    _selectedFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  void setSpecialty(String specialty) {
    _selectedSpecialty = specialty;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    List<Doctor> filtered = List.from(_allDoctors);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((doctor) =>
              doctor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              doctor.specialty
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              doctor.hospital
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply specialty filter
    if (_selectedSpecialty != 'All') {
      filtered = filtered
          .where((doctor) => doctor.specialty == _selectedSpecialty)
          .toList();
    }

    // Apply other filters
    switch (_selectedFilter) {
      case DoctorFilter.online:
        filtered = filtered.where((doctor) => doctor.isOnline).toList();
        break;
      case DoctorFilter.nearby:
        filtered.sort((a, b) => a.distance.compareTo(b.distance));
        break;
      case DoctorFilter.topRated:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case DoctorFilter.lowPrice:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case DoctorFilter.highPrice:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case DoctorFilter.verified:
        filtered = filtered.where((doctor) => doctor.isVerified).toList();
        break;
      case DoctorFilter.all:
      default:
        // No additional filtering
        break;
    }

    _filteredDoctors = filtered;
  }

  List<DoctorReview> getReviewsForDoctor(String doctorId) {
    return _doctorReviews
        .where((review) => review.doctorId == doctorId)
        .toList();
  }

  double getAverageCategoryRating(String doctorId, String category) {
    final reviews = getReviewsForDoctor(doctorId);
    if (reviews.isEmpty) return 0.0;

    double total = 0.0;
    int count = 0;

    for (final review in reviews) {
      if (review.categoryRatings != null &&
          review.categoryRatings!.containsKey(category)) {
        total += review.categoryRatings![category]!;
        count++;
      }
    }

    return count > 0 ? total / count : 0.0;
  }

  void addReview(DoctorReview review) {
    _doctorReviews.add(review);
    notifyListeners();
  }

  void deleteReview(String reviewId) {
    _doctorReviews.removeWhere((review) => review.id == reviewId);
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedFilter = DoctorFilter.all;
    _selectedSpecialty = 'All';
    _applyFilters();
    notifyListeners();
  }
}
