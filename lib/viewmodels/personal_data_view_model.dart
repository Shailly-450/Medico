import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../core/services/personal_data_service.dart';
import '../models/personal_data.dart';

class PersonalDataViewModel extends BaseViewModel {
  final PersonalDataService _dataService = PersonalDataService();
  
  List<PersonalDataItem> _dataItems = [];
  List<DataExportRequest> _exportRequests = [];
  List<DataDeletionRequest> _deletionRequests = [];
  PersonalDataSummary? _summary;
  
  // UI State
  bool _isLoading = false;
  bool _isExporting = false;
  bool _isDeleting = false;
  double _exportProgress = 0.0;
  double _deletionProgress = 0.0;
  String? _errorMessage;
  DataFormat _selectedFormat = DataFormat.json;
  
  // Getters
  List<PersonalDataItem> get dataItems => _dataItems;
  List<DataExportRequest> get exportRequests => _exportRequests;
  List<DataDeletionRequest> get deletionRequests => _deletionRequests;
  PersonalDataSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  bool get isExporting => _isExporting;
  bool get isDeleting => _isDeleting;
  double get exportProgress => _exportProgress;
  double get deletionProgress => _deletionProgress;
  String? get errorMessage => _errorMessage;
  DataFormat get selectedFormat => _selectedFormat;
  
  // Computed properties
  List<PersonalDataItem> get selectedItems => _dataItems.where((item) => item.isSelected).toList();
  List<DataCategory> get selectedCategories => selectedItems.map((item) => item.category).toList();
  bool get hasSelectedItems => selectedItems.isNotEmpty;
  bool get hasRequiredItemsSelected => selectedItems.any((item) => item.isRequired);
  
  // Available formats
  List<DataFormat> get availableFormats => DataFormat.values;
  
  @override
  Future<void> initialize() async {
    setLoading(true);
    try {
      await _dataService.initialize();
      await _loadData();
      setError(null);
    } catch (e) {
      setError('Failed to initialize personal data service: $e');
    } finally {
      setLoading(false);
    }
  }
  
  @override
  void init() {
    initialize();
  }
  
  Future<void> _loadData() async {
    _dataItems = _dataService.dataItems;
    _exportRequests = _dataService.exportRequests;
    _deletionRequests = _dataService.deletionRequests;
    _summary = _dataService.summary;
    notifyListeners();
  }
  
  // Toggle item selection
  void toggleItemSelection(String itemId) {
    _dataService.toggleDataItemSelection(itemId);
    _dataItems = _dataService.dataItems;
    notifyListeners();
  }
  
  // Select all items
  void selectAllItems() {
    _dataService.selectAllDataItems();
    _dataItems = _dataService.dataItems;
    notifyListeners();
  }
  
  // Deselect all items
  void deselectAllItems() {
    _dataService.deselectAllDataItems();
    _dataItems = _dataService.dataItems;
    notifyListeners();
  }
  
  // Set export format
  void setExportFormat(DataFormat format) {
    _selectedFormat = format;
    notifyListeners();
  }
  
  // Export selected data
  Future<DataExportRequest?> exportSelectedData() async {
    if (!hasSelectedItems) {
      setError('Please select at least one data category to export');
      return null;
    }
    
    if (hasRequiredItemsSelected) {
      setError('Cannot export required data categories');
      return null;
    }
    
    setExporting(true);
    setError(null);
    
    try {
      final request = await _dataService.exportData(
        categories: selectedCategories,
        format: _selectedFormat,
        onProgress: (progress) {
          _exportProgress = progress;
          notifyListeners();
        },
      );
      
      _exportRequests = _dataService.exportRequests;
      notifyListeners();
      
      return request;
    } catch (e) {
      setError('Export failed: $e');
      return null;
    } finally {
      setExporting(false);
      _exportProgress = 0.0;
      notifyListeners();
    }
  }
  
  // Export all data
  Future<DataExportRequest?> exportAllData() async {
    setExporting(true);
    setError(null);
    
    try {
      final request = await _dataService.exportData(
        categories: _dataService.availableCategories,
        format: _selectedFormat,
        onProgress: (progress) {
          _exportProgress = progress;
          notifyListeners();
        },
      );
      
      _exportRequests = _dataService.exportRequests;
      notifyListeners();
      
      return request;
    } catch (e) {
      setError('Export failed: $e');
      return null;
    } finally {
      setExporting(false);
      _exportProgress = 0.0;
      notifyListeners();
    }
  }
  
