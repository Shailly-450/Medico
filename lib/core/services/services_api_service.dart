import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medico/models/medical_service.dart';
import 'package:medico/models/service_provider.dart';
import 'package:medico/core/config.dart';

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

  // Get all services from the API
  static Future<List<MedicalService>> fetchServices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services'),
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
      print('Error fetching services: $e');
      return [];
    }
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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List)
              .map((json) => ServiceProvider.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching providers: $e');
      return [];
    }
  }

  // Get provider by ID
  static Future<ServiceProvider?> fetchProviderById(String providerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/providers/$providerId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List)
              .map((category) => category.toString())
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
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
} 