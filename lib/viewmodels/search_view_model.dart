import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/doctor.dart';

enum SearchFilter {
  all,
  nearby,
  topRated,
  lowestPrice,
  openNow,
  online,
}

class SearchViewModel extends BaseViewModel {
  final TextEditingController searchController = TextEditingController();
  List<Doctor> allDoctors = [];
  List<Doctor> filteredDoctors = [];
  List<String> recentSearches = [];
  SearchFilter selectedFilter = SearchFilter.all;
  bool isSearching = false;

  @override
  void init() {
    _loadDummyData();
    _loadRecentSearches();
    filteredDoctors = allDoctors;
    notifyListeners();
  }

  void _loadDummyData() {
    allDoctors = [
      Doctor(
        name: 'Dr. Sarah Johnson',
        specialty: 'Cardiologist',
        hospital: 'Mount Sinai Hospital',
        rating: 4.8,
        reviews: 128,
        price: 100.0,
        isOnline: true,
        imageUrl:
            'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=800&q=80',
      ),
      Doctor(
        name: 'Dr. Michael Chen',
        specialty: 'Dentist',
        hospital: 'NYU Langone',
        rating: 4.7,
        reviews: 89,
        price: 90.0,
        isOnline: false,
        imageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=800&q=80',
      ),
      Doctor(
        name: 'Dr. Emily Brown',
        specialty: 'Pediatrician',
        hospital: 'Children\'s Hospital',
        rating: 4.9,
        reviews: 156,
        price: 85.0,
        isOnline: true,
        imageUrl:
            'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&w=800&q=80',
      ),
      Doctor(
        name: 'Dr. David Wilson',
        specialty: 'Neurologist',
        hospital: 'Johns Hopkins',
        rating: 4.6,
        reviews: 203,
        price: 120.0,
        isOnline: false,
        imageUrl:
            'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&w=800&q=80',
      ),
      Doctor(
        name: 'Dr. Lisa Rodriguez',
        specialty: 'Dermatologist',
        hospital: 'Mayo Clinic',
        rating: 4.5,
        reviews: 94,
        price: 95.0,
        isOnline: true,
        imageUrl:
            'https://images.unsplash.com/photo-1594824475544-3d0c0c0c0c0c?auto=format&fit=crop&w=800&q=80',
      ),
      Doctor(
        name: 'Dr. James Thompson',
        specialty: 'Orthopedic Surgeon',
        hospital: 'Cleveland Clinic',
        rating: 4.4,
        reviews: 167,
        price: 150.0,
        isOnline: false,
        imageUrl:
            'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?auto=format&fit=crop&w=800&q=80',
      ),
      Doctor(
        name: 'Dr. Maria Garcia',
        specialty: 'Psychiatrist',
        hospital: 'Stanford Health',
        rating: 4.7,
        reviews: 78,
        price: 110.0,
        isOnline: true,
        imageUrl:
            'https://images.unsplash.com/photo-1582750433449-648ed127bb54?auto=format&fit=crop&w=800&q=80',
      ),
      Doctor(
        name: 'Dr. Robert Lee',
        specialty: 'Oncologist',
        hospital: 'MD Anderson',
        rating: 4.8,
        reviews: 145,
        price: 130.0,
        isOnline: false,
        imageUrl:
            'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&w=800&q=80',
      ),
    ];
  }

  void _loadRecentSearches() {
    // In a real app, this would load from local storage
    recentSearches = [
      'Cardiologist',
      'Dental',
      'MRI',
      'Pediatrician',
      'Dermatologist',
    ];
  }

  void onSearchChanged(String query) {
    isSearching = query.isNotEmpty;
    _performSearch(query);
    notifyListeners();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      filteredDoctors = _applyFilter(allDoctors, selectedFilter);
    } else {
      final searchResults = allDoctors.where((doctor) {
        final searchLower = query.toLowerCase();
        return doctor.name.toLowerCase().contains(searchLower) ||
            doctor.specialty.toLowerCase().contains(searchLower) ||
            doctor.hospital.toLowerCase().contains(searchLower);
      }).toList();

      filteredDoctors = _applyFilter(searchResults, selectedFilter);
    }
  }

  void setFilter(SearchFilter filter) {
    selectedFilter = filter;
    _performSearch(searchController.text);
    notifyListeners();
  }

  List<Doctor> _applyFilter(List<Doctor> doctors, SearchFilter filter) {
    switch (filter) {
      case SearchFilter.all:
        return doctors;
      case SearchFilter.nearby:
        // In a real app, this would filter by distance
        return doctors.take(4).toList();
      case SearchFilter.topRated:
        final sorted = List<Doctor>.from(doctors);
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        return sorted;
      case SearchFilter.lowestPrice:
        final sorted = List<Doctor>.from(doctors);
        sorted.sort((a, b) => a.price.compareTo(b.price));
        return sorted;
      case SearchFilter.openNow:
        // In a real app, this would check actual availability
        return doctors.where((d) => d.isOnline).toList();
      case SearchFilter.online:
        return doctors.where((d) => d.isOnline).toList();
    }
  }

  void addToRecentSearches(String search) {
    if (search.isNotEmpty && !recentSearches.contains(search)) {
      recentSearches.insert(0, search);
      if (recentSearches.length > 10) {
        recentSearches.removeLast();
      }
      // In a real app, save to local storage
      notifyListeners();
    }
  }

  void removeFromRecentSearches(String search) {
    recentSearches.remove(search);
    notifyListeners();
  }

  void clearRecentSearches() {
    recentSearches.clear();
    notifyListeners();
  }

  void onSearchSubmitted(String query) {
    addToRecentSearches(query);
    _performSearch(query);
    notifyListeners();
  }

  String getFilterDisplayName(SearchFilter filter) {
    switch (filter) {
      case SearchFilter.all:
        return 'All';
      case SearchFilter.nearby:
        return 'Nearby';
      case SearchFilter.topRated:
        return 'Top Rated';
      case SearchFilter.lowestPrice:
        return 'Lowest Price';
      case SearchFilter.openNow:
        return 'Open Now';
      case SearchFilter.online:
        return 'Online';
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
