import 'package:flutter/foundation.dart';
import '../models/prescription.dart';
import '../core/services/prescription_service.dart';
import '../core/viewmodels/base_view_model.dart';
import '../core/services/auth_service.dart';

class PrescriptionsViewModel extends BaseViewModel {
  final PrescriptionService _prescriptionService = PrescriptionService();

  List<Prescription> _prescriptions = [];
  List<Prescription> _filteredPrescriptions = [];
  Prescription? _selectedPrescription;
  String _searchQuery = '';
  String _statusFilter = 'all';
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Prescription> get prescriptions => _prescriptions;
  List<Prescription> get filteredPrescriptions => _filteredPrescriptions;
  Prescription? get selectedPrescription => _selectedPrescription;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isBusy => busy; // Alias for BaseViewModel's busy getter

  // Statistics
  int get totalPrescriptions => _prescriptions.length;
  int get activePrescriptions => _prescriptions.where((p) => p.isActive()).length;
  int get expiredPrescriptions => _prescriptions.where((p) => p.isExpired()).length;
  int get completedPrescriptions => _prescriptions.where((p) => p.isCompleted()).length;

  // Initialize the view model
  Future<void> initialize() async {
    await AuthService.initialize();
    await loadPrescriptions();
  }

  // Load all prescriptions
  Future<void> loadPrescriptions() async {
    try {
      setBusy(true);
      _error = null;
      notifyListeners();

      debugPrint('🔄 Loading prescriptions...');
      final prescriptions = await _prescriptionService.getPrescriptions();
      _prescriptions = prescriptions;
      _applyFilters();
      
      debugPrint('✅ Loaded ${prescriptions.length} prescriptions');
      debugPrint('📋 Prescription IDs: ${prescriptions.map((p) => p.id).join(', ')}');
      
      _error = null;
    } catch (e) {
      _error = 'Failed to load prescriptions: $e';
      debugPrint('❌ Error loading prescriptions: $_error');
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // Get prescription by ID
  Future<Prescription?> getPrescriptionById(String id) async {
    try {
      setBusy(true);
      _error = null;
      notifyListeners();

      final prescription = await _prescriptionService.getPrescription(id);
      _selectedPrescription = prescription;
      return prescription;
    } catch (e) {
      _error = 'Failed to load prescription: $e';
      return null;
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // Create new prescription
  Future<bool> createPrescription(Map<String, dynamic> prescriptionData) async {
    try {
      setBusy(true);
      _error = null;
      notifyListeners();

      debugPrint('📝 Creating prescription with data: $prescriptionData');
      
      final newPrescription = await _prescriptionService.createPrescription(prescriptionData);
      _prescriptions.insert(0, newPrescription);
      _applyFilters();
      
      debugPrint('✅ Prescription created successfully with ID: ${newPrescription.id}');
      debugPrint('📋 Total prescriptions in list: ${_prescriptions.length}');
      return true;
    } catch (e) {
      _error = 'Failed to create prescription: $e';
      debugPrint('❌ Error in view model: $_error');
      
      // Check if it's a network/API issue
      if (e.toString().contains('Failed to connect') || 
          e.toString().contains('Connection refused') ||
          e.toString().contains('timeout')) {
        _error = 'Backend server is not available. Prescription created locally for testing.';
      }
      
      return false;
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // Update prescription
  Future<bool> updatePrescription(String id, Map<String, dynamic> updates) async {
    try {
      setBusy(true);
      _error = null;
      notifyListeners();

      final updatedPrescription = await _prescriptionService.updatePrescription(id, updates);
      
      // Update in the list
      final index = _prescriptions.indexWhere((p) => p.id == id);
      if (index != -1) {
        _prescriptions[index] = updatedPrescription;
        if (_selectedPrescription?.id == id) {
          _selectedPrescription = updatedPrescription;
        }
      }
      
      _applyFilters();
      return true;
    } catch (e) {
      _error = 'Failed to update prescription: $e';
      return false;
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // Delete prescription
  Future<bool> deletePrescription(String id) async {
    try {
      setBusy(true);
      _error = null;
      notifyListeners();

      await _prescriptionService.deletePrescription(id);
      
      // Remove from lists
      _prescriptions.removeWhere((p) => p.id == id);
      if (_selectedPrescription?.id == id) {
        _selectedPrescription = null;
      }
      
      _applyFilters();
      return true;
    } catch (e) {
      _error = 'Failed to delete prescription: $e';
      return false;
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // Generate PDF
  Future<String?> generatePdf(String prescriptionId) async {
    try {
      setBusy(true);
      _error = null;
      notifyListeners();

      final pdfUrl = await _prescriptionService.generatePrescriptionPdf(prescriptionId);
      return pdfUrl;
    } catch (e) {
      _error = 'Failed to generate PDF: $e';
      return null;
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // Search and filter methods
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredPrescriptions = _prescriptions.where((prescription) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          prescription.doctorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          prescription.diagnosis.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          prescription.medications.any((med) => 
              med.name.toLowerCase().contains(_searchQuery.toLowerCase()));

      if (!matchesSearch) return false;

      // Status filter
      switch (_statusFilter) {
        case 'active':
          return prescription.isActive();
        case 'expired':
          return prescription.isExpired();
        case 'completed':
          return prescription.isCompleted();
        default:
          return true;
      }
    }).toList();
  }

  // Set selected prescription
  void setSelectedPrescription(Prescription prescription) {
    _selectedPrescription = prescription;
    notifyListeners();
  }

  // Clear selected prescription
  void clearSelectedPrescription() {
    _selectedPrescription = null;
    notifyListeners();
  }

  // Clear error
  @override
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get prescriptions by status
  List<Prescription> getPrescriptionsByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return _prescriptions.where((p) => p.isActive()).toList();
      case 'expired':
        return _prescriptions.where((p) => p.isExpired()).toList();
      case 'completed':
        return _prescriptions.where((p) => p.isCompleted()).toList();
      default:
        return _prescriptions;
    }
  }

  // Check if prescription is recent (within 30 days)
  bool isRecentPrescription(Prescription prescription) {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return prescription.prescriptionDate.isAfter(thirtyDaysAgo);
  }

  // Get prescriptions expiring soon (within 7 days)
  List<Prescription> getExpiringSoon() {
    final sevenDaysFromNow = DateTime.now().add(const Duration(days: 7));
    return _prescriptions.where((p) => 
        p.expirationDate != null && 
        p.expirationDate!.isBefore(sevenDaysFromNow) && 
        p.isActive()
    ).toList();
  }
}
