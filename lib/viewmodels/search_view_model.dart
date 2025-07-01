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
  bool hasSearchResults = false;

  @override
  void init() {
    _loadDummyData();
    _loadRecentSearches();
    filteredDoctors = allDoctors;
    
    // Test symptom search
    _testSymptomSearch();
    
    notifyListeners();
  }

  void _loadDummyData() {
    allDoctors = [
      Doctor(
        id: '1',
        name: 'Dr. Sarah Johnson',
        specialty: 'Cardiologist',
        hospital: 'Mount Sinai Hospital',
        rating: 4.8,
        reviews: 128,
        price: 100.0,
        isAvailable: true,
        videoCall: true,
        imageUrl:
            'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=800&q=80',
        symptoms: ['chest pain', 'shortness of breath', 'palpitations'],
      ),
      Doctor(
        id: '2',
        name: 'Dr. Michael Chen',
        specialty: 'Dentist',
        hospital: 'NYU Langone',
        rating: 4.7,
        reviews: 89,
        price: 90.0,
        isAvailable: false,
        videoCall: false,
        imageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=800&q=80',
        symptoms: ['toothache', 'cavity', 'gum bleeding'],
      ),
      Doctor(
        id: '3',
        name: 'Dr. Emily Brown',
        specialty: 'Pediatrician',
        hospital: 'Children\'s Hospital',
        rating: 4.9,
        reviews: 156,
        price: 85.0,
        isAvailable: true,
        videoCall: true,
        imageUrl:
            'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&w=800&q=80',
        symptoms: ['fever', 'cough', 'child growth'],
      ),
      Doctor(
        id: '4',
        name: 'Dr. David Wilson',
        specialty: 'Neurologist',
        hospital: 'Johns Hopkins',
        rating: 4.6,
        reviews: 203,
        price: 120.0,
        isAvailable: false,
        videoCall: false,
        imageUrl:
            'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&w=800&q=80',
        symptoms: ['headache', 'seizures', 'memory loss'],
      ),
      Doctor(
        id: '5',
        name: 'Dr. Lisa Rodriguez',
        specialty: 'Dermatologist',
        hospital: 'Mayo Clinic',
        rating: 4.5,
        reviews: 94,
        price: 95.0,
        isAvailable: true,
        videoCall: true,
        imageUrl:
            'https://images.unsplash.com/photo-1594824475544-3d0c0c0c0c0c?auto=format&fit=crop&w=800&q=80',
        symptoms: ['rash', 'acne', 'itching'],
      ),
      Doctor(
        id: '6',
        name: 'Dr. James Thompson',
        specialty: 'Orthopedic Surgeon',
        hospital: 'Cleveland Clinic',
        rating: 4.4,
        reviews: 167,
        price: 150.0,
        isAvailable: false,
        videoCall: false,
        imageUrl:
            'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?auto=format&fit=crop&w=800&q=80',
        symptoms: ['joint pain', 'fracture', 'back pain'],
      ),
      Doctor(
        id: '7',
        name: 'Dr. Maria Garcia',
        specialty: 'Psychiatrist',
        hospital: 'Stanford Health',
        rating: 4.7,
        reviews: 78,
        price: 110.0,
        isAvailable: true,
        videoCall: true,
        imageUrl:
            'https://images.unsplash.com/photo-1582750433449-648ed127bb54?auto=format&fit=crop&w=800&q=80',
        symptoms: ['anxiety', 'depression', 'insomnia'],
      ),
      Doctor(
        id: '8',
        name: 'Dr. Robert Lee',
        specialty: 'Oncologist',
        hospital: 'MD Anderson',
        rating: 4.8,
        reviews: 145,
        price: 130.0,
        isAvailable: false,
        videoCall: false,
        imageUrl:
            'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&w=800&q=80',
        symptoms: ['lump', 'weight loss', 'fatigue'],
      ),
      Doctor(
        id: '9',
        name: 'Dr. Jennifer Foster',
        specialty: 'Family Medicine',
        hospital: 'Kaiser Permanente',
        rating: 4.3,
        reviews: 112,
        price: 75.0,
        isAvailable: true,
        videoCall: true,
        imageUrl:
            'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=800&q=80',
        symptoms: ['cold', 'flu', 'checkup'],
      ),
      Doctor(
        id: '10',
        name: 'Dr. Alex Kumar',
        specialty: 'Endocrinologist',
        hospital: 'Cedars-Sinai',
        rating: 4.6,
        reviews: 89,
        price: 105.0,
        isAvailable: false,
        videoCall: false,
        imageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=800&q=80',
        symptoms: ['diabetes', 'thyroid', 'hormone imbalance'],
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
    final trimmedQuery = query.trim();
    isSearching = trimmedQuery.isNotEmpty;
    _performSearch(trimmedQuery);
    notifyListeners();
  }

  void _performSearch(String query) {
    print('_performSearch called with query: "$query"'); // Debug
    
    if (query.isEmpty) {
      // When no search query, show all doctors with current filter
      filteredDoctors = _applyFilter(allDoctors, selectedFilter);
      hasSearchResults = true;
      isSearching = false;
      print('Empty query - showing all doctors: ${filteredDoctors.length}'); // Debug
    } else {
      // Perform intelligent search
      final searchResults = _searchDoctors(query);
      print('Search results before filter: ${searchResults.length}'); // Debug
      filteredDoctors = _applyFilter(searchResults, selectedFilter);
      hasSearchResults = filteredDoctors.isNotEmpty;
      isSearching = true;
      print('Final filtered results: ${filteredDoctors.length}, hasSearchResults: $hasSearchResults'); // Debug
    }
  }

  List<Doctor> _searchDoctors(String query) {
    final searchLower = query.toLowerCase().trim();
    if (searchLower.isEmpty) return allDoctors;
    
    final searchTerms = searchLower.split(' ').where((term) => term.isNotEmpty).toList();
    
    print('Searching for: "$searchLower" with terms: $searchTerms'); // Debug

    return allDoctors.where((doctor) {
      // Check each search term against all fields
      for (final term in searchTerms) {
        final matchesName = doctor.name.toLowerCase().contains(term);
        final matchesSpecialty = doctor.specialty.toLowerCase().contains(term);
        final matchesHospital = doctor.hospital.toLowerCase().contains(term);
        
        // Check symptoms - more flexible matching
        final matchesSymptom = doctor.symptoms.any((symptom) {
          final symptomLower = symptom.toLowerCase();
          return symptomLower.contains(term) || term.contains(symptomLower);
        });
        
        if (matchesName || matchesSpecialty || matchesHospital || matchesSymptom) {
          print('Found match: ${doctor.name} - matches symptom: $matchesSymptom'); // Debug
          return true;
        }
      }
      return false;
    }).toList();
  }

  void setFilter(SearchFilter filter) {
    selectedFilter = filter;
    _performSearch(searchController.text.trim());
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
        return doctors.where((d) => d.isAvailable).toList();
      case SearchFilter.online:
        return doctors.where((d) => d.videoCall).toList();
    }
  }

  void addToRecentSearches(String search) {
    final trimmedSearch = search.trim();
    if (trimmedSearch.isNotEmpty && !recentSearches.contains(trimmedSearch)) {
      recentSearches.insert(0, trimmedSearch);
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
    final trimmedQuery = query.trim();
    if (trimmedQuery.isNotEmpty) {
      addToRecentSearches(trimmedQuery);
      _performSearch(trimmedQuery);
      notifyListeners();
    }
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

  // Get search suggestions based on current input
  List<String> getSearchSuggestions(String query) {
    if (query.trim().isEmpty) return [];

    final suggestions = <String>{};
    final queryLower = query.toLowerCase();

    // Add matching specialties
    for (final doctor in allDoctors) {
      if (doctor.specialty.toLowerCase().contains(queryLower)) {
        suggestions.add(doctor.specialty);
      }
    }

    // Add matching hospital names
    for (final doctor in allDoctors) {
      if (doctor.hospital.toLowerCase().contains(queryLower)) {
        suggestions.add(doctor.hospital);
      }
    }

    // Add matching doctor names
    for (final doctor in allDoctors) {
      if (doctor.name.toLowerCase().contains(queryLower)) {
        suggestions.add(doctor.name);
      }
    }

    // Add matching symptoms
    for (final doctor in allDoctors) {
      for (final symptom in doctor.symptoms) {
        if (symptom.toLowerCase().contains(queryLower)) {
          suggestions.add(symptom);
        }
      }
    }

    return suggestions.take(5).toList();
  }

  void _testSymptomSearch() {
    print('=== Testing Symptom Search ===');
    print('Total doctors: ${allDoctors.length}');
    
    // Test some symptom searches
    final testSymptoms = ['headache', 'chest pain', 'rash', 'anxiety'];
    
    for (final symptom in testSymptoms) {
      final results = _searchDoctors(symptom);
      print('Searching for "$symptom": Found ${results.length} doctors');
      for (final doctor in results) {
        print('  - ${doctor.name} (${doctor.specialty})');
      }
    }
    print('=== End Test ===');
  }

  void testSymptomSearch(String symptom) {
    print('=== Testing Symptom Search for: $symptom ===');
    final results = _searchDoctors(symptom);
    print('Found ${results.length} doctors for symptom: $symptom');
    for (final doctor in results) {
      print('  - ${doctor.name} (${doctor.specialty}) - Symptoms: ${doctor.symptoms}');
    }
    print('=== End Test ===');
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
