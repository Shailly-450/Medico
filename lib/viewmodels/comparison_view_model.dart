import 'package:flutter/material.dart';
import '../models/medical_service.dart';
import '../models/service_provider.dart';
import '../core/services/services_api_service.dart';
import '../core/services/services_api_service.dart' show ProviderService;

class ComparisonViewModel extends ChangeNotifier {
  List<MedicalService> _allServices = [];
  List<String> _allCategories = [];
  List<ServiceProvider> _providers = [];
  List<ServiceProvider> _selectedProviders = [];
  String _selectedServiceCategory = 'All';
  String _selectedService = '';
  MedicalService? _selectedServiceDetails;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filter states
  bool _nearest = false;
  bool _lowCost = false;
  bool _topRated = false;
  bool _insurance = false;
  bool _availableToday = false;
  Map<String, double>? _userLocation;
  List<ProviderService> _providerServices = [];
  List<ProviderService> get providerServices => _providerServices;
  List<ProviderService> _providerServicesByProvider = [];
  List<ProviderService> get providerServicesByProvider => _providerServicesByProvider;
  List<ProviderService> _providersByService = [];
  List<ProviderService> get providersByService => _providersByService;
  Map<String, dynamic> _availableFilters = {};
  Map<String, dynamic> get availableFilters => _availableFilters;
  List<Map<String, dynamic>> _providerReviews = [];
  List<Map<String, dynamic>> get providerReviews => _providerReviews;
  List<Map<String, dynamic>> _serviceReviews = [];
  List<Map<String, dynamic>> get serviceReviews => _serviceReviews;

  // Getters
  List<MedicalService> get allServices => _allServices;
  List<String> get allCategories => _allCategories;
  List<ServiceProvider> get providers => _providers;
  List<ServiceProvider> get selectedProviders => _selectedProviders;
  String get selectedServiceCategory => _selectedServiceCategory;
  String get selectedService => _selectedService;
  MedicalService? get selectedServiceDetails => _selectedServiceDetails;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Filter getters
  bool get nearest => _nearest;
  bool get lowCost => _lowCost;
  bool get topRated => _topRated;
  bool get insurance => _insurance;
  bool get availableToday => _availableToday;
  Map<String, double>? get userLocation => _userLocation;

  // Initialize the view model
  Future<void> initialize() async {
    await _loadServicesFromApi();
    await _loadProvidersFromApi();
    await _loadProviderServicesFromApi();
    await fetchAvailableFilters();
  }

  // Load services from API
  Future<void> _loadServicesFromApi() async {
    _setLoading(true);
    _clearError();

    try {
      // Load categories first
      final categories = await ServicesApiService.fetchCategories();
      
      // Load all services
      final services = await ServicesApiService.fetchServices();
      
      _allCategories = categories;
      _allServices = services;
      
      // Set default selected service if available
      if (_allServices.isNotEmpty) {
        _selectedService = _allServices.first.name;
        await _loadServiceDetails(_allServices.first.id);
      }
      
      _setLoading(false);
      
      
    } catch (e) {
      _setError('Failed to load services: $e');
      _setLoading(false);
      print('❌ Error loading services from API: $e');
      
      // Fallback to sample data
      await _loadSampleData();
    }
  }

  // Load providers from API
  Future<void> _loadProvidersFromApi() async {
    try {
      final providers = await ServicesApiService.fetchProviders(
        location: _userLocation,
        page: 1,
        limit: 50,
      );
      
      _providers = providers;
      
      
    } catch (e) {
      print('❌ Error loading providers from API: $e');
      // Keep existing providers if API fails
    }
  }

  // Load provider services from API
  Future<void> _loadProviderServicesFromApi() async {
    try {
      final services = await ServicesApiService.fetchProviderServices();
      _providerServices = services;
      
    } catch (e) {
      print('❌ Error loading provider services from API: ${e.toString()}');
      _providerServices = [];
    }
    notifyListeners();
  }

