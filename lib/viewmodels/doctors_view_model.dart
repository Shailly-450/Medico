import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/viewmodels/base_view_model.dart';
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
  List<Doctor> _allDoctors = [];
  List<Doctor> _filteredDoctors = [];
  List<DoctorReview> _doctorReviews = [];
  String _searchQuery = '';
  DoctorFilter _selectedFilter = DoctorFilter.all;
  String _selectedSpecialty = 'All';
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Doctor> get allDoctors => _allDoctors;
  List<Doctor> get filteredDoctors => _filteredDoctors;
  List<DoctorReview> get doctorReviews => _doctorReviews;
  String get searchQuery => _searchQuery;
  DoctorFilter get selectedFilter => _selectedFilter;
  String get selectedSpecialty => _selectedSpecialty;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<String> get availableSpecialties {
    final specialties = _allDoctors.map((d) => d.specialty).toSet().toList();
    specialties.insert(0, 'All');
    return specialties;
  }

  @override
  void init() {
    fetchDoctorsFromApi();
    // _loadDummyData(); // Remove dummy data loading
    // _applyFilters();
    // notifyListeners();
  }

  Future<void> fetchDoctorsFromApi() async {
    setBusy(true);
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/users/doctors'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List doctorsJson = data['data'];
        _allDoctors = doctorsJson.map((json) => Doctor.fromJson(json)).toList();
        _applyFilters();
        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to load doctors';
        _allDoctors = [];
        _filteredDoctors = [];
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _allDoctors = [];
      _filteredDoctors = [];
    }
    setBusy(false);
    _isLoading = false;
    notifyListeners();
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

  void _applyFilters() {
    List<Doctor> filtered = List.from(_allDoctors);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((doctor) =>
              doctor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              doctor.specialty
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              doctor.hospital
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply specialty filter
    if (_selectedSpecialty != 'All') {
      filtered = filtered
          .where((doctor) => doctor.specialty == _selectedSpecialty)
          .toList();
    }

    // Apply other filters
    switch (_selectedFilter) {
      case DoctorFilter.online:
        filtered = filtered.where((doctor) => doctor.isOnline).toList();
        break;
      case DoctorFilter.nearby:
        filtered.sort((a, b) => a.distance.compareTo(b.distance));
        break;
      case DoctorFilter.topRated:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case DoctorFilter.lowPrice:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case DoctorFilter.highPrice:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case DoctorFilter.verified:
        filtered = filtered.where((doctor) => doctor.isVerified).toList();
        break;
      case DoctorFilter.all:
      default:
        // No additional filtering
        break;
    }

    _filteredDoctors = filtered;
  }

  List<DoctorReview> getReviewsForDoctor(String doctorId) {
    return _doctorReviews
        .where((review) => review.doctorId == doctorId)
        .toList();
  }

  double getAverageCategoryRating(String doctorId, String category) {
    final reviews = getReviewsForDoctor(doctorId);
    if (reviews.isEmpty) return 0.0;

    double total = 0.0;
    int count = 0;

    for (final review in reviews) {
      if (review.categoryRatings != null &&
          review.categoryRatings!.containsKey(category)) {
        total += review.categoryRatings![category]!;
        count++;
      }
    }

    return count > 0 ? total / count : 0.0;
  }

  void addReview(DoctorReview review) {
    _doctorReviews.add(review);
    notifyListeners();
  }

  void deleteReview(String reviewId) {
    _doctorReviews.removeWhere((review) => review.id == reviewId);
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedFilter = DoctorFilter.all;
    _selectedSpecialty = 'All';
    _applyFilters();
    notifyListeners();
  }
}
