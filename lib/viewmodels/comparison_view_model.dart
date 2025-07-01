import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/service_provider.dart';
import '../models/medical_service.dart';

class ComparisonViewModel extends BaseViewModel {
  List<ServiceProvider> _providers = [];
  List<ServiceProvider> _selectedProviders = [];
  String _selectedServiceCategory = '';
  List<String> _availableCategories = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<ServiceProvider> get providers => _providers;
  List<ServiceProvider> get selectedProviders => _selectedProviders;
  String get selectedServiceCategory => _selectedServiceCategory;
  List<String> get availableCategories => _availableCategories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize with sample data
  void initialize() {
    _loadSampleData();
  }

  void _loadSampleData() {
    setBusy(true);
    
    // Sample medical services
    final bloodTestService = MedicalService(
      id: 'blood_test_1',
      name: 'Complete Blood Count (CBC)',
      description: 'Comprehensive blood analysis including red blood cells, white blood cells, and platelets',
      category: 'Laboratory Tests',
      price: 45.0,
      duration: 30,
      includedTests: ['RBC Count', 'WBC Count', 'Hemoglobin', 'Platelet Count'],
      requirements: ['Fasting for 8-12 hours', 'No medications 24h before'],
      rating: 4.5,
      reviewCount: 128,
    );

    final mriService = MedicalService(
      id: 'mri_1',
      name: 'MRI Scan - Brain',
      description: 'Magnetic Resonance Imaging of the brain for detailed neurological assessment',
      category: 'Imaging',
      price: 350.0,
      duration: 45,
      includedTests: ['Brain MRI', 'Radiologist Report', 'Digital Images'],
      requirements: ['No metal objects', 'Remove jewelry', 'Comfortable clothing'],
      rating: 4.8,
      reviewCount: 89,
    );

    final consultationService = MedicalService(
      id: 'consultation_1',
      name: 'General Consultation',
      description: 'Comprehensive health consultation with a general practitioner',
      category: 'Consultation',
      price: 80.0,
      duration: 30,
      includedTests: ['Physical Examination', 'Health Assessment', 'Prescription if needed'],
      requirements: ['Bring medical history', 'List of current medications'],
      rating: 4.6,
      reviewCount: 256,
    );

    // Sample service providers
    _providers = [
      ServiceProvider(
        id: '1',
        name: 'City General Hospital',
        type: 'hospital',
        location: 'Downtown Medical District',
        rating: 4.7,
        reviewCount: 1247,
        distance: 2.3,
        isOpen: true,
        imageUrl: 'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=400',
        description: 'Leading hospital with state-of-the-art facilities',
        specialties: ['Cardiology', 'Neurology', 'Orthopedics'],
        services: [bloodTestService, mriService, consultationService],
        workingHours: '24/7',
        facilities: ['ICU', 'Emergency Room', 'Laboratory', 'Imaging Center'],
        averagePrice: 158.33,
        totalServices: 3,
      ),
      ServiceProvider(
        id: '2',
        name: 'Community Medical Clinic',
        type: 'clinic',
        location: 'Westside Plaza',
        rating: 4.3,
        reviewCount: 892,
        distance: 1.8,
        isOpen: true,
        imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400',
        description: 'Family-friendly clinic with personalized care',
        specialties: ['Family Medicine', 'Pediatrics', 'Preventive Care'],
        services: [
          MedicalService(
            id: 'blood_test_2',
            name: 'Complete Blood Count (CBC)',
            description: 'Standard blood analysis with quick results',
            category: 'Laboratory Tests',
            price: 35.0,
            duration: 20,
            includedTests: ['RBC Count', 'WBC Count', 'Hemoglobin'],
            requirements: ['Fasting for 8 hours'],
            rating: 4.2,
            reviewCount: 95,
          ),
          MedicalService(
            id: 'consultation_2',
            name: 'General Consultation',
            description: 'Friendly consultation with family doctor',
            category: 'Consultation',
            price: 65.0,
            duration: 25,
            includedTests: ['Physical Examination', 'Health Advice'],
            requirements: ['Medical history'],
            rating: 4.4,
            reviewCount: 203,
          ),
        ],
        workingHours: 'Mon-Fri: 8AM-6PM, Sat: 9AM-2PM',
        facilities: ['Waiting Room', 'Examination Rooms', 'Basic Laboratory'],
        averagePrice: 50.0,
        totalServices: 2,
      ),
      ServiceProvider(
        id: '3',
        name: 'Premium Health Center',
        type: 'clinic',
        location: 'Uptown Business District',
        rating: 4.9,
        reviewCount: 567,
        distance: 3.1,
        isOpen: true,
        imageUrl: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=400',
        description: 'Premium healthcare with luxury amenities',
        specialties: ['Executive Health', 'Wellness', 'Preventive Medicine'],
        services: [
          MedicalService(
            id: 'blood_test_3',
            name: 'Complete Blood Count (CBC)',
            description: 'Premium blood analysis with comprehensive panel',
            category: 'Laboratory Tests',
            price: 75.0,
            duration: 40,
            includedTests: ['RBC Count', 'WBC Count', 'Hemoglobin', 'Platelet Count', 'ESR', 'CRP'],
            requirements: ['Fasting for 12 hours', 'No medications 48h before'],
            rating: 4.9,
            reviewCount: 67,
          ),
          MedicalService(
            id: 'mri_3',
            name: 'MRI Scan - Brain',
            description: 'High-resolution MRI with 3T technology',
            category: 'Imaging',
            price: 450.0,
            duration: 60,
            includedTests: ['Brain MRI', 'Specialist Report', '3D Reconstruction', 'Digital Images'],
            requirements: ['No metal objects', 'Comfortable clothing', 'Arrive 15min early'],
            rating: 4.9,
            reviewCount: 34,
          ),
          MedicalService(
            id: 'consultation_3',
            name: 'Executive Consultation',
            description: 'Comprehensive health assessment with specialist',
            category: 'Consultation',
            price: 150.0,
            duration: 60,
            includedTests: ['Comprehensive Physical', 'Health Risk Assessment', 'Lifestyle Consultation'],
            requirements: ['Complete medical history', 'Current medications list'],
            rating: 4.8,
            reviewCount: 89,
          ),
        ],
        workingHours: 'Mon-Fri: 7AM-8PM, Sat: 9AM-5PM',
        facilities: ['Private Rooms', 'Luxury Waiting Area', 'Advanced Laboratory', 'Imaging Suite'],
        averagePrice: 225.0,
        totalServices: 3,
      ),
    ];

    // Extract available categories
    _availableCategories = _providers
        .expand((provider) => provider.services)
        .map((service) => service.category)
        .toSet()
        .toList();

    if (_availableCategories.isNotEmpty) {
      _selectedServiceCategory = _availableCategories.first;
    }

    setBusy(false);
  }