  // Delete selected data
  Future<DataDeletionRequest?> deleteSelectedData(String reason) async {
    if (!hasSelectedItems) {
      setError('Please select at least one data category to delete');
      return null;
    }
    
    if (hasRequiredItemsSelected) {
      setError('Cannot delete required data categories');
      return null;
    }
    
    setDeleting(true);
    setError(null);
    
    try {
      final request = await _dataService.deleteData(
        categories: selectedCategories,
        reason: reason,
        onProgress: (progress) {
          _deletionProgress = progress;
          notifyListeners();
        },
      );
      
      _deletionRequests = _dataService.deletionRequests;
      _dataItems = _dataService.dataItems;
      _summary = _dataService.summary;
      notifyListeners();
      
      return request;
    } catch (e) {
      setError('Deletion failed: $e');
      return null;
    } finally {
      setDeleting(false);
      _deletionProgress = 0.0;
      notifyListeners();
    }
  }
  
  // Delete all data
  Future<DataDeletionRequest?> deleteAllData(String reason) async {
    setDeleting(true);
    setError(null);
    
    try {
      final request = await _dataService.deleteData(
        categories: _dataService.availableCategories,
        reason: reason,
        onProgress: (progress) {
          _deletionProgress = progress;
          notifyListeners();
        },
      );
      
      _deletionRequests = _dataService.deletionRequests;
      _dataItems = _dataService.dataItems;
      _summary = _dataService.summary;
      notifyListeners();
      
      return request;
    } catch (e) {
      setError('Deletion failed: $e');
      return null;
    } finally {
      setDeleting(false);
      _deletionProgress = 0.0;
      notifyListeners();
    }
  }
  
  // Get export request by ID
  DataExportRequest? getExportRequest(String id) {
    return _dataService.getExportRequest(id);
  }
  
  // Get deletion request by ID
  DataDeletionRequest? getDeletionRequest(String id) {
    return _dataService.getDeletionRequest(id);
  }
  
  // Clear export requests
  void clearExportRequests() {
    _dataService.clearExportRequests();
    _exportRequests = _dataService.exportRequests;
    notifyListeners();
  }
  
  // Clear deletion requests
  void clearDeletionRequests() {
    _dataService.clearDeletionRequests();
    _deletionRequests = _dataService.deletionRequests;
    notifyListeners();
  }
  
  // Refresh data
  Future<void> refreshData() async {
    setLoading(true);
    try {
      await _loadData();
      setError(null);
    } catch (e) {
      setError('Failed to refresh data: $e');
    } finally {
      setLoading(false);
    }
  }
  
  // Helper methods for UI state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void setExporting(bool exporting) {
    _isExporting = exporting;
    notifyListeners();
  }
  
  void setDeleting(bool deleting) {
    _isDeleting = deleting;
    notifyListeners();
  }
  
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Format helpers
  String formatFileSize(String? size) {
    return size ?? 'Unknown';
  }
  
  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  String formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  // Category helpers
  IconData getCategoryIcon(DataCategory category) {
    switch (category) {
      case DataCategory.profile:
        return Icons.person;
      case DataCategory.healthRecords:
        return Icons.medical_information;
      case DataCategory.appointments:
        return Icons.calendar_today;
      case DataCategory.prescriptions:
        return Icons.medication;
      case DataCategory.medications:
        return Icons.medication;
      case DataCategory.familyMembers:
        return Icons.family_restroom;
      case DataCategory.payments:
        return Icons.payment;
      case DataCategory.invoices:
        return Icons.receipt;
      case DataCategory.chatHistory:
        return Icons.chat;
      case DataCategory.notifications:
        return Icons.notifications;
      case DataCategory.consentSettings:
        return Icons.privacy_tip;
      case DataCategory.preferences:
        return Icons.settings;
      case DataCategory.documents:
        return Icons.description;
      case DataCategory.analytics:
        return Icons.analytics;
      case DataCategory.all:
        return Icons.all_inclusive;
    }
  }
  
  Color getCategoryColor(DataCategory category) {
    switch (category) {
      case DataCategory.profile:
        return Colors.blue;
      case DataCategory.healthRecords:
        return Colors.green;
      case DataCategory.appointments:
        return Colors.orange;
      case DataCategory.prescriptions:
        return Colors.purple;
      case DataCategory.medications:
        return Colors.indigo;
      case DataCategory.familyMembers:
        return Colors.teal;
      case DataCategory.payments:
        return Colors.amber;
      case DataCategory.invoices:
        return Colors.red;
      case DataCategory.chatHistory:
        return Colors.cyan;
      case DataCategory.notifications:
        return Colors.pink;
      case DataCategory.consentSettings:
        return Colors.brown;
      case DataCategory.preferences:
        return Colors.grey;
      case DataCategory.documents:
        return Colors.deepPurple;
      case DataCategory.analytics:
        return Colors.lightBlue;
      case DataCategory.all:
        return Colors.black;
    }
  }
  
  String getFormatDisplayName(DataFormat format) {
    switch (format) {
      case DataFormat.json:
        return 'JSON';
      case DataFormat.csv:
        return 'CSV';
      case DataFormat.pdf:
        return 'PDF';
      case DataFormat.xml:
        return 'XML';
    }
  }
} 