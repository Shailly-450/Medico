import 'package:flutter/material.dart';
import '../core/services/health_record_service.dart';
import '../models/health_record.dart';

class HealthRecordsViewModel extends ChangeNotifier {
  HealthRecordService? _healthRecordService;
  List<HealthRecord> _allRecords = [];
  List<HealthRecord> _filteredRecords = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _showImportantOnly = false;
  String? _currentFamilyMemberId;
  bool _isLoading = false;
  String? _error;

  // Initialize with service
  void init(HealthRecordService service) {
    _healthRecordService = service;
  }

  // Getters
  List<HealthRecord> get allRecords => _allRecords;
  List<HealthRecord> get filteredRecords => _filteredRecords;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get showImportantOnly => _showImportantOnly;
  String? get currentFamilyMemberId => _currentFamilyMemberId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<String> get categories => [
        'All',
        'Conditions',
        'Allergies',
        'Medications',
        'Lab Results',
        'Procedures',
        'Immunizations',
        'Family History'
      ];

  Future<void> loadHealthRecords() async {
    if (_healthRecordService == null) {
      _error = 'Authentication required';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      _allRecords =
          await _healthRecordService!.getHealthRecords(_currentFamilyMemberId);
      _error = null;
      _applyFilters();
    } catch (e) {
      _error = 'Failed to load health records: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentFamilyMember(String? familyMemberId) {
    _currentFamilyMemberId = familyMemberId;
    loadHealthRecords();
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
      if (_currentFamilyMemberId != null &&
          record.familyMemberId != _currentFamilyMemberId) {
        return false;
      }
      if (_selectedCategory != 'All' && record.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!record.title.toLowerCase().contains(query) &&
            !(record.description?.toLowerCase().contains(query) ?? false) &&
            !(record.provider?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }
      if (_showImportantOnly && !record.isImportant) {
        return false;
      }
      return true;
    }).toList();

    _filteredRecords.sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addRecord(HealthRecord record) async {
    try {
      _isLoading = true;
      notifyListeners();

      final newRecord = await _healthRecordService!.addHealthRecord(record);
      _allRecords.add(newRecord);
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = 'Failed to add record: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteRecord(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _healthRecordService!.deleteHealthRecord(id);
      _allRecords.removeWhere((record) => record.id == id);
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = 'Failed to delete record: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsImportant(String id, bool isImportant) async {
    try {
      _isLoading = true;
      notifyListeners();

      final index = _allRecords.indexWhere((record) => record.id == id);
      if (index != -1) {
        // Create new record with updated importance without using copyWith
        final record = _allRecords[index];
        final updatedRecord = HealthRecord(
          id: record.id,
          patientId: record.patientId,
          recordType: record.recordType,
          title: record.title,
          description: record.description,
          date: record.date,
          medicalHistory: record.medicalHistory,
          allergies: record.allergies,
          medications: record.medications,
          labResults: record.labResults,
          imaging: record.imaging,
          surgery: record.surgery,
          familyHistory: record.familyHistory,
          attachments: record.attachments,
          isPrivate: record.isPrivate,
          familyMemberId: record.familyMemberId,
          provider: record.provider,
          providerImage: record.providerImage,
          status: record.status,
          isImportant: isImportant, // Only this changes
        );

        await _healthRecordService!.updateHealthRecord(updatedRecord);
        _allRecords[index] = updatedRecord;
        _applyFilters();
      }
    } catch (e) {
      _error = 'Failed to update record: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
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
      case 'Conditions':
        return Icons.health_and_safety;
      case 'Allergies':
        return Icons.warning;
      case 'Medications':
        return Icons.medication;
      case 'Lab Results':
        return Icons.science;
      case 'Procedures':
        return Icons.medical_services;
      case 'Immunizations':
        return Icons.vaccines;
      case 'Family History':
        return Icons.family_restroom;
      default:
        return Icons.medical_information;
    }
  }
}
