import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/hospital.dart';
import '../models/offer_package.dart';
import '../core/services/pre_approval_service.dart';
import '../core/services/hospital_service.dart';
import '../core/services/offer_service.dart';
import 'notification_view_model.dart';

class HomeViewModel extends BaseViewModel {
  HomeViewModel() {
    init();
  }
  String userName = "John Doe";
  String userLocation = "San Francisco, CA";

  // Unread notification count (matches the notification data)
  int get unreadCount => 5; // 5 unread notifications in the dummy data

  List<Map<String, dynamic>> categories = [
    {'name': 'General', 'icon': Icons.medical_services},
    {'name': 'Cardiology', 'icon': Icons.favorite},
    {'name': 'Dental', 'icon': Icons.face},
    {'name': 'Eye Care', 'icon': Icons.remove_red_eye},
    {'name': 'Blogs', 'icon': Icons.article},
  ];

  String selectedCategory = 'General';

  // Offers & Packages data
  List<OfferPackage> offers = [];

  List<Appointment> upcomingAppointments = [
    Appointment(
      id: '2001',
      doctorName: "Dr. Sarah Johnson",
      doctorImage:
      "https://img.freepik.com/free-photo/woman-doctor-wearing-lab-coat-with-stethoscope-isolated_1303-29791.jpg",
      specialty: "Cardiologist",
      isVideoCall: true,
      date: "Jun 30, 2025",
      time: "10:00 AM",
      appointmentType: "consultation",
      preApprovalStatus: "pending",
    ),
    Appointment(
      id: '2002',
      doctorName: "Dr. Michael Chen",
      doctorImage:
      "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
      specialty: "Dentist",
      isVideoCall: false,
      date: "Jul 01, 2025",
      time: "2:30 PM",
      appointmentType: "consultation",
      preApprovalStatus: "notRequired",
    ),
    Appointment(
      id: '2003',
      doctorName: "Dr. Emily Brown",
      doctorImage:
      "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
      specialty: "Pediatrician",
      isVideoCall: true,
      date: "Jul 03, 2025",
      time: "4:00 PM",
      appointmentType: "consultation",
      preApprovalStatus: "notRequired",
    ),
  ];

  List<String> specialties = [
    'All',
    'General',
    'Cardiology',
    'Dental',
    'Eye Care'
  ];
  String selectedSpecialty = 'All';

  // Hospital filtering
  List<String> hospitalTypes = [
    'All',
    'General Hospital',
    'Academic Medical Center',
    'University Hospital',
    'Specialty Clinic',
    'Emergency Center',
    'Government Hospital',
    'Multi-Specialty Hospital'
  ];
  String selectedHospitalType = 'All';

  // Cost filtering
  List<String> costCategories = ['All', 'Low', 'Medium', 'High', 'Premium'];
  String selectedCostCategory = 'All';

  // Hospital specialties for filtering
  List<String> hospitalSpecialties = [
    'All',
    'Cardiology',
    'Emergency Medicine',
    'Surgery',
    'Neurology',
    'Orthopedics',
    'Dental Care',
    'Dermatology',
    'Pediatrics',
    'Oncology',
    'Ophthalmology',
    'Otolaryngology',
    'Plastic Surgery',
    'Internal Medicine',
    'Radiology',
    'Pathology',
    'Trauma Care',
    'Critical Care'
  ];
  String selectedHospitalSpecialty = 'All';

  // Get filtered hospitals based on selected filters
  List<Hospital> get filteredHospitals {
    List<Hospital> filtered = hospitals;

    // Filter by hospital type
    if (selectedHospitalType != 'All') {
      filtered = filtered
          .where((hospital) => hospital.type == selectedHospitalType)
          .toList();
    }

    // Filter by cost category
    if (selectedCostCategory != 'All') {
      filtered = filtered
          .where((hospital) => hospital.costCategory == selectedCostCategory)
          .toList();
    }

    // Filter by specialty
    if (selectedHospitalSpecialty != 'All') {
      filtered = filtered
          .where((hospital) =>
          hospital.specialties.contains(selectedHospitalSpecialty))
          .toList();
    }

    return filtered;
  }

