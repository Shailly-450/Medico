import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medico/models/medical_service.dart';
import 'package:medico/models/service_provider.dart';
import 'package:medico/core/config.dart';
import 'package:medico/core/services/auth_service.dart';

// Model for ProviderService API response
class ProviderService {
  final String id;
  final Map<String, dynamic> availability;
  final Map<String, dynamic> doctor;
  final Map<String, dynamic> providerId;
  final Map<String, dynamic>? serviceId;

  ProviderService({
    required this.id,
    required this.availability,
    required this.doctor,
    required this.providerId,
    this.serviceId,
  });

  factory ProviderService.fromJson(Map<String, dynamic> json) {
    return ProviderService(
      id: json['_id'] ?? '',
      availability: json['availability'] ?? {},
      doctor: json['doctor'] ?? {},
      providerId: json['providerId'] ?? {},
      serviceId: json['serviceId'],
    );
  }
}

class ServicesApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  // Get authentication headers
  static Map<String, String> get _authHeaders {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = AuthService.accessToken;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Get all services from the API
  static Future<List<MedicalService>> fetchServices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          final services = (data['data'] as List)
              .map((json) => MedicalService.fromJson(json))
              .toList();
          return services;
        }
      }
      
      // Fallback to mock data if API fails
      return _getMockServices();
    } catch (e) {
      // Fallback to mock data if API fails
      return _getMockServices();
    }
  }

  // Get available services for order creation (matches backend structure)
  static Future<List<MedicalService>> fetchAvailableServices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          final services = (data['data'] as List)
              .where((json) => json['isActive'] == true) // Only active services
              .map((json) => MedicalService.fromJson(json))
              .toList();
          return services;
        }
      }
      
      // Fallback to mock data if API fails
      return _getMockAvailableServices();
    } catch (e) {
      // Fallback to mock data if API fails
      return _getMockAvailableServices();
    }
  }

  // Mock services data
  static List<MedicalService> _getMockServices() {
    return [
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
      MedicalService(
        id: '3',
        name: 'X-Ray Imaging',
        description: 'Digital X-ray imaging for bone and chest examination',
        category: 'imaging',
        price: 80.0,
        duration: 30,
        provider: 'Medico Imaging Center',
        location: 'Medical District',
        rating: 4.5,
        reviewCount: 445,
      ),
      MedicalService(
        id: '4',
        name: 'MRI Scan',
        description: 'Magnetic Resonance Imaging for detailed body examination',
        category: 'imaging',
        price: 350.0,
        duration: 45,
        provider: 'Medico Imaging Center',
        location: 'Medical District',
        rating: 4.7,
        reviewCount: 223,
      ),
      MedicalService(
        id: '5',
        name: 'Cardiology Consultation',
        description: 'Specialized heart health consultation',
        category: 'consultation',
        price: 120.0,
        duration: 45,
        provider: 'Medico Cardiology',
        location: 'Heart Center',
        rating: 4.9,
        reviewCount: 156,
      ),
      MedicalService(
        id: '6',
        name: 'Dental Checkup',
        description: 'Comprehensive dental examination and cleaning',
        category: 'consultation',
        price: 60.0,
        duration: 30,
        provider: 'Medico Dental Clinic',
        location: 'Dental Center',
        rating: 4.6,
        reviewCount: 234,
      ),
      MedicalService(
        id: '7',
        name: 'Vaccination',
        description: 'Routine vaccination services',
        category: 'vaccination',
        price: 25.0,
        duration: 15,
        provider: 'Medico Vaccination Center',
        location: 'Preventive Care Clinic',
        rating: 4.4,
        reviewCount: 567,
      ),
      MedicalService(
        id: '8',
        name: 'Physical Therapy',
        description: 'Rehabilitation and physical therapy sessions',
        category: 'therapy',
        price: 90.0,
        duration: 60,
        provider: 'Medico Rehabilitation Center',
        location: 'Therapy Center',
        rating: 4.7,
        reviewCount: 189,
      ),
    ];
  }

  // Mock providers data
  static List<ServiceProvider> _getMockProviders() {
    return [
      ServiceProvider(
        id: '1',
        name: 'Medico General Hospital',
        type: 'hospital',
        description: 'Comprehensive medical services and emergency care',
        imageUrl: 'https://example.com/hospital1.jpg',
        rating: 4.5,
        reviewCount: 120,
        isOpen: true,
        workingHours: '24/7',
        facilities: ['Emergency Room', 'ICU', 'Surgery', 'Laboratory'],
        specialties: ['General Medicine', 'Emergency Care', 'Surgery'],
        accreditation: ['JCI', 'ISO 9001'],
        averagePrice: 150.0,
        totalServices: 25,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
        location: ProviderLocation(
          address: '123 Medical Center Dr',
          coordinates: [34.0522, -118.2437],
          area: 'Downtown',
          city: 'Los Angeles',
          state: 'CA',
          pincode: '90210',
          distance: 0.0,
        ),
        contact: ProviderContact(
          phone: '+1-555-0123',
          email: 'info@medicogeneral.com',
          website: 'https://medicogeneral.com',
          emergencyContact: '+1-555-9111',
        ),
      ),
      ServiceProvider(
        id: '2',
        name: 'Medico Laboratory',
        type: 'laboratory',
        description: 'Advanced diagnostic and laboratory testing services',
        imageUrl: 'https://example.com/lab1.jpg',
        rating: 4.8,
        reviewCount: 89,
        isOpen: true,
        workingHours: 'Mon-Fri 8AM-6PM, Sat 9AM-2PM',
        facilities: ['Blood Testing', 'Urine Analysis', 'Microbiology'],
        specialties: ['Clinical Chemistry', 'Hematology', 'Immunology'],
        accreditation: ['CLIA', 'CAP'],
        averagePrice: 75.0,
        totalServices: 15,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
        updatedAt: DateTime.now(),
        location: ProviderLocation(
          address: '456 Medical District Ave',
          coordinates: [34.0622, -118.2537],
          area: 'Medical District',
          city: 'Los Angeles',
          state: 'CA',
          pincode: '90211',
          distance: 0.0,
        ),
        contact: ProviderContact(
          phone: '+1-555-0456',
          email: 'info@medicolab.com',
          website: 'https://medicolab.com',
          emergencyContact: '+1-555-9112',
        ),
      ),
      ServiceProvider(
        id: '3',
        name: 'Medico Imaging Center',
        type: 'imaging',
        description: 'Advanced medical imaging and diagnostic services',
        imageUrl: 'https://example.com/imaging1.jpg',
        rating: 4.7,
        reviewCount: 223,
        isOpen: true,
        workingHours: 'Mon-Fri 7AM-7PM, Sat 8AM-4PM',
        facilities: ['MRI', 'CT Scan', 'X-Ray', 'Ultrasound'],
        specialties: ['Radiology', 'Nuclear Medicine'],
        accreditation: ['ACR', 'Joint Commission'],
        averagePrice: 250.0,
        totalServices: 12,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 250)),
        updatedAt: DateTime.now(),
        location: ProviderLocation(
          address: '789 Imaging Blvd',
          coordinates: [34.0722, -118.2637],
          area: 'Medical District',
          city: 'Los Angeles',
          state: 'CA',
          pincode: '90212',
          distance: 0.0,
        ),
        contact: ProviderContact(
          phone: '+1-555-0789',
          email: 'info@medicoimaging.com',
          website: 'https://medicoimaging.com',
          emergencyContact: '+1-555-9113',
        ),
      ),
      ServiceProvider(
        id: '4',
        name: 'Medico Cardiology',
        type: 'specialty',
        description: 'Specialized cardiac care and heart health services',
        imageUrl: 'https://example.com/cardio1.jpg',
        rating: 4.9,
        reviewCount: 156,
        isOpen: true,
        workingHours: 'Mon-Fri 8AM-5PM',
        facilities: ['EKG', 'Echocardiogram', 'Stress Test'],
        specialties: ['Cardiology', 'Interventional Cardiology'],
        accreditation: ['ACC', 'Joint Commission'],
        averagePrice: 200.0,
        totalServices: 8,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        updatedAt: DateTime.now(),
        location: ProviderLocation(
          address: '321 Heart Center Way',
          coordinates: [34.0822, -118.2737],
          area: 'Heart Center',
          city: 'Los Angeles',
          state: 'CA',
          pincode: '90213',
          distance: 0.0,
        ),
        contact: ProviderContact(
          phone: '+1-555-0321',
          email: 'info@medicocardio.com',
          website: 'https://medicocardio.com',
          emergencyContact: '+1-555-9114',
        ),
      ),
      ServiceProvider(
        id: '5',
        name: 'Medico Dental Clinic',
        type: 'dental',
        description: 'Comprehensive dental care and oral health services',
        imageUrl: 'https://example.com/dental1.jpg',
        rating: 4.6,
        reviewCount: 234,
        isOpen: true,
        workingHours: 'Mon-Fri 9AM-6PM, Sat 9AM-3PM',
        facilities: ['General Dentistry', 'Orthodontics', 'Oral Surgery'],
        specialties: ['General Dentistry', 'Orthodontics', 'Periodontics'],
        accreditation: ['ADA', 'State Board'],
        averagePrice: 120.0,
        totalServices: 18,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        updatedAt: DateTime.now(),
        location: ProviderLocation(
          address: '654 Dental Plaza',
          coordinates: [34.0922, -118.2837],
          area: 'Dental Center',
          city: 'Los Angeles',
          state: 'CA',
          pincode: '90214',
          distance: 0.0,
        ),
        contact: ProviderContact(
          phone: '+1-555-0654',
          email: 'info@medicodental.com',
          website: 'https://medicodental.com',
          emergencyContact: '+1-555-9115',
        ),
      ),
    ];
  }

  // Get all providers from the API
  static Future<List<ServiceProvider>> fetchProviders({
    Map<String, double>? location,
    String? type,
    String? city,
    String? state,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (location != null) {
        queryParams['location'] = jsonEncode(location);
      }
      if (type != null) {
        queryParams['type'] = type;
      }
      if (city != null) {
        queryParams['city'] = city;
      }
      if (state != null) {
        queryParams['state'] = state;
      }
      if (page != null) {
        queryParams['page'] = page.toString();
      }
      if (limit != null) {
        queryParams['limit'] = limit.toString();
      }

      final uri = Uri.parse('$baseUrl/providers').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http.get(
        uri,
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          final providers = (data['data'] as List)
              .map((json) => ServiceProvider.fromJson(json))
              .toList();
          return providers;
        }
      }
      
      // Fallback to mock data if API fails
      return _getMockProviders();
    } catch (e) {
      // Fallback to mock data if API fails
      return _getMockProviders();
    }
  }

  // Get provider by ID
  static Future<ServiceProvider?> fetchProviderById(String providerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/providers/$providerId'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return ServiceProvider.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching provider by ID: $e');
      return null;
    }
  }

  // Get provider types from the API
  static Future<List<String>> fetchProviderTypes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/providers/types'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List).map((e) => e.toString()).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching provider types: $e');
      return [];
    }
  }

  // Get service categories from the dedicated categories API
  static Future<List<String>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services/categories'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          final categories = (data['data'] as List)
              .map((category) => category.toString())
              .toList();
          return categories;
        }
      }
      
      // Fallback to mock data if API fails
      return _getMockCategories();
    } catch (e) {
      // Fallback to mock data if API fails
      return _getMockCategories();
    }
  }

  // Mock categories data
  static List<String> _getMockCategories() {
    return [
      'consultation',
      'emergency',
      'imaging',
      'laboratory_tests',
      'procedure',
      'screening',
      'therapy',
      'vaccination'
    ];
  }

  // Get services by specific category using dedicated API
  static Future<List<MedicalService>> fetchServicesByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services/category/$category'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List)
              .map((json) => MedicalService.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching services by category: $e');
      return [];
    }
  }

  // Get service comparison details with filters
  static Future<Map<String, dynamic>> fetchServiceComparison({
    required String serviceId,
    bool nearest = false,
    bool lowCost = false,
    bool topRated = false,
    bool insurance = false,
    bool availableToday = false,
    Map<String, double>? location,
  }) async {
    try {
      final queryParams = <String, String>{
        if (nearest) 'nearest': 'true',
        if (lowCost) 'lowCost': 'true',
        if (topRated) 'topRated': 'true',
        if (insurance) 'insurance': 'true',
        if (availableToday) 'availableToday': 'true',
      };

      if (location != null) {
        queryParams['location'] = jsonEncode(location);
      }

      final uri = Uri.parse('$baseUrl/comparison/service/$serviceId').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is Map) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      return {};
    } catch (e) {
      print('Error fetching service comparison: $e');
      return {};
    }
  }

  // Get service by ID
  static Future<MedicalService?> fetchServiceById(String serviceId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services/$serviceId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return MedicalService.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching service by ID: $e');
      return null;
    }
  }

  // Get services by subcategory
  static Future<List<MedicalService>> fetchServicesBySubcategory(String subcategory) async {
    try {
      final allServices = await fetchServices();
      return allServices.where((service) => 
        service.toJson().containsKey('subcategory') && 
        service.toJson()['subcategory'] == subcategory
      ).toList();
    } catch (e) {
      print('Error fetching services by subcategory: $e');
      return [];
    }
  }

  // Get available subcategories
  static Future<List<String>> fetchSubcategories() async {
    try {
      final services = await fetchServices();
      final subcategories = services
          .where((service) => service.toJson().containsKey('subcategory'))
          .map((service) => service.toJson()['subcategory'] as String)
          .toSet()
          .toList();
      return subcategories;
    } catch (e) {
      print('Error fetching subcategories: $e');
      return [];
    }
  }

  // Search services by name or description
  static Future<List<MedicalService>> searchServices(String query) async {
    try {
      final allServices = await fetchServices();
      return allServices.where((service) =>
        service.name.toLowerCase().contains(query.toLowerCase()) ||
        service.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      print('Error searching services: $e');
      return [];
    }
  }

  // Get services with filters
  static Future<List<MedicalService>> fetchServicesWithFilters({
    String? category,
    String? subcategory,
    double? minPrice,
    double? maxPrice,
    bool? isAvailable,
    bool? hasInsurance,
  }) async {
    try {
      List<MedicalService> filteredServices;
      
      // If category is specified, use the dedicated category API
      if (category != null) {
        filteredServices = await fetchServicesByCategory(category);
      } else {
        // Otherwise, get all services and filter
        filteredServices = await fetchServices();
      }

      // Apply additional filters
      if (subcategory != null) {
        filteredServices = filteredServices.where((service) => service.subcategory == subcategory).toList();
      }

      if (minPrice != null) {
        filteredServices = filteredServices.where((service) => service.price >= minPrice).toList();
      }

      if (maxPrice != null) {
        filteredServices = filteredServices.where((service) => service.price <= maxPrice).toList();
      }

      if (isAvailable != null) {
        filteredServices = filteredServices.where((service) => service.isAvailable == isAvailable).toList();
      }

      if (hasInsurance != null) {
        filteredServices = filteredServices.where((service) => service.insuranceCoverage == hasInsurance).toList();
      }

      return filteredServices;
    } catch (e) {
      print('Error fetching services with filters: $e');
      return [];
    }
  }

  // Fetch all provider services from the API
  static Future<List<ProviderService>> fetchProviderServices() async {
    try {
      final uri = Uri.parse('$baseUrl/provider-services');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List)
              .map((json) => ProviderService.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching provider services: $e');
      return [];
    }
  }

  // Fetch provider services by providerId from the API
  static Future<List<ProviderService>> fetchProviderServicesByProvider(String providerId) async {
    try {
      final uri = Uri.parse('$baseUrl/provider-services/provider/$providerId');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List)
              .map((json) => ProviderService.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching provider services by provider: $e');
      return [];
    }
  }

  // Fetch providers by serviceId from the API
  static Future<List<ProviderService>> fetchProvidersByService(String serviceId) async {
    try {
      final uri = Uri.parse('$baseUrl/provider-services/service/$serviceId');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List)
              .map((json) => ProviderService.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching providers by service: $e');
      return [];
    }
  }

  // Fetch available comparison filters from the API
  static Future<Map<String, dynamic>> fetchAvailableComparisonFilters() async {
    try {
      final uri = Uri.parse('$baseUrl/comparison/filters/available');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is Map<String, dynamic>) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      return {};
    } catch (e) {
      print('Error fetching available comparison filters: $e');
      return {};
    }
  }

  // Fetch reviews for a provider from the API
  static Future<List<Map<String, dynamic>>> fetchProviderReviews(String providerId) async {
    try {
      final uri = Uri.parse('$baseUrl/reviews/provider/$providerId');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching provider reviews: $e');
      return [];
    }
  }

  // Fetch reviews for a service from the API
  static Future<List<Map<String, dynamic>>> fetchServiceReviews(String serviceId) async {
    try {
      final uri = Uri.parse('$baseUrl/reviews/service/$serviceId');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching service reviews: $e');
      return [];
    }
  }

  static Future<List<MedicalService>> fetchServicesForProvider(String providerId) async {
    try {
      // Use the main services endpoint as suggested by backend team
      final response = await http.get(
        Uri.parse('$baseUrl/services'),
        headers: _authHeaders,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          final allServices = (data['data'] as List)
              .map((json) => MedicalService.fromJson(json))
              .toList();
          
          // For now, return all services since we don't have provider-specific filtering
          return allServices;
        }
      }
      
      // Fallback to mock services if API fails
      return _getMockServicesForProvider(providerId);
    } catch (e) {
      // Fallback to mock services if API fails
      return _getMockServicesForProvider(providerId);
    }
  }

  // Mock services for specific providers
  static List<MedicalService> _getMockServicesForProvider(String providerId) {
    switch (providerId) {
      case '68871dfe0941b14a43eb8bf0': // Apollo Hospital
        return [
          MedicalService(
            id: '1',
            name: 'Blood Pressure Monitoring',
            description: 'Regular blood pressure monitoring service',
            category: 'monitoring',
            price: 35.0,
            duration: 15,
            provider: 'Apollo Hospital',
            location: 'JP Nagar, Bangalore',
            rating: 4.8,
            reviewCount: 1247,
          ),
          MedicalService(
            id: '2',
            name: 'General Consultation',
            description: 'Basic health consultation with a doctor',
            category: 'consultation',
            price: 50.0,
            duration: 30,
            provider: 'Apollo Hospital',
            location: 'JP Nagar, Bangalore',
            rating: 4.8,
            reviewCount: 1247,
          ),
          MedicalService(
            id: '3',
            name: 'Emergency Care',
            description: '24/7 emergency medical services',
            category: 'emergency',
            price: 200.0,
            duration: 60,
            provider: 'Apollo Hospital',
            location: 'JP Nagar, Bangalore',
            rating: 4.8,
            reviewCount: 1247,
          ),
        ];
      case '68871dff0941b14a43eb8bf1': // Fortis Hospital
        return [
          MedicalService(
            id: '4',
            name: 'Blood Pressure Monitoring',
            description: 'Regular blood pressure monitoring service',
            category: 'monitoring',
            price: 35.0,
            duration: 15,
            provider: 'Fortis Hospital',
            location: 'Medical District',
            rating: 4.8,
            reviewCount: 89,
          ),
          MedicalService(
            id: '5',
            name: 'General Consultation',
            description: 'Basic health consultation with a doctor',
            category: 'consultation',
            price: 50.0,
            duration: 30,
            provider: 'Fortis Hospital',
            location: 'Medical District',
            rating: 4.8,
            reviewCount: 89,
          ),
          MedicalService(
            id: '6',
            name: 'Blood Test',
            description: 'Comprehensive blood analysis',
            category: 'laboratory_tests',
            price: 75.0,
            duration: 15,
            provider: 'Fortis Hospital',
            location: 'Medical District',
            rating: 4.8,
            reviewCount: 89,
          ),
        ];
      case '1': // Medico General Hospital (fallback)
        return [
          MedicalService(
            id: '1',
            name: 'Blood Pressure Monitoring',
            description: 'Regular blood pressure monitoring service',
            category: 'monitoring',
            price: 35.0,
            duration: 15,
            provider: 'Medico General Hospital',
            location: 'Downtown Medical Center',
            rating: 4.5,
            reviewCount: 120,
          ),
          MedicalService(
            id: '2',
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
            id: '3',
            name: 'Emergency Care',
            description: '24/7 emergency medical services',
            category: 'emergency',
            price: 200.0,
            duration: 60,
            provider: 'Medico General Hospital',
            location: 'Downtown Medical Center',
            rating: 4.8,
            reviewCount: 89,
          ),
        ];
      case '68871dff0941b14a43eb8bf2': // Manipal Hospital
        return [
          MedicalService(
            id: '7',
            name: 'Blood Pressure Monitoring',
            description: 'Regular blood pressure monitoring service',
            category: 'monitoring',
            price: 35.0,
            duration: 15,
            provider: 'Manipal Hospital',
            location: 'Medical District',
            rating: 4.8,
            reviewCount: 89,
          ),
          MedicalService(
            id: '8',
            name: 'General Consultation',
            description: 'Basic health consultation with a doctor',
            category: 'consultation',
            price: 50.0,
            duration: 30,
            provider: 'Manipal Hospital',
            location: 'Medical District',
            rating: 4.8,
            reviewCount: 89,
          ),
          MedicalService(
            id: '9',
            name: 'Blood Test',
            description: 'Comprehensive blood analysis',
            category: 'laboratory_tests',
            price: 75.0,
            duration: 15,
            provider: 'Manipal Hospital',
            location: 'Medical District',
            rating: 4.8,
            reviewCount: 89,
          ),
        ];
      case '2': // Medico Laboratory (fallback)
      case '3': // Medico Imaging Center
        return [
          MedicalService(
            id: '7',
            name: 'Blood Pressure Monitoring',
            description: 'Regular blood pressure monitoring service',
            category: 'monitoring',
            price: 35.0,
            duration: 15,
            provider: 'Medico Imaging Center',
            location: 'Medical District',
            rating: 4.5,
            reviewCount: 445,
          ),
          MedicalService(
            id: '8',
            name: 'X-Ray Imaging',
            description: 'Digital X-ray imaging for bone and chest examination',
            category: 'imaging',
            price: 80.0,
            duration: 30,
            provider: 'Medico Imaging Center',
            location: 'Medical District',
            rating: 4.5,
            reviewCount: 445,
          ),
          MedicalService(
            id: '9',
            name: 'MRI Scan',
            description: 'Magnetic Resonance Imaging for detailed body examination',
            category: 'imaging',
            price: 350.0,
            duration: 45,
            provider: 'Medico Imaging Center',
            location: 'Medical District',
            rating: 4.7,
            reviewCount: 223,
          ),
          MedicalService(
            id: '10',
            name: 'CT Scan',
            description: 'Computed Tomography scan for detailed imaging',
            category: 'imaging',
            price: 280.0,
            duration: 30,
            provider: 'Medico Imaging Center',
            location: 'Medical District',
            rating: 4.6,
            reviewCount: 189,
          ),
        ];
      case '4': // Medico Cardiology
        return [
          MedicalService(
            id: '11',
            name: 'Blood Pressure Monitoring',
            description: 'Regular blood pressure monitoring service',
            category: 'monitoring',
            price: 35.0,
            duration: 15,
            provider: 'Medico Cardiology',
            location: 'Heart Center',
            rating: 4.9,
            reviewCount: 156,
          ),
          MedicalService(
            id: '12',
            name: 'Cardiology Consultation',
            description: 'Specialized heart health consultation',
            category: 'consultation',
            price: 120.0,
            duration: 45,
            provider: 'Medico Cardiology',
            location: 'Heart Center',
            rating: 4.9,
            reviewCount: 156,
          ),
          MedicalService(
            id: '13',
            name: 'EKG Test',
            description: 'Electrocardiogram for heart rhythm analysis',
            category: 'laboratory_tests',
            price: 85.0,
            duration: 20,
            provider: 'Medico Cardiology',
            location: 'Heart Center',
            rating: 4.8,
            reviewCount: 123,
          ),
          MedicalService(
            id: '14',
            name: 'Echocardiogram',
            description: 'Heart ultrasound for structural analysis',
            category: 'imaging',
            price: 180.0,
            duration: 40,
            provider: 'Medico Cardiology',
            location: 'Heart Center',
            rating: 4.9,
            reviewCount: 98,
          ),
        ];
      case '5': // Medico Dental Clinic
        return [
          MedicalService(
            id: '15',
            name: 'Blood Pressure Monitoring',
            description: 'Regular blood pressure monitoring service',
            category: 'monitoring',
            price: 35.0,
            duration: 15,
            provider: 'Medico Dental Clinic',
            location: 'Dental Center',
            rating: 4.6,
            reviewCount: 234,
          ),
          MedicalService(
            id: '16',
            name: 'Dental Checkup',
            description: 'Comprehensive dental examination and cleaning',
            category: 'consultation',
            price: 60.0,
            duration: 30,
            provider: 'Medico Dental Clinic',
            location: 'Dental Center',
            rating: 4.6,
            reviewCount: 234,
          ),
          MedicalService(
            id: '17',
            name: 'Cavity Filling',
            description: 'Dental cavity filling and restoration',
            category: 'dental',
            price: 120.0,
            duration: 45,
            provider: 'Medico Dental Clinic',
            location: 'Dental Center',
            rating: 4.5,
            reviewCount: 189,
          ),
          MedicalService(
            id: '18',
            name: 'Root Canal',
            description: 'Root canal treatment for severe tooth decay',
            category: 'dental',
            price: 350.0,
            duration: 90,
            provider: 'Medico Dental Clinic',
            location: 'Dental Center',
            rating: 4.8,
            reviewCount: 145,
          ),
        ];
      default:
        // Return general services for unknown providers
        return _getMockServices();
    }
  }

  // Mock available services data (matches backend structure)
  static List<MedicalService> _getMockAvailableServices() {
    return [
      MedicalService(
        id: '68871dff0941b14a43eb8c10',
        name: 'Blood Test',
        description: 'Comprehensive blood analysis and diagnostic tests',
        category: 'Laboratory',
        price: 500.0,
        duration: 20,
        includedTests: ['CBC', 'Blood Sugar', 'Cholesterol', 'Liver Function'],
        requirements: ['Fasting for 8-12 hours', 'Early morning appointment'],
        provider: 'Medico General Hospital',
        location: 'Laboratory Center',
        rating: 4.7,
        reviewCount: 156,
        isActive: true,
      ),
      MedicalService(
        id: '68871dff0941b14a43eb8c0d',
        name: 'CT Scan',
        description: 'Computed Tomography scan for detailed cross-sectional images',
        category: 'Imaging',
        price: 2500.0,
        duration: 30,
        includedTests: ['CT Report', 'Radiologist Consultation'],
        requirements: ['Fasting for 4-6 hours', 'Remove metal objects'],
        provider: 'Medico Imaging Center',
        location: 'Imaging Center',
        rating: 4.8,
        reviewCount: 89,
        isActive: true,
      ),
      MedicalService(
        id: '68871dff0941b14a43eb8c0e',
        name: 'MRI Scan',
        description: 'Magnetic Resonance Imaging for detailed soft tissue analysis',
        category: 'Imaging',
        price: 3500.0,
        duration: 45,
        includedTests: ['MRI Report', 'Radiologist Consultation'],
        requirements: ['Fasting for 6 hours', 'Remove all metal objects'],
        provider: 'Medico Imaging Center',
        location: 'Imaging Center',
        rating: 4.9,
        reviewCount: 67,
        isActive: true,
      ),
      MedicalService(
        id: '68871dff0941b14a43eb8c0f',
        name: 'General Consultation',
        description: 'Basic health consultation with a doctor',
        category: 'Consultation',
        price: 200.0,
        duration: 30,
        includedTests: ['Physical Examination', 'Health Assessment'],
        requirements: ['Bring previous medical records if any'],
        provider: 'Medico General Hospital',
        location: 'Consultation Center',
        rating: 4.6,
        reviewCount: 234,
        isActive: true,
      ),
      MedicalService(
        id: '68871dff0941b14a43eb8c11',
        name: 'Cardiology Consultation',
        description: 'Specialized heart health consultation',
        category: 'Cardiology',
        price: 400.0,
        duration: 45,
        includedTests: ['Heart Assessment', 'ECG if needed'],
        requirements: ['Fasting for 4 hours', 'Bring previous heart reports'],
        provider: 'Medico Cardiology',
        location: 'Heart Center',
        rating: 4.9,
        reviewCount: 156,
        isActive: true,
      ),
    ];
  }
} 