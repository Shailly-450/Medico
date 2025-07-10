import 'dart:convert';
import 'package:http/http.dart' as http;

enum UserRole { patient, doctor, admin }

class AuthService {
  static const String baseUrl = 'https://api.medico.com';
  static const Duration timeout = Duration(seconds: 10);

  // Mock doctor credentials (in real app, this would come from backend)
  static final Map<String, Map<String, dynamic>> _mockDoctors = {
    'dr.sarah@medico.com': {
      'password': 'doctor123',
      'id': 'doc_001',
      'name': 'Dr. Sarah Johnson',
      'specialty': 'Cardiologist',
      'hospital': 'Mount Sinai Hospital',
      'role': UserRole.doctor,
    },
    'dr.mike@medico.com': {
      'password': 'doctor456',
      'id': 'doc_002',
      'name': 'Dr. Mike Chen',
      'specialty': 'Dermatologist',
      'hospital': 'City General Hospital',
      'role': UserRole.doctor,
    },
    'dr.emma@medico.com': {
      'password': 'doctor789',
      'id': 'doc_003',
      'name': 'Dr. Emma Wilson',
      'specialty': 'Pediatrician',
      'hospital': 'Children\'s Medical Center',
      'role': UserRole.doctor,
    },
  };

  // Mock admin credentials
  static final Map<String, Map<String, dynamic>> _mockAdmins = {
    'admin@medico.com': {
      'password': 'admin123',
      'id': 'admin_001',
      'name': 'System Administrator',
      'role': UserRole.admin,
    },
  };

  // Mock patient credentials
  static final Map<String, Map<String, dynamic>> _mockPatients = {
    'patient@medico.com': {
      'password': 'patient123',
      'id': 'pat_001',
      'name': 'John Doe',
      'role': UserRole.patient,
    },
  };

  static UserRole? _currentUserRole;
  static String? _currentUserId;
  static String? _currentUserName;

  // Getters for current user info
  static UserRole? get currentUserRole => _currentUserRole;
  static String? get currentUserId => _currentUserId;
  static String? get currentUserName => _currentUserName;
  static bool get isLoggedIn => _currentUserId != null;

  // Login method
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 1000));

      final normalizedEmail = email.toLowerCase().trim();

      // Check admin credentials
      if (_mockAdmins.containsKey(normalizedEmail)) {
        final admin = _mockAdmins[normalizedEmail]!;
        if (admin['password'] == password) {
          _setCurrentUser(admin['id'], admin['name'], admin['role']);
          return {
            'success': true,
            'message': 'Admin login successful',
            'role': UserRole.admin,
            'user': admin,
          };
        }
      }

      // Check doctor credentials
      if (_mockDoctors.containsKey(normalizedEmail)) {
        final doctor = _mockDoctors[normalizedEmail]!;
        if (doctor['password'] == password) {
          _setCurrentUser(doctor['id'], doctor['name'], doctor['role']);
          return {
            'success': true,
            'message': 'Doctor login successful',
            'role': UserRole.doctor,
            'user': doctor,
          };
        }
      }

      // Check patient credentials
      if (_mockPatients.containsKey(normalizedEmail)) {
        final patient = _mockPatients[normalizedEmail]!;
        if (patient['password'] == password) {
          _setCurrentUser(patient['id'], patient['name'], patient['role']);
          return {
            'success': true,
            'message': 'Patient login successful',
            'role': UserRole.patient,
            'user': patient,
          };
        }
      }

      // Invalid credentials
      return {
        'success': false,
        'message': 'Invalid email or password',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed: ${e.toString()}',
      };
    }
  }

  // Logout method
  static void logout() {
    _currentUserRole = null;
    _currentUserId = null;
    _currentUserName = null;
  }

  // Helper method to set current user
  static void _setCurrentUser(String id, String name, UserRole role) {
    _currentUserId = id;
    _currentUserName = name;
    _currentUserRole = role;
  }

  // Get available doctor credentials for testing
  static List<Map<String, String>> getAvailableDoctorCredentials() {
    return _mockDoctors.entries.map((entry) {
      return {
        'email': entry.key,
        'password': entry.value['password'] as String,
        'name': entry.value['name'] as String,
        'specialty': entry.value['specialty'] as String,
      };
    }).toList();
  }

  // Check if user is doctor
  static bool get isDoctor => _currentUserRole == UserRole.doctor;
  
  // Check if user is admin
  static bool get isAdmin => _currentUserRole == UserRole.admin;
  
  // Check if user is patient
  static bool get isPatient => _currentUserRole == UserRole.patient;
} 