  void selectProvider(ServiceProvider provider) {
    if (_selectedProviders.length < 3 && !_selectedProviders.contains(provider)) {
      _selectedProviders.add(provider);
      notifyListeners();
    }
  }

  void removeProvider(ServiceProvider provider) {
    _selectedProviders.remove(provider);
    notifyListeners();
  }

  void setServiceCategory(String category) {
    _selectedServiceCategory = category;
    notifyListeners();
  }

  List<MedicalService> getServicesForCategory(String category) {
    return _providers
        .expand((provider) => provider.services)
        .where((service) => service.category == category)
        .toList();
  }

  List<MedicalService> getServicesForProviderAndCategory(ServiceProvider provider, String category) {
    return provider.services.where((service) => service.category == category).toList();
  }

  void clearSelection() {
    _selectedProviders.clear();
    notifyListeners();
  }

  ServiceProvider? getProviderById(String id) {
    try {
      return _providers.firstWhere((provider) => provider.id == id);
    } catch (e) {
      return null;
    }
  }

  List<ServiceProvider> getProvidersByCategory(String category) {
    return _providers.where((provider) => 
      provider.services.any((service) => service.category == category)
    ).toList();
  }

  void sortProvidersByPrice({bool ascending = true}) {
    _selectedProviders.sort((a, b) {
      final aService = a.services.firstWhere(
        (s) => s.category == _selectedServiceCategory,
        orElse: () => MedicalService(
          id: '', name: '', description: '', category: '', price: 0, duration: 0,
        ),
      );
      final bService = b.services.firstWhere(
        (s) => s.category == _selectedServiceCategory,
        orElse: () => MedicalService(
          id: '', name: '', description: '', category: '', price: 0, duration: 0,
        ),
      );
      
      return ascending 
          ? aService.price.compareTo(bService.price)
          : bService.price.compareTo(aService.price);
    });
    notifyListeners();
  }

  void sortProvidersByRating({bool ascending = false}) {
    _selectedProviders.sort((a, b) {
      return ascending 
          ? a.rating.compareTo(b.rating)
          : b.rating.compareTo(a.rating);
    });
    notifyListeners();
  }

  void sortProvidersByDistance({bool ascending = true}) {
    _selectedProviders.sort((a, b) {
      return ascending 
          ? a.distance.compareTo(b.distance)
          : b.distance.compareTo(a.distance);
    });
    notifyListeners();
  }
} 