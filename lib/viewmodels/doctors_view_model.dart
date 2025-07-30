import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../core/services/doctor_service.dart';
import '../models/doctor.dart';
import '../models/doctor_review.dart';

enum DoctorFilter {
  all,
  online,
  nearby,
  topRated,
  lowPrice,
  highPrice,
  verified,
}

class DoctorsViewModel extends BaseViewModel {
  final DoctorService _doctorService = DoctorService();
  
  List<Doctor> _allDoctors = [];
  List<Doctor> _filteredDoctors = [];
  final List<DoctorReview> _doctorReviews = [];
  String _searchQuery = '';
  DoctorFilter _selectedFilter = DoctorFilter.all;
  String _selectedSpecialty = 'All';
  bool _isLoading = false;
  String? _errorMessage;
  
  // Pagination
  int _currentPage = 1;
  bool _hasMoreDoctors = true;
  Map<String, dynamic>? _pagination;

  // Getters
  List<Doctor> get allDoctors => _allDoctors;
  List<Doctor> get filteredDoctors => _filteredDoctors;
  List<DoctorReview> get doctorReviews => _doctorReviews;
  String get searchQuery => _searchQuery;
  DoctorFilter get selectedFilter => _selectedFilter;
  String get selectedSpecialty => _selectedSpecialty;
  bool get isLoading => _isLoading;
  @override
  String? get errorMessage => _errorMessage;
  bool get hasMoreDoctors => _hasMoreDoctors;
  Map<String, dynamic>? get pagination => _pagination;

  List<String> get availableSpecialties {
    final specialties = _allDoctors.map((d) => d.specialty).toSet().toList();
    specialties.insert(0, 'All');
    return specialties;
  }

  @override
  void init() {
    loadDoctors();
  }

