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
    notifyListeners();
  }

  void _loadDummyData() {
    allDoctors = [
      Doctor(
        id: 'search_1',
        name: 'Dr. Sarah Johnson',
        specialty: 'Cardiologist',
        hospital: 'Mount Sinai Hospital',
        rating: 4.8,
        reviews: 128,
        price: 100.0,
        isOnline: true,
        imageUrl:
            'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=800&q=80',
        experience: 15,
        education: 'MBBS, MD - Cardiology, Harvard Medical School',
        languages: ['English', 'Spanish'],
        specializations: ['Interventional Cardiology', 'Heart Failure'],
        about:
            'Experienced cardiologist with expertise in interventional procedures.',
        availability: {
          'Monday': '9:00 AM - 5:00 PM',
          'Tuesday': '9:00 AM - 5:00 PM',
          'Wednesday': '9:00 AM - 5:00 PM',
          'Thursday': '9:00 AM - 5:00 PM',
          'Friday': '9:00 AM - 5:00 PM',
          'Saturday': '9:00 AM - 2:00 PM',
          'Sunday': 'Closed',
        },
        awards: ['Best Cardiologist 2023'],
        consultationFee: '₹100',
        acceptsInsurance: true,
        insuranceProviders: ['Max Bupa', 'HDFC Health'],
        location: 'Mumbai, Maharashtra',
        distance: 2.3,
        isVerified: true,
        phoneNumber: '+91 98765 43210',
        email: 'dr.sarah.johnson@hospital.com',
      ),
      Doctor(
        id: 'search_2',
        name: 'Dr. Michael Chen',
        specialty: 'Dentist',
        hospital: 'NYU Langone',
        rating: 4.7,
        reviews: 89,
        price: 90.0,
        isOnline: false,
        imageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=800&q=80',
        experience: 12,
        education: 'BDS, MDS - Orthodontics, Delhi University',
        languages: ['English', 'Hindi', 'Mandarin'],
        specializations: ['Orthodontics', 'Cosmetic Dentistry'],
        about:
            'Skilled dentist with expertise in orthodontics and cosmetic procedures.',
        availability: {
          'Monday': '10:00 AM - 6:00 PM',
          'Tuesday': '10:00 AM - 6:00 PM',
          'Wednesday': '10:00 AM - 6:00 PM',
          'Thursday': '10:00 AM - 6:00 PM',
          'Friday': '10:00 AM - 6:00 PM',
          'Saturday': '9:00 AM - 3:00 PM',
          'Sunday': 'Closed',
        },
        awards: ['Best Dentist Award 2022'],
        consultationFee: '₹90',
        acceptsInsurance: true,
        insuranceProviders: ['Max Bupa', 'Star Health'],
        location: 'Delhi, NCR',
        distance: 1.8,
        isVerified: true,
        phoneNumber: '+91 98765 43211',
        email: 'dr.michael.chen@dental.com',
      ),
      Doctor(
        id: 'search_3',
        name: 'Dr. Emily Brown',
        specialty: 'Pediatrician',
        hospital: 'Children\'s Hospital',
        rating: 4.9,
        reviews: 156,
        price: 85.0,
        isOnline: true,
        imageUrl:
            'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&w=800&q=80',
        experience: 18,
        education: 'MBBS, MD - Pediatrics, AIIMS Delhi',
        languages: ['English', 'Hindi'],
        specializations: ['General Pediatrics', 'Child Development'],
        about:
            'Compassionate pediatrician with 18 years of experience in child healthcare.',
        availability: {
          'Monday': '8:00 AM - 4:00 PM',
          'Tuesday': '8:00 AM - 4:00 PM',
          'Wednesday': '8:00 AM - 4:00 PM',
          'Thursday': '8:00 AM - 4:00 PM',
          'Friday': '8:00 AM - 4:00 PM',
          'Saturday': '8:00 AM - 12:00 PM',
          'Sunday': 'Closed',
        },
        awards: ['Best Pediatrician 2023'],
        consultationFee: '₹85',
        acceptsInsurance: true,
        insuranceProviders: ['Max Bupa', 'HDFC Health', 'Star Health'],
        location: 'Bangalore, Karnataka',
        distance: 3.1,
        isVerified: true,
        phoneNumber: '+91 98765 43212',
        email: 'dr.emily.brown@children.com',
      ),
      Doctor(
        id: 'search_4',
        name: 'Dr. David Wilson',
        specialty: 'Neurologist',
        hospital: 'Johns Hopkins',
        rating: 4.6,
        reviews: 203,
        price: 120.0,
        isOnline: false,
        imageUrl:
            'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&w=800&q=80',
        experience: 20,
        education: 'MBBS, MD - Neurology, JIPMER',
        languages: ['English', 'Hindi', 'Tamil'],
        specializations: ['Stroke Management', 'Epilepsy'],
        about:
            'Renowned neurologist specializing in stroke management and neurological disorders.',
        availability: {
          'Monday': '9:00 AM - 6:00 PM',
          'Tuesday': '9:00 AM - 6:00 PM',
          'Wednesday': '9:00 AM - 6:00 PM',
          'Thursday': '9:00 AM - 6:00 PM',
          'Friday': '9:00 AM - 6:00 PM',
          'Saturday': '9:00 AM - 2:00 PM',
          'Sunday': 'Closed',
        },
        awards: ['Neurology Excellence Award'],
        consultationFee: '₹120',
        acceptsInsurance: true,
        insuranceProviders: ['Max Bupa', 'HDFC Health', 'ICICI Lombard'],
        location: 'Chennai, Tamil Nadu',
        distance: 4.2,
        isVerified: true,
        phoneNumber: '+91 98765 43213',
        email: 'dr.david.wilson@neuro.com',
      ),
      Doctor(
        id: 'search_5',
        name: 'Dr. Lisa Rodriguez',
        specialty: 'Dermatologist',
        hospital: 'Mayo Clinic',
        rating: 4.5,
        reviews: 94,
        price: 95.0,
        isOnline: true,
        imageUrl:
            'https://images.unsplash.com/photo-1582750433449-648ed127bb54?auto=format&fit=crop&w=800&q=80',
        experience: 14,
        education: 'MBBS, MD - Dermatology, PGIMER',
        languages: ['English', 'Hindi', 'Spanish'],
        specializations: ['Cosmetic Dermatology', 'Skin Cancer'],
        about:
            'Board-certified dermatologist with expertise in cosmetic procedures and skin cancer treatment.',
        availability: {
          'Monday': '10:00 AM - 7:00 PM',
          'Tuesday': '10:00 AM - 7:00 PM',
          'Wednesday': '10:00 AM - 7:00 PM',
          'Thursday': '10:00 AM - 7:00 PM',
          'Friday': '10:00 AM - 7:00 PM',
          'Saturday': '10:00 AM - 4:00 PM',
          'Sunday': 'Closed',
        },
        awards: ['Dermatology Excellence Award'],
        consultationFee: '₹95',
        acceptsInsurance: true,
        insuranceProviders: ['Max Bupa', 'Star Health'],
        location: 'Pune, Maharashtra',
        distance: 2.8,
        isVerified: true,
        phoneNumber: '+91 98765 43214',
        email: 'dr.lisa.rodriguez@derma.com',
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
    isSearching = query.trim().isNotEmpty;
    _performSearch(query.trim());
    notifyListeners();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      // When no search query, show all doctors with current filter
      filteredDoctors = _applyFilter(allDoctors, selectedFilter);
      hasSearchResults = true;
    } else {
      // Perform intelligent search
      final searchResults = _searchDoctors(query);
      filteredDoctors = _applyFilter(searchResults, selectedFilter);
      hasSearchResults = filteredDoctors.isNotEmpty;
    }
  }

  List<Doctor> _searchDoctors(String query) {
    final searchLower = query.toLowerCase();
    final searchTerms =
        searchLower.split(' ').where((term) => term.isNotEmpty).toList();

    return allDoctors.where((doctor) {
      // Check if any search term matches any field
      for (final term in searchTerms) {
        final matchesName = doctor.name.toLowerCase().contains(term);
        final matchesSpecialty = doctor.specialty.toLowerCase().contains(term);
        final matchesHospital = doctor.hospital.toLowerCase().contains(term);

        // If any term matches any field, include this doctor
        if (matchesName || matchesSpecialty || matchesHospital) {
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
        return doctors.where((d) => d.isOnline).toList();
      case SearchFilter.online:
        return doctors.where((d) => d.isOnline).toList();
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

    return suggestions.take(5).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
