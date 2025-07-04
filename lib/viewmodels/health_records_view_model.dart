import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/health_record.dart';
import '../models/family_member.dart';

class HealthRecordsViewModel extends BaseViewModel {
  List<HealthRecord> _allRecords = [];
  List<HealthRecord> _filteredRecords = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _showImportantOnly = false;
  String? _currentFamilyMemberId; // Add this field
  
  // Vital signs data
  List<VitalSigns> _vitalSigns = [];
  VitalSigns? _latestVitals;
  
  // Lab results data
  List<LabResult> _labResults = [];
  
  // Getters
  List<HealthRecord> get allRecords => _allRecords;
  List<HealthRecord> get filteredRecords => _filteredRecords;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get showImportantOnly => _showImportantOnly;
  String? get currentFamilyMemberId => _currentFamilyMemberId; // Add this getter
  List<VitalSigns> get vitalSigns => _vitalSigns;
  VitalSigns? get latestVitals => _latestVitals;
  List<LabResult> get labResults => _labResults;
  
  // Categories for filtering
  List<String> get categories => [
    'All',
    'Vital Signs',
    'Lab Results',
    'Medications',
    'Appointments',
    'Procedures',
    'Immunizations',
    'Allergies',
    'Conditions',
  ];

  @override
  void init() {
    super.init();
    _loadMockData();
    _applyFilters();
  }

  void _loadMockData() {
    // Use dummy health records
    _allRecords = HealthRecord.dummyList();

    // Mock vital signs
    _vitalSigns = [
      VitalSigns(
        bloodPressureSystolic: 120,
        bloodPressureDiastolic: 80,
        heartRate: 72,
        temperature: 98.6,
        oxygenSaturation: 98,
        weight: 70.0,
        height: 175.0,
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      VitalSigns(
        bloodPressureSystolic: 118,
        bloodPressureDiastolic: 78,
        heartRate: 70,
        temperature: 98.4,
        oxygenSaturation: 99,
        weight: 69.5,
        height: 175.0,
        date: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];

    _latestVitals = _vitalSigns.isNotEmpty ? _vitalSigns.first : null;

    // Mock lab results
    _labResults = [
      LabResult(
        testName: 'Hemoglobin',
        result: '14.2',
        unit: 'g/dL',
        normalRange: '12.0-15.5',
        status: 'normal',
        date: DateTime.now().subtract(const Duration(days: 5)),
        labName: 'City Medical Lab',
      ),
      LabResult(
        testName: 'White Blood Cells',
        result: '7.5',
        unit: 'K/μL',
        normalRange: '4.5-11.0',
        status: 'normal',
        date: DateTime.now().subtract(const Duration(days: 5)),
        labName: 'City Medical Lab',
      ),
      LabResult(
        testName: 'Cholesterol Total',
        result: '210',
        unit: 'mg/dL',
        normalRange: '<200',
        status: 'high',
        date: DateTime.now().subtract(const Duration(days: 5)),
        labName: 'City Medical Lab',
      ),
    ];
  }

  // Add method to set current family member
  void setCurrentFamilyMember(String? familyMemberId) {
    _currentFamilyMemberId = familyMemberId;
    _applyFilters();
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void toggleImportantOnly() {
    _showImportantOnly = !_showImportantOnly;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredRecords = _allRecords.where((record) {
      // Family member filter
      if (_currentFamilyMemberId != null && record.familyMemberId != _currentFamilyMemberId) {
        return false;
      }
      
      // Category filter
      if (_selectedCategory != 'All' && record.category != _selectedCategory) {
        return false;
      }
      
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!record.title.toLowerCase().contains(query) &&
            !record.description.toLowerCase().contains(query) &&
            !record.provider.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      // Important filter
      if (_showImportantOnly && !record.isImportant) {
        return false;
      }
      
      return true;
    }).toList();
    
    // Sort by date (newest first)
    _filteredRecords.sort((a, b) => b.date.compareTo(a.date));
  }

  void addRecord(HealthRecord record) {
    _allRecords.add(record);
    _applyFilters();
    notifyListeners();
  }

  void deleteRecord(String id) {
    _allRecords.removeWhere((record) => record.id == id);
    _applyFilters();
    notifyListeners();
  }

  void markAsImportant(String id) {
    final index = _allRecords.indexWhere((record) => record.id == id);
    if (index != -1) {
      _allRecords[index] = HealthRecord(
        id: _allRecords[index].id,
        title: _allRecords[index].title,
        description: _allRecords[index].description,
        date: _allRecords[index].date,
        category: _allRecords[index].category,
        provider: _allRecords[index].provider,
        providerImage: _allRecords[index].providerImage,
        data: _allRecords[index].data,
        attachmentUrl: _allRecords[index].attachmentUrl,
        isImportant: !_allRecords[index].isImportant,
        status: _allRecords[index].status,
        familyMemberId: _allRecords[index].familyMemberId, // Add this field
      );
      _applyFilters();
      notifyListeners();
    }
  }

  List<HealthRecord> getRecordsByCategory(String category) {
    return _allRecords.where((record) => record.category == category).toList();
  }

  List<HealthRecord> getRecentRecords(int count) {
    return _allRecords.take(count).toList();
  }

  List<HealthRecord> getImportantRecords() {
    return _allRecords.where((record) => record.isImportant).toList();
  }

  // Add method to get records for a specific family member
  List<HealthRecord> getRecordsForFamilyMember(String familyMemberId) {
    return _allRecords.where((record) => record.familyMemberId == familyMemberId).toList();
  }

  // Add method to get records count for a specific family member
  int getRecordsCountForFamilyMember(String familyMemberId) {
    return _allRecords.where((record) => record.familyMemberId == familyMemberId).length;
  }

  // Add method to get all records for all family members
  Map<String, List<HealthRecord>> getRecordsByFamilyMember() {
    final Map<String, List<HealthRecord>> recordsByFamily = {};
    for (final record in _allRecords) {
      if (!recordsByFamily.containsKey(record.familyMemberId)) {
        recordsByFamily[record.familyMemberId] = [];
      }
      recordsByFamily[record.familyMemberId]!.add(record);
    }
    return recordsByFamily;
  }

  // Add method to get summary statistics
  Map<String, int> getFamilyMemberRecordCounts() {
    final Map<String, int> counts = {};
    for (final record in _allRecords) {
      counts[record.familyMemberId] = (counts[record.familyMemberId] ?? 0) + 1;
    }
    return counts;
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'high':
      case 'low':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Vital Signs':
        return Icons.favorite;
      case 'Lab Results':
        return Icons.science;
      case 'Medications':
        return Icons.medication;
      case 'Appointments':
        return Icons.calendar_today;
      case 'Procedures':
        return Icons.medical_services;
      case 'Immunizations':
        return Icons.vaccines;
      case 'Allergies':
        return Icons.warning;
      case 'Conditions':
        return Icons.health_and_safety;
      default:
        return Icons.medical_information;
    }
  }
} 