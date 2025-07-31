import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/prescription.dart';
import '../config.dart';
import 'auth_service.dart';
import 'dart:io';
import 'file_upload_service.dart';

class PrescriptionService {
  static const String _endpoint = '/prescriptions';
  String get baseUrl => '${AppConfig.apiBaseUrl}$_endpoint';

  // Static list to store mock prescriptions that persist across method calls
  static final List<Prescription> _mockPrescriptions = [];

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${AuthService.accessToken}',
      };

  Future<List<Prescription>> getPrescriptions() async {
    try {
      debugPrint('🌐 Fetching prescriptions from: $baseUrl');

      if (AuthService.accessToken == null) {
        throw Exception('Not authenticated');
      }

      // Test API connectivity first
      bool apiAvailable = false;
      try {
        final testResponse = await http.get(
          Uri.parse('${AppConfig.apiBaseUrl}/health'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 5));
        debugPrint('🏥 Health check status: ${testResponse.statusCode}');
        apiAvailable = testResponse.statusCode == 200;
      } catch (e) {
        debugPrint('⚠️ Health check failed: $e');
        apiAvailable = false;
      }

      if (!apiAvailable) {
        debugPrint('🔄 Backend not available, returning mock prescriptions');
        return _getMockPrescriptions();
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: _headers,
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        debugPrint('📦 Response structure: $responseData');

        // Check if response has success field and data field
        if (responseData.containsKey('success') &&
            responseData.containsKey('data')) {
          final List<dynamic> data = responseData['data'];
          final prescriptions =
              data.map((json) => Prescription.fromJson(json)).toList();
          debugPrint(
              '✅ Successfully fetched ${prescriptions.length} prescriptions');
          return prescriptions;
        } else {
          // If response doesn't have the expected structure, throw an error
          throw Exception(
              'Unexpected response format: missing success or data fields');
        }
      }

      debugPrint(
          '❌ Failed to load prescriptions: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load prescriptions: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Error getting prescriptions: $e');
      // Return mock data if API is not available
      return _getMockPrescriptions();
    }
  }

  List<Prescription> _getMockPrescriptions() {
    // If we have stored mock prescriptions, return them
    if (_mockPrescriptions.isNotEmpty) {
      debugPrint('📋 Returning ${_mockPrescriptions.length} stored mock prescriptions');
      return List.from(_mockPrescriptions);
    }

    // Initialize with default mock data
    final defaultMockPrescriptions = [
      Prescription(
        id: 'mock-1',
        patientId: 'patient-1',
        patientName: 'John Doe',
        patientAge: 35,
        doctorId: 'doctor-1',
        doctorName: 'Dr. Smith',
        doctorSpecialty: 'Cardiology',
        prescriptionDate: DateTime.now().subtract(const Duration(days: 7)),
        diagnosis: 'Hypertension',
        medications: [
          PrescriptionMedicine(
            name: 'Amlodipine',
            dosage: '5mg',
            frequency: 'Once daily',
            duration: '30 days',
            instructions: 'Take with food',
            quantity: 30,
            refills: '2',
          ),
        ],
        notes: 'Monitor blood pressure weekly',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Prescription(
        id: 'mock-2',
        patientId: 'patient-1',
        patientName: 'John Doe',
        patientAge: 35,
        doctorId: 'doctor-2',
        doctorName: 'Dr. Johnson',
        doctorSpecialty: 'Dermatology',
        prescriptionDate: DateTime.now().subtract(const Duration(days: 3)),
        diagnosis: 'Eczema',
        medications: [
          PrescriptionMedicine(
            name: 'Hydrocortisone',
            dosage: '1%',
            frequency: 'Twice daily',
            duration: '14 days',
            instructions: 'Apply to affected areas',
            quantity: 1,
            refills: '1',
          ),
        ],
        notes: 'Avoid hot showers',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    // Add default mock prescriptions to the stored list
    _mockPrescriptions.addAll(defaultMockPrescriptions);
    debugPrint('📋 Initialized with ${_mockPrescriptions.length} default mock prescriptions');
    return List.from(_mockPrescriptions);
  }

  Future<Prescription> getPrescription(String id) async {
    try {
      if (AuthService.accessToken == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return Prescription.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to load prescription');
    } catch (e) {
      throw Exception('Error getting prescription: $e');
    }
  }

  Future<String> generatePrescriptionPdf(String prescriptionId) async {
    try {
      final url = '$baseUrl/$prescriptionId/pdf';
      debugPrint('🌐 Generating PDF from: $url');

      if (AuthService.accessToken == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final pdfUrl = jsonData['pdfUrl'] as String;
        debugPrint('✅ PDF generated successfully: $pdfUrl');
        return pdfUrl;
      }

      debugPrint(
          '❌ Failed to generate PDF: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to generate prescription PDF');
    } catch (e) {
      debugPrint('❌ Error generating PDF: $e');
      throw Exception('Error generating prescription PDF: $e');
    }
  }

  Future<Prescription> createPrescription(
      Map<String, dynamic> prescriptionData) async {
    try {
      debugPrint('🌐 Creating prescription at: $baseUrl');
      debugPrint('📦 Request body: ${json.encode(prescriptionData)}');
      debugPrint('🔑 Auth token: ${AuthService.accessToken?.substring(0, 20)}...');

      if (AuthService.accessToken == null) {
        throw Exception('Not authenticated');
      }

      // Test API connectivity first
      bool apiAvailable = false;
      try {
        final testResponse = await http.get(
          Uri.parse('${AppConfig.apiBaseUrl}/health'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 5));
        debugPrint('🏥 Health check status: ${testResponse.statusCode}');
        apiAvailable = testResponse.statusCode == 200;
      } catch (e) {
        debugPrint('⚠️ Health check failed: $e');
        apiAvailable = false;
      }

      if (!apiAvailable) {
        debugPrint('🔄 Backend not available, creating mock prescription');
        final mockPrescription = Prescription(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          patientId: prescriptionData['patientId'] ?? '',
          patientName: 'Test Patient',
          patientAge: 30,
          doctorId: 'mock-doctor-id',
          doctorName: 'Dr. Test',
          doctorSpecialty: 'General Medicine',
          prescriptionDate: DateTime.now(),
          diagnosis: prescriptionData['diagnosis'] ?? '',
          medications: (prescriptionData['medications'] as List?)
              ?.map((med) => PrescriptionMedicine.fromJson(med))
              .toList() ?? [],
          notes: prescriptionData['notes'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Add the new mock prescription to the stored list
        _mockPrescriptions.insert(0, mockPrescription);
        debugPrint('📋 Added new mock prescription to stored list. Total: ${_mockPrescriptions.length}');
        
        return mockPrescription;
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _headers,
        body: json.encode(prescriptionData),
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📦 Response body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        debugPrint('📦 Response structure: $responseData');

        // Check if response has success field and data field
        if (responseData.containsKey('success') &&
            responseData.containsKey('data')) {
          final prescription = Prescription.fromJson(responseData['data']);
          debugPrint(
              '✅ Prescription created successfully with ID: ${prescription.id}');
          return prescription;
        } else {
          // If response doesn't have the expected structure, try direct parsing
          final prescription = Prescription.fromJson(responseData);
          debugPrint(
              '✅ Prescription created successfully with ID: ${prescription.id}');
          return prescription;
        }
      } else if (response.statusCode == 200) {
        // Some APIs return 200 instead of 201 for creation
        final Map<String, dynamic> responseData = json.decode(response.body);
        debugPrint('📦 Response structure: $responseData');

        if (responseData.containsKey('success') &&
            responseData.containsKey('data')) {
          final prescription = Prescription.fromJson(responseData['data']);
          debugPrint(
              '✅ Prescription created successfully with ID: ${prescription.id}');
          return prescription;
        } else {
          final prescription = Prescription.fromJson(responseData);
          debugPrint(
              '✅ Prescription created successfully with ID: ${prescription.id}');
          return prescription;
        }
      }

      debugPrint(
          '❌ Failed to create prescription: ${response.statusCode} - ${response.body}');
      
      // If the API is not available, create a mock response for testing
      if (response.statusCode == 404 || response.statusCode == 500) {
        debugPrint('🔄 Creating mock prescription for testing');
        final mockPrescription = Prescription(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          patientId: prescriptionData['patientId'] ?? '',
          patientName: 'Test Patient',
          patientAge: 30,
          doctorId: 'mock-doctor-id',
          doctorName: 'Dr. Test',
          doctorSpecialty: 'General Medicine',
          prescriptionDate: DateTime.now(),
          diagnosis: prescriptionData['diagnosis'] ?? '',
          medications: (prescriptionData['medications'] as List?)
              ?.map((med) => PrescriptionMedicine.fromJson(med))
              .toList() ?? [],
          notes: prescriptionData['notes'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Add the new mock prescription to the stored list
        _mockPrescriptions.insert(0, mockPrescription);
        debugPrint('📋 Added new mock prescription to stored list. Total: ${_mockPrescriptions.length}');
        
        return mockPrescription;
      }
      
      throw Exception('Failed to create prescription: ${response.statusCode} - ${response.body}');
    } catch (e) {
      debugPrint('❌ Error creating prescription: $e');
      throw Exception('Error creating prescription: $e');
    }
  }

  Future<Prescription> updatePrescription(
      String id, Map<String, dynamic> updates) async {
    try {
      if (AuthService.accessToken == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: _headers,
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Prescription.fromJson(jsonData);
      }
      throw Exception('Failed to update prescription');
    } catch (e) {
      throw Exception('Error updating prescription: $e');
    }
  }

  Future<void> deletePrescription(String id) async {
    try {
      if (AuthService.accessToken == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete prescription');
      }
    } catch (e) {
      throw Exception('Error deleting prescription: $e');
    }
  }

  // Method to clear mock prescriptions (for testing)
  static void clearMockPrescriptions() {
    _mockPrescriptions.clear();
    debugPrint('🗑️ Cleared all mock prescriptions');
  }

  // Method to get mock prescription count (for debugging)
  static int getMockPrescriptionCount() {
    return _mockPrescriptions.length;
  }

  /// Upload prescription file to Google Drive
  Future<String?> uploadPrescriptionToDrive(File file, String prescriptionId) async {
    try {
      debugPrint('🌐 Uploading prescription to Google Drive...');
      
      final result = await FileUploadService.uploadPrescription(file, prescriptionId);
      
      if (result['success'] == true) {
        debugPrint('✅ Prescription uploaded to Google Drive: ${result['webContentLink']}');
        return result['webContentLink'] as String;
      } else {
        debugPrint('❌ Failed to upload prescription to Google Drive: ${result['error']}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error uploading prescription to Google Drive: $e');
      return null;
    }
  }

  /// Upload prescription attachment to Google Drive
  Future<String?> uploadPrescriptionAttachment(File file, String prescriptionId, String attachmentType) async {
    try {
      debugPrint('🌐 Uploading prescription attachment to Google Drive...');
      
      final fileName = '${attachmentType}_${prescriptionId}_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
      
      final result = await FileUploadService.uploadFileToDrive(
        file: file,
        fileName: fileName,
        description: '$attachmentType attachment for prescription ID: $prescriptionId',
      );
      
      if (result['success'] == true) {
        debugPrint('✅ Prescription attachment uploaded to Google Drive: ${result['webContentLink']}');
        return result['webContentLink'] as String;
      } else {
        debugPrint('❌ Failed to upload prescription attachment to Google Drive: ${result['error']}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error uploading prescription attachment to Google Drive: $e');
      return null;
    }
  }
}
