import 'package:http/http.dart' as http;
import '../../models/hospital.dart';
import 'api_service.dart';

class HospitalService {
  // Use the public ApiService methods directly

  static Future<Map<String, dynamic>> getHospitals({
    int page = 1,
    int limit = 10,
    String? search,
    String? specialty,
    String? city,
    String? state,
    bool? emergencyServices,
    bool? verified,
    String? sortBy,
    String? sortOrder,
  }) async {
    return await ApiService.getHospitals(
      page: page,
      limit: limit,
      search: search,
      specialty: specialty,
      city: city,
      emergencyServices: emergencyServices,
      verified: verified,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  static Future<Map<String, dynamic>> getHospitalById(String hospitalId) async {
    return await ApiService.getHospitalById(hospitalId);
  }

  // Get doctors for a specific hospital
  static Future<Map<String, dynamic>> getHospitalDoctors(
    String hospitalId, {
    int page = 1,
    int limit = 20,
    String? specialty,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (specialty != null) queryParams['specialty'] = specialty;
      if (search != null) queryParams['search'] = search;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

      final queryString = Uri(queryParameters: queryParams).query;
      final endpoint = '/hospitals/$hospitalId/doctors${queryString.isNotEmpty ? '?$queryString' : ''}';
      
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}$endpoint'),
        headers: ApiService.defaultHeaders,
      );
      
      return ApiService.parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get hospital doctors: ${e.toString()}',
      };
    }
  }

  // Get services for a specific hospital
  static Future<Map<String, dynamic>> getHospitalServices(String hospitalId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/hospitals/$hospitalId/services'),
        headers: ApiService.defaultHeaders,
      );
      
      return ApiService.parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get hospital services: ${e.toString()}',
      };
    }
  }

  // Get reviews for a specific hospital
  static Future<Map<String, dynamic>> getHospitalReviews(
    String hospitalId, {
    int page = 1,
    int limit = 10,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      return await ApiService.getHospitalReviews(
        hospitalId,
        page: page,
        limit: limit,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get hospital reviews: ${e.toString()}',
      };
    }
  }

  // Add review to a hospital (requires authentication)
  static Future<Map<String, dynamic>> addHospitalReview(
    String hospitalId,
    Map<String, dynamic> reviewData,
  ) async {
    try {
      // No public method for adding review, so return error for now
      return {
        'success': false,
        'message': 'addHospitalReview not implemented with public ApiService method',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to add hospital review: ${e.toString()}',
      };
    }
  }

  // Update hospital review (requires authentication)
  static Future<Map<String, dynamic>> updateHospitalReview(
    String hospitalId,
    String reviewId,
    Map<String, dynamic> reviewData,
  ) async {
    try {
      // No public method for updating review, so return error for now
      return {
        'success': false,
        'message': 'updateHospitalReview not implemented with public ApiService method',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update hospital review: ${e.toString()}',
      };
    }
  }

  // Delete hospital review (requires authentication)
  static Future<Map<String, dynamic>> deleteHospitalReview(
    String hospitalId,
    String reviewId,
  ) async {
    try {
      // No public method for deleting review, so return error for now
      return {
        'success': false,
        'message': 'deleteHospitalReview not implemented with public ApiService method',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to delete hospital review: ${e.toString()}',
      };
    }
  }

  // Search nearby hospitals
  static Future<Map<String, dynamic>> searchNearbyHospitals({
    required double latitude,
    required double longitude,
    double maxDistance = 10000, // in meters
    int limit = 20,
  }) async {
    try {
      return await ApiService.searchNearbyHospitals(
        latitude: latitude,
        longitude: longitude,
        maxDistance: maxDistance,
        limit: limit,
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to search nearby hospitals: ${e.toString()}',
      };
    }
  }

  // Get general hospital statistics
  static Future<Map<String, dynamic>> getGeneralHospitalStats() async {
    try {
      return await ApiService.getGeneralHospitalStats();
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get hospital statistics: ${e.toString()}',
      };
    }
  }

  // Get statistics for a specific hospital
  static Future<Map<String, dynamic>> getHospitalStats(String hospitalId) async {
    try {
      return await ApiService.getHospitalStats(hospitalId);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get hospital statistics: ${e.toString()}',
      };
    }
  }

  // Convert backend hospital data to Flutter Hospital model
  static Hospital convertToHospitalModel(Map<String, dynamic> hospitalData) {
    return Hospital(
      id: hospitalData['_id'] ?? hospitalData['id'] ?? '',
      name: hospitalData['name'] ?? '',
      type: _determineHospitalType(hospitalData),
      location: _buildFullAddress(hospitalData),
      rating: (hospitalData['rating']?['average'] ?? 0.0).toDouble(),
      distance: 0.0, // Will be calculated based on user location
      availableDoctors: hospitalData['doctors']?.length ?? 0,
      isOpen: _isHospitalOpen(hospitalData),
      imageUrl: _getPrimaryImage(hospitalData),
      description: hospitalData['description'] ?? '',
      specialties: List<String>.from(hospitalData['specialties'] ?? []),
      contactInfo: {
        'phone': hospitalData['contact']?['phone'],
        'email': hospitalData['contact']?['email'],
        'website': hospitalData['contact']?['website'],
      },
      latitude: hospitalData['location']?['coordinates']?[1]?.toDouble(),
      longitude: hospitalData['location']?['coordinates']?[0]?.toDouble(),
      consultationFee: null, // Not available in backend model
      emergencyFee: null, // Not available in backend model
      costCategory: _determineCostCategory(hospitalData),
    );
  }

  // Helper methods for data conversion
  static String _buildFullAddress(Map<String, dynamic> hospitalData) {
    final address = hospitalData['address'];
    if (address == null) return '';
    
    final parts = <String>[];
    if (address['street'] != null) parts.add(address['street']);
    if (address['city'] != null) parts.add(address['city']);
    if (address['state'] != null) parts.add(address['state']);
    if (address['zipCode'] != null) parts.add(address['zipCode']);
    
    return parts.join(', ');
  }

  static bool _isHospitalOpen(Map<String, dynamic> hospitalData) {
    // This is a simplified check - in a real app, you'd check current time against operating hours
    return hospitalData['status'] == 'active';
  }

  static String? _getPrimaryImage(Map<String, dynamic> hospitalData) {
    final images = hospitalData['images'] as List<dynamic>?;
    if (images == null || images.isEmpty) return null;
    
    final primaryImage = images.firstWhere(
      (img) => img['isPrimary'] == true,
      orElse: () => images.first,
    );
    
    return primaryImage['url'];
  }

  static String _determineHospitalType(Map<String, dynamic> hospitalData) {
    // Determine hospital type based on specialties and services
    final specialties = List<String>.from(hospitalData['specialties'] ?? []);
    final services = List<Map<String, dynamic>>.from(hospitalData['services'] ?? []);
    final emergencyServices = hospitalData['emergencyServices'] ?? false;
    
    // Check if it's a cancer center
    if (specialties.contains('Oncology') || 
        services.any((service) => service['name'].toString().toLowerCase().contains('cancer'))) {
      return 'Cancer Center';
    }
    
    // Check if it's a specialty clinic
    if (specialties.length <= 3 && !emergencyServices) {
      return 'Specialty Clinic';
    }
    
    // Check if it's an academic medical center
    if (specialties.length >= 8 && hospitalData['verified'] == true) {
      return 'Academic Medical Center';
    }
    
    // Check if it's an emergency center
    if (emergencyServices && specialties.contains('Emergency Medicine')) {
      return 'Emergency Center';
    }
    
    // Default to general hospital
    return 'General Hospital';
  }

  static String? _determineCostCategory(Map<String, dynamic> hospitalData) {
    // This is a simplified logic - in a real app, you'd have actual cost data
    final rating = hospitalData['rating']?['average'] ?? 0.0;
    final verified = hospitalData['verified'] ?? false;
    
    if (rating >= 4.5 && verified) return 'Premium';
    if (rating >= 4.0) return 'High';
    if (rating >= 3.5) return 'Medium';
    return 'Low';
  }
} 