  // Load services for a specific category
  Future<void> loadServicesForCategory(String category) async {
    if (category == 'All') {
      await _loadServicesFromApi();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      // Use the dedicated category API
      final services = await ServicesApiService.fetchServicesByCategory(category);
      
      _allServices = services;
      
      // Set default selected service if available
      if (_allServices.isNotEmpty) {
        _selectedService = _allServices.first.name;
        await _loadServiceDetails(_allServices.first.id);
      }
      
      _setLoading(false);
      print('✅ Loaded ${services.length} services for category: $category');
      
    } catch (e) {
      _setError('Failed to load services for category $category: $e');
      _setLoading(false);
      print('❌ Error loading services for category $category: $e');
    }
  }

  // Load service details using comparison API
  Future<void> loadServiceDetails(String serviceName) async {
    final service = _allServices.firstWhere(
      (s) => s.name == serviceName,
      orElse: () => throw Exception('Service not found'),
    );
    
    await _loadServiceDetails(service.id);
  }

  Future<void> _loadServiceDetails(String serviceId) async {
    try {
      final comparisonData = await ServicesApiService.fetchServiceComparison(
        serviceId: serviceId,
        nearest: _nearest,
        lowCost: _lowCost,
        topRated: _topRated,
        insurance: _insurance,
        availableToday: _availableToday,
        location: _userLocation,
      );

      if (comparisonData.isNotEmpty && comparisonData['service'] != null) {
        _selectedServiceDetails = MedicalService.fromJson(comparisonData['service']);
        
        // Update providers from comparison data if available
        if (comparisonData['providers'] != null && comparisonData['providers'] is List) {
          final providersData = comparisonData['providers'] as List;
          _providers = providersData.map((json) => ServiceProvider.fromJson(json)).toList();
        }
        
        print('✅ Loaded service details for: ${_selectedServiceDetails?.name}');
      }
    } catch (e) {
      print('❌ Error loading service details: $e');
      // Fallback to local service data
      final service = _allServices.firstWhere(
        (s) => s.id == serviceId,
        orElse: () => throw Exception('Service not found'),
      );
      _selectedServiceDetails = service;
    }
  }

  // Update filters
  void updateFilters({
    bool? nearest,
    bool? lowCost,
    bool? topRated,
    bool? insurance,
    bool? availableToday,
    Map<String, double>? location,
  }) {
    if (nearest != null) _nearest = nearest;
    if (lowCost != null) _lowCost = lowCost;
    if (topRated != null) _topRated = topRated;
    if (insurance != null) _insurance = insurance;
    if (availableToday != null) _availableToday = availableToday;
    if (location != null) _userLocation = location;
    
      notifyListeners();
    
    // Reload service details with new filters if a service is selected
    if (_selectedServiceDetails != null) {
      _loadServiceDetails(_selectedServiceDetails!.id);
    }
  }

  // Get services for a specific category
  List<String> getServicesForCategory(String category) {
    if (category == 'All') {
      return _allServices.map((s) => s.name).toList();
    }
    return _allServices
        .where((service) => service.category == category)
        .map((s) => s.name)
        .toList();
  }

  // Set selected service category
  void setSelectedServiceCategory(String category) {
    _selectedServiceCategory = category;
    notifyListeners();
  }

  // Set selected service
  void setSelectedService(String service) {
    _selectedService = service;
    loadServiceDetails(service);
    notifyListeners();
  }

  // Toggle provider selection
  void toggleProviderSelection(ServiceProvider provider) {
    if (_selectedProviders.contains(provider)) {
      _selectedProviders.remove(provider);
    } else {
      if (_selectedProviders.length < 3) {
        _selectedProviders.add(provider);
      }
    }
    notifyListeners();
  }

  // Clear selected providers
  void clearSelectedProviders() {
    _selectedProviders.clear();
    notifyListeners();
  }

  // Fetch provider services for a specific provider
  Future<void> fetchProviderServicesByProvider(String providerId) async {
    try {
      final services = await ServicesApiService.fetchProviderServicesByProvider(providerId);
      _providerServicesByProvider = services;
      print('✅ Loaded ${services.length} provider services for provider $providerId');
    } catch (e) {
      print('❌ Error loading provider services for provider: $providerId: ${e.toString()}');
      _providerServicesByProvider = [];
    }
    notifyListeners();
  }

