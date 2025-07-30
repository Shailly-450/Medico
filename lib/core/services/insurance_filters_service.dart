import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'auth_service.dart';

class InsuranceFiltersService {
  static const String baseUrl = AppConfig.apiBaseUrl;
  static const Duration timeout = Duration(seconds: 10);

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${AuthService.accessToken}',
  };

  // Get available insurance filters for comparison
  static Future<Map<String, dynamic>> getInsuranceFilters() async {
    try {
      final uri = Uri.parse('$baseUrl/comparison/filters');
      final response = await http.get(
        uri,
        headers: _headers,
      ).timeout(timeout);

      print('Insurance Filters API Response [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is Map<String, dynamic>) {
          return data['data'] as Map<String, dynamic>;
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required');
      } else {
        throw Exception('Failed to fetch insurance filters: ${response.statusCode}');
      }
      
      return {};
    } catch (e) {
      print('Error fetching insurance filters: $e');
      return _getDefaultFilters();
    }
  }

  // Get insurance providers list
  static Future<List<String>> getInsuranceProviders() async {
    try {
      final filters = await getInsuranceFilters();
      final insuranceList = filters['insurance'] as List?;
      
      if (insuranceList != null) {
        return insuranceList.cast<String>();
      }
      
      return _getDefaultInsuranceProviders();
    } catch (e) {
      print('Error fetching insurance providers: $e');
      return _getDefaultInsuranceProviders();
    }
  }

  // Get price ranges for insurance comparison
  static Future<List<Map<String, dynamic>>> getPriceRanges() async {
    try {
      final filters = await getInsuranceFilters();
      final priceRanges = filters['priceRanges'] as List?;
      
      if (priceRanges != null) {
        return priceRanges.cast<Map<String, dynamic>>();
      }
      
      return _getDefaultPriceRanges();
    } catch (e) {
      print('Error fetching price ranges: $e');
      return _getDefaultPriceRanges();
    }
  }

  // Get categories for insurance comparison
  static Future<List<String>> getCategories() async {
    try {
      final filters = await getInsuranceFilters();
      final categories = filters['categories'] as List?;
      
      if (categories != null) {
        return categories.cast<String>();
      }
      
      return _getDefaultCategories();
    } catch (e) {
      print('Error fetching categories: $e');
      return _getDefaultCategories();
    }
  }

  // Get accreditations for insurance comparison
  static Future<List<String>> getAccreditations() async {
    try {
      final filters = await getInsuranceFilters();
      final accreditations = filters['accreditations'] as List?;
      
      if (accreditations != null) {
        return accreditations.cast<String>();
      }
      
      return _getDefaultAccreditations();
    } catch (e) {
      print('Error fetching accreditations: $e');
      return _getDefaultAccreditations();
    }
  }

  // Get provider types for insurance comparison
  static Future<List<String>> getProviderTypes() async {
    try {
      final filters = await getInsuranceFilters();
      final providerTypes = filters['providerTypes'] as List?;
      
      if (providerTypes != null) {
        return providerTypes.cast<String>();
      }
      
      return _getDefaultProviderTypes();
    } catch (e) {
      print('Error fetching provider types: $e');
      return _getDefaultProviderTypes();
    }
  }

  // Default fallback data
  static Map<String, dynamic> _getDefaultFilters() {
    return {
      'categories': _getDefaultCategories(),
      'accreditations': _getDefaultAccreditations(),
      'providerTypes': _getDefaultProviderTypes(),
      'insurance': _getDefaultInsuranceProviders(),
      'priceRanges': _getDefaultPriceRanges(),
    };
  }

  static List<String> _getDefaultCategories() {
    return [
      'Cardiology',
      'Dental',
      'General',
      'Orthopedics',
      'Pediatrics',
      'Neurology',
      'Oncology',
      'Dermatology',
    ];
  }

  static List<String> _getDefaultAccreditations() {
    return [
      'JCI',
      'NABH',
      'ISO',
      'CAP',
      'AABB',
    ];
  }

  static List<String> _getDefaultProviderTypes() {
    return [
      'Hospital',
      'Clinic',
      'Diagnostic Center',
      'Specialty Center',
      'Medical Center',
    ];
  }

  static List<String> _getDefaultInsuranceProviders() {
    return [
      'Blue Cross',
      'Aetna',
      'Cigna',
      'UnitedHealth',
      'Humana',
      'Kaiser Permanente',
      'Anthem',
      'Molina Healthcare',
    ];
  }

  static List<Map<String, dynamic>> _getDefaultPriceRanges() {
    return [
      {'label': 'Under ₹1000', 'min': 0, 'max': 1000},
      {'label': '₹1000 - ₹5000', 'min': 1000, 'max': 5000},
      {'label': '₹5000 - ₹10000', 'min': 5000, 'max': 10000},
      {'label': 'Above ₹10000', 'min': 10000, 'max': null},
    ];
  }
} 