  // Load doctors with optional parameters
  Future<void> loadDoctors({
    String? specialty,
    String? search,
    String? sort,
    int? limit,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _allDoctors.clear();
        _hasMoreDoctors = true;
      }

      if (!_hasMoreDoctors || _isLoading) return;

      setBusy(true);
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      debugPrint('🔄 Loading doctors...');
      
      final result = await _doctorService.getDoctors(
        specialty: specialty,
        search: search,
        sort: sort,
        limit: limit ?? 20,
        page: _currentPage,
      );

      if (result['success'] == true) {
        final List<Doctor> newDoctors = result['data'];
        _pagination = result['pagination'];
        
        if (refresh) {
          _allDoctors = newDoctors;
        } else {
          _allDoctors.addAll(newDoctors);
        }
        
        _hasMoreDoctors = newDoctors.length >= (limit ?? 20);
        _currentPage++;
        
        _applyFilters();
        _errorMessage = null;
        
        debugPrint('✅ Loaded ${newDoctors.length} doctors. Total: ${_allDoctors.length}');
      } else {
        _errorMessage = result['message'] ?? 'Failed to load doctors';
        debugPrint('❌ Error loading doctors: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      debugPrint('❌ Exception loading doctors: $e');
    } finally {
      setBusy(false);
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load doctors by specialty
  Future<void> loadDoctorsBySpecialty(String specialty) async {
    await loadDoctors(specialty: specialty, refresh: true);
  }

  // Load top-rated doctors
  Future<void> loadTopRatedDoctors({int limit = 10}) async {
    await loadDoctors(sort: 'rating', limit: limit, refresh: true);
  }

  // Search doctors
  Future<void> searchDoctors(String searchTerm) async {
    await loadDoctors(search: searchTerm, refresh: true);
  }

  // Load more doctors (pagination)
  Future<void> loadMoreDoctors() async {
    if (!_hasMoreDoctors || _isLoading) return;
    await loadDoctors();
  }

  // Get doctor by ID
  Future<Doctor?> getDoctorById(String doctorId) async {
    try {
      setBusy(true);
      _errorMessage = null;
      notifyListeners();

      debugPrint('🔄 Loading doctor details for ID: $doctorId');
      
      final result = await _doctorService.getDoctorById(doctorId);

      if (result['success'] == true) {
        final doctor = result['data'] as Doctor;
        debugPrint('✅ Loaded doctor: ${doctor.name}');
        return doctor;
      } else {
        _errorMessage = result['message'] ?? 'Failed to load doctor';
        debugPrint('❌ Error loading doctor: $_errorMessage');
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      debugPrint('❌ Exception loading doctor: $e');
      return null;
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setFilter(DoctorFilter filter) {
    _selectedFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  void setSpecialty(String specialty) {
    _selectedSpecialty = specialty;
    _applyFilters();
    notifyListeners();
  }

  @override
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _applyFilters() {
    List<Doctor> filtered = List.from(_allDoctors);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((doctor) {
        final query = _searchQuery.toLowerCase();
        return doctor.name.toLowerCase().contains(query) ||
               doctor.specialty.toLowerCase().contains(query) ||
               doctor.education.toLowerCase().contains(query) ||
               doctor.languages.any((lang) => lang.toLowerCase().contains(query));
      }).toList();
    }

    // Apply specialty filter
    if (_selectedSpecialty != 'All') {
      filtered = filtered.where((doctor) => doctor.specialty == _selectedSpecialty).toList();
    }

    // Apply other filters
    switch (_selectedFilter) {
      case DoctorFilter.online:
        filtered = filtered.where((doctor) => doctor.isOnline).toList();
        break;
      case DoctorFilter.verified:
        filtered = filtered.where((doctor) => doctor.isVerified).toList();
        break;
      case DoctorFilter.topRated:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case DoctorFilter.lowPrice:
        filtered.sort((a, b) => a.consultationFee.compareTo(b.consultationFee));
        break;
      case DoctorFilter.highPrice:
        filtered.sort((a, b) => b.consultationFee.compareTo(a.consultationFee));
        break;
      case DoctorFilter.nearby:
        // For now, just show all doctors since we don't have location data
        break;
      case DoctorFilter.all:
        // No additional filtering
        break;
    }

    _filteredDoctors = filtered;
  }

  // Get doctors by status
  List<Doctor> getDoctorsByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return _allDoctors.where((d) => d.isOnline).toList();
      case 'verified':
        return _allDoctors.where((d) => d.isVerified).toList();
      case 'top-rated':
        final sorted = List<Doctor>.from(_allDoctors);
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        return sorted.take(10).toList();
      default:
        return _allDoctors;
    }
  }

  // Get doctors by specialty
  List<Doctor> getDoctorsBySpecialty(String specialty) {
    return _allDoctors.where((d) => d.specialty == specialty).toList();
  }

  // Get doctor statistics
  Map<String, dynamic> getDoctorStats() {
    if (_allDoctors.isEmpty) return {};

    final totalDoctors = _allDoctors.length;
    final onlineDoctors = _allDoctors.where((d) => d.isOnline).length;
    final verifiedDoctors = _allDoctors.where((d) => d.isVerified).length;
    final avgRating = _allDoctors.map((d) => d.rating).reduce((a, b) => a + b) / totalDoctors;
    final avgFee = _allDoctors.map((d) => d.consultationFee).reduce((a, b) => a + b) / totalDoctors;

    return {
      'totalDoctors': totalDoctors,
      'onlineDoctors': onlineDoctors,
      'verifiedDoctors': verifiedDoctors,
      'avgRating': avgRating,
      'avgFee': avgFee,
    };
  }

  // Review-related methods (for backward compatibility)
  List<DoctorReview> getReviewsForDoctor(String doctorId) {
    // Return empty list for now since we don't have review data
    return [];
  }

  double getAverageCategoryRating(String doctorId, String category) {
    // Return default rating for now
    return 4.5;
  }

  void addReview(DoctorReview review) {
    _doctorReviews.add(review);
    notifyListeners();
  }

  void deleteReview(String reviewId) {
    _doctorReviews.removeWhere((review) => review.id == reviewId);
    notifyListeners();
  }
}