  // Fetch providers for a specific service
  Future<void> fetchProvidersByService(String serviceId) async {
    try {
      final providers = await ServicesApiService.fetchProvidersByService(serviceId);
      _providersByService = providers;
      print('✅ Loaded ${providers.length} providers for service $serviceId');
    } catch (e) {
      print('❌ Error loading providers for service: $serviceId: ${e.toString()}');
      _providersByService = [];
    }
    notifyListeners();
  }

  // Fetch available comparison filters
  Future<void> fetchAvailableFilters() async {
    try {
      final filters = await ServicesApiService.fetchAvailableComparisonFilters();
      _availableFilters = filters;
      print('✅ Loaded available comparison filters');
    } catch (e) {
      print('❌ Error loading available comparison filters: ${e.toString()}');
      _availableFilters = {};
    }
    notifyListeners();
  }

  // Fetch reviews for a provider
  Future<void> fetchProviderReviews(String providerId) async {
    try {
      final reviews = await ServicesApiService.fetchProviderReviews(providerId);
      _providerReviews = reviews;
      print('✅ Loaded ${reviews.length} reviews for provider $providerId');
    } catch (e) {
      print('❌ Error loading reviews for provider: $providerId: ${e.toString()}');
      _providerReviews = [];
    }
    notifyListeners();
  }

  // Fetch reviews for a service
  Future<void> fetchServiceReviews(String serviceId) async {
    try {
      final reviews = await ServicesApiService.fetchServiceReviews(serviceId);
      _serviceReviews = reviews;
      print('✅ Loaded ${reviews.length} reviews for service $serviceId');
    } catch (e) {
      print('❌ Error loading reviews for service: $serviceId: ${e.toString()}');
      _serviceReviews = [];
    }
    notifyListeners();
  }

  // Loading state management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Fallback to sample data
  Future<void> _loadSampleData() async {
    print('🔄 Loading sample data as fallback...');
    
    _allCategories = [
      'consultation',
      'emergency', 
      'imaging',
      'laboratory_tests',
      'procedure',
      'screening',
      'therapy',
      'vaccination'
    ];

    _allServices = [
      MedicalService(
        id: '1',
        name: 'General Consultation',
        description: 'Basic health consultation with a doctor',
        category: 'consultation',
        price: 50.0,
        duration: 30,
        provider: 'Medico General Hospital',
        location: 'Downtown Medical Center',
        rating: 4.5,
        reviewCount: 120,
      ),
      MedicalService(
        id: '2', 
        name: 'Blood Test',
        description: 'Comprehensive blood analysis',
        category: 'laboratory_tests',
        price: 75.0,
        duration: 15,
        provider: 'Medico Laboratory',
        location: 'Medical District',
        rating: 4.8,
        reviewCount: 89,
      ),
    ];

    if (_allServices.isNotEmpty) {
      _selectedService = _allServices.first.name;
      _selectedServiceDetails = _allServices.first;
    }
    
    _setLoading(false);
  }

  // Provider selection methods
  void addProvider(ServiceProvider provider) {
    if (_selectedProviders.length < 3 && !_selectedProviders.contains(provider)) {
      _selectedProviders.add(provider);
      notifyListeners();
      print('✅ Added provider: ${provider.name}');
    }
  }

  void removeProvider(ServiceProvider provider) {
    if (_selectedProviders.contains(provider)) {
      _selectedProviders.remove(provider);
      notifyListeners();
      print('✅ Removed provider: ${provider.name}');
    }
  }

  void clearAllProviders() {
    _selectedProviders.clear();
    notifyListeners();
    print('✅ Cleared all selected providers');
  }

  // Get providers that offer the selected service
  List<ServiceProvider> getProvidersForSelectedService() {
    if (_selectedService.isEmpty) return [];
    
    // For now, return all providers since we don't have service-specific provider mapping
    // In a real implementation, you would filter providers based on the selected service
    return _providers;
  }
} 