  List<Doctor> doctors = [
    Doctor(
      id: '1',
      name: "Dr. Sarah Johnson",
      imageUrl:
      "https://img.freepik.com/free-photo/woman-doctor-wearing-lab-coat-with-stethoscope-isolated_1303-29791.jpg",
      specialty: "Cardiologist",
      hospital: "Mount Sinai Hospital",
      rating: 4.8,
      reviews: 128,
      price: 100.0,
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
      'Dr. Sarah Johnson is a board-certified cardiologist with over 15 years of experience.',
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
      location: 'New York, NY',
      distance: 0.8,
      isVerified: true,
      phoneNumber: '+1 555-123-4567',
      email: 'dr.sarah.johnson@hospital.com',
      symptoms: ['Chest Pain', 'Heart Palpitations', 'High Blood Pressure'],
      videoCall: true,
    ),
    Doctor(
      id: '2',
      name: "Dr. Michael Chen",
      imageUrl:
      "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
      specialty: "Dentist",
      hospital: "NYU Langone",
      rating: 4.7,
      reviews: 89,
      price: 90.0,
      isOnline: false,
      isAvailable: true,
      experience: 12,
      education: 'BDS, MDS - Orthodontics, NYU School of Dentistry',
      languages: ['English', 'Mandarin'],
      specializations: [
        'Orthodontics',
        'Cosmetic Dentistry',
        'Root Canal Treatment'
      ],
      about:
      'Dr. Michael Chen is a skilled dentist with expertise in orthodontics.',
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
      location: 'New York, NY',
      distance: 1.2,
      isVerified: true,
      phoneNumber: '+1 555-234-5678',
      email: 'dr.michael.chen@dental.com',
      symptoms: ['Tooth Pain', 'Gum Problems', 'Teeth Whitening'],
      videoCall: false,
    ),
    Doctor(
      id: '3',
      name: "Dr. Emily Brown",
      imageUrl:
      "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
      specialty: "Pediatrician",
      hospital: "Columbia Presbyterian",
      rating: 4.9,
      reviews: 175,
      price: 110.0,
      isOnline: true,
      isAvailable: true,
      experience: 18,
      education: 'MBBS, MD - Pediatrics, Columbia University',
      languages: ['English', 'Spanish'],
      specializations: [
        'General Pediatrics',
        'Child Development',
        'Vaccination'
      ],
      about:
      'Dr. Emily Brown is a compassionate pediatrician with 18 years of experience.',
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
      location: 'New York, NY',
      distance: 2.5,
      isVerified: true,
      phoneNumber: '+1 555-345-6789',
      email: 'dr.emily.brown@children.com',
      symptoms: ['Fever', 'Cough', 'Growth Concerns', 'Vaccination'],
      videoCall: true,
    ),
  ];

  List<Hospital> hospitals = [];
  bool _hospitalsLoaded = false;
  String? _hospitalsError;

  String? get hospitalsError => _hospitalsError;
  bool get isBusy => busy;

  // API Integration Methods
  Future<void> loadHospitals() async {
    if (_hospitalsLoaded) return;

    setBusy(true);
    _hospitalsError = null;

    try {
      final result = await HospitalService.getHospitals(
        page: 1,
        limit: 20,
        sortBy: 'rating',
        sortOrder: 'desc',
      );
      print('DEBUG: API result from getHospitals:');
      print(result);

      if (result['success'] == true) {
        final hospitalsData = result['data'] as List<dynamic>;
        hospitals = hospitalsData
            .map((data) => HospitalService.convertToHospitalModel(data))
            .toList();
        print('DEBUG: Parsed hospitals count: ${hospitals.length}');
        _hospitalsLoaded = true;
        print('✅ Loaded ${hospitals.length} hospitals from API');
      } else {
        _hospitalsError = result['message'] ?? 'Failed to load hospitals';
        print('❌ Failed to load hospitals: ${result['message']}');
        hospitals = []; // Clear hospitals on error
      }
    } catch (e) {
      _hospitalsError = 'Error loading hospitals: ${e.toString()}';
      print('❌ Exception loading hospitals: $e');
      hospitals = []; // Clear hospitals on error
    } finally {
      setBusy(false);
    }
  }

  Future<void> searchNearbyHospitals({
    required double latitude,
    required double longitude,
    double maxDistance = 10000,
  }) async {
    setBusy(true);
    _hospitalsError = null;

    try {
      final result = await HospitalService.searchNearbyHospitals(
        latitude: latitude,
        longitude: longitude,
        maxDistance: maxDistance,
      );
      print('DEBUG: API result from searchNearbyHospitals:');
      print(result);

      if (result['success'] == true) {
        final hospitalsData = result['data'] as List<dynamic>;
        hospitals = hospitalsData
            .map((data) => HospitalService.convertToHospitalModel(data))
            .toList();
        print('DEBUG: Parsed hospitals count: ${hospitals.length}');
        _hospitalsLoaded = true;
        print('✅ Found ${hospitals.length} nearby hospitals');
      } else {
        _hospitalsError =
            result['message'] ?? 'Failed to search nearby hospitals';
        print('❌ Failed to search nearby hospitals: ${result['message']}');
        hospitals = []; // Clear hospitals on error
      }
    } catch (e) {
      _hospitalsError = 'Error searching nearby hospitals: ${e.toString()}';
      print('❌ Exception searching nearby hospitals: $e');
      hospitals = []; // Clear hospitals on error
    } finally {
      setBusy(false);
    }
  }

  Future<void> refreshHospitals() async {
    _hospitalsLoaded = false;
    await loadHospitals();
  }

  @override
  void init() {
    super.init();
    // Load hospitals from API when view model is initialized
    loadHospitals();
    loadOffers();
  }

  Future<void> loadOffers() async {
    setBusy(true);
    offers = await OfferService.getOffers();
    print('Loaded offers: ${offers.length}');
    setBusy(false);
    notifyListeners();
  }

  Future<bool> createOffer(Map<String, dynamic> offerData) async {
    setBusy(true);
    final offer = await OfferService.createOffer(offerData);
    if (offer != null) {
      offers.insert(0, offer);
      setBusy(false);
      notifyListeners();
      return true;
    }
    setBusy(false);
    return false;
  }


  void setSpecialty(String specialty) {
    selectedSpecialty = specialty;
    notifyListeners();
  }

  void setCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void setHospitalType(String hospitalType) {
    selectedHospitalType = hospitalType;
    notifyListeners();
  }

  void setCostCategory(String costCategory) {
    selectedCostCategory = costCategory;
    notifyListeners();
  }

  void setHospitalSpecialty(String specialty) {
    selectedHospitalSpecialty = specialty;
    notifyListeners();
  }
}
