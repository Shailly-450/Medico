import 'package:flutter/material.dart';

// Pre-approval status enum
enum PreApprovalStatus { pending, approved, rejected, notRequired }

class PreApprovalService {
  // Singleton instance
  static final PreApprovalService _instance = PreApprovalService._internal();
  factory PreApprovalService() => _instance;
  PreApprovalService._internal();

  // Mock pre-approval requirements by specialty
  final Map<String, bool> _specialtiesRequiringPreApproval = {
    'Cardiologist': true,
    'Neurologist': true,
    'Orthopedic': true,
    'Psychiatrist': true,
    'Dermatologist': false,
    'General Physician': false,
    'Pediatrician': false,
    'Dentist': false,
    'Ophthalmologist': false,
  };

  // Check if pre-approval is required for a specialty
  bool isPreApprovalRequired(String specialty) {
    return _specialtiesRequiringPreApproval[specialty] ?? false;
  }

  // Mock pre-approval check
  Future<String> checkPreApprovalStatus(String appointmentId) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock logic: appointments with even IDs are approved, odd are pending
    if (int.tryParse(appointmentId)?.isEven ?? false) {
      return 'approved';
    } else {
      return 'pending';
    }
  }

  // Get pre-approval requirements text
  String getPreApprovalRequirements(String specialty) {
    if (!isPreApprovalRequired(specialty)) {
      return 'No pre-approval required for this specialty.';
    }

    return '''
Pre-approval requirements for $specialty:
• Recent medical history (last 6 months)
• Previous treatment records
• Insurance information
• Referral letter from primary physician (if applicable)
''';
  }

  // Submit pre-approval request
  Future<bool> submitPreApprovalRequest({
    required String appointmentId,
    required String patientName,
    required String specialty,
    required String insuranceNumber,
    String? referralCode,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock success (80% success rate)
    return DateTime.now().millisecond % 5 != 0;
  }
}
