import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../models/personal_data.dart';
// import '../../models/notification.dart'; // Commented out - model not found

class PersonalDataService {
  static final PersonalDataService _instance = PersonalDataService._internal();
  factory PersonalDataService() => _instance;
  PersonalDataService._internal();

  // Mock data for demonstration
  List<PersonalDataItem> _dataItems = [];
  List<DataExportRequest> _exportRequests = [];
  List<DataDeletionRequest> _deletionRequests = [];
  PersonalDataSummary? _summary;

  // Getters
  List<PersonalDataItem> get dataItems => List.unmodifiable(_dataItems);
  List<DataExportRequest> get exportRequests => List.unmodifiable(_exportRequests);
  List<DataDeletionRequest> get deletionRequests => List.unmodifiable(_deletionRequests);
  PersonalDataSummary? get summary => _summary;
  List<DataCategory> get availableCategories => DataCategory.values.where((c) => c != DataCategory.all).toList();

  // Initialize service with mock data
  Future<void> initialize() async {
    await _loadMockData();
    await _generateSummary();
  }

  Future<void> _loadMockData() async {
    _dataItems = [
      PersonalDataItem(
        id: '1',
        title: 'Profile Information',
        description: 'Personal details, contact information, and account settings',
        category: DataCategory.profile,
        recordCount: 1,
        lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
        isRequired: true,
        canDelete: false,
        fileSize: '2.3 KB',
        tags: ['personal', 'account'],
      ),
      PersonalDataItem(
        id: '2',
        title: 'Health Records',
        description: 'Medical records, test results, and health history',
        category: DataCategory.healthRecords,
        recordCount: 15,
        lastUpdated: DateTime.now().subtract(const Duration(hours: 6)),
        fileSize: '45.2 KB',
        tags: ['medical', 'health'],
      ),
      PersonalDataItem(
        id: '3',
        title: 'Appointments',
        description: 'Scheduled appointments and visit history',
        category: DataCategory.appointments,
        recordCount: 8,
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        fileSize: '12.8 KB',
        tags: ['scheduling', 'visits'],
      ),
      PersonalDataItem(
        id: '4',
        title: 'Prescriptions',
        description: 'Medication prescriptions and refill history',
        category: DataCategory.prescriptions,
        recordCount: 12,
        lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
        fileSize: '28.5 KB',
        tags: ['medication', 'prescriptions'],
      ),
      PersonalDataItem(
        id: '5',
        title: 'Family Members',
        description: 'Family member profiles and health records',
        category: DataCategory.familyMembers,
        recordCount: 4,
        lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
        fileSize: '15.7 KB',
        tags: ['family', 'dependents'],
      ),
      PersonalDataItem(
        id: '6',
        title: 'Payment Information',
        description: 'Payment methods and transaction history',
        category: DataCategory.payments,
        recordCount: 6,
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        fileSize: '8.9 KB',
        tags: ['financial', 'payments'],
      ),
      PersonalDataItem(
        id: '7',
        title: 'Invoices',
        description: 'Medical invoices and billing records',
        category: DataCategory.invoices,
        recordCount: 10,
        lastUpdated: DateTime.now().subtract(const Duration(hours: 12)),
        fileSize: '32.1 KB',
        tags: ['billing', 'invoices'],
      ),
      PersonalDataItem(
        id: '8',
        title: 'Chat History',
        description: 'Conversations with healthcare providers',
        category: DataCategory.chatHistory,
        recordCount: 25,
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
        fileSize: '67.3 KB',
        tags: ['communication', 'chat'],
      ),
      PersonalDataItem(
        id: '9',
        title: 'Notifications',
        description: 'App notifications and alerts history',
        category: DataCategory.notifications,
        recordCount: 45,
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
        fileSize: '5.2 KB',
        tags: ['alerts', 'notifications'],
      ),
      PersonalDataItem(
        id: '10',
        title: 'Consent Settings',
        description: 'Privacy and consent preferences',
        category: DataCategory.consentSettings,
        recordCount: 1,
        lastUpdated: DateTime.now().subtract(const Duration(days: 7)),
        isRequired: true,
        canDelete: false,
        fileSize: '1.8 KB',
        tags: ['privacy', 'consent'],
      ),
      PersonalDataItem(
        id: '11',
        title: 'App Preferences',
        description: 'App settings and user preferences',
        category: DataCategory.preferences,
        recordCount: 1,
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        fileSize: '3.4 KB',
        tags: ['settings', 'preferences'],
      ),
      PersonalDataItem(
        id: '12',
        title: 'Documents',
        description: 'Uploaded medical documents and files',
        category: DataCategory.documents,
        recordCount: 7,
        lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
        fileSize: '156.7 KB',
        tags: ['documents', 'files'],
      ),
      PersonalDataItem(
        id: '13',
        title: 'Analytics Data',
        description: 'App usage analytics and performance data',
        category: DataCategory.analytics,
        recordCount: 120,
        lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
        fileSize: '89.4 KB',
        tags: ['analytics', 'usage'],
      ),
      // Additional deletable dummy data
      PersonalDataItem(
        id: '14',
        title: 'Old Appointments',
        description: 'Historical appointment records from previous years',
        category: DataCategory.appointments,
        recordCount: 23,
        lastUpdated: DateTime.now().subtract(const Duration(days: 365)),
        fileSize: '34.7 KB',
        tags: ['historical', 'old'],
      ),
      PersonalDataItem(
        id: '15',
        title: 'Expired Prescriptions',
        description: 'Prescriptions that are no longer active',
        category: DataCategory.prescriptions,
        recordCount: 8,
        lastUpdated: DateTime.now().subtract(const Duration(days: 180)),
        fileSize: '18.9 KB',
        tags: ['expired', 'inactive'],
      ),
      PersonalDataItem(
        id: '16',
        title: 'Test Results Archive',
        description: 'Old laboratory test results and reports',
        category: DataCategory.healthRecords,
        recordCount: 31,
        lastUpdated: DateTime.now().subtract(const Duration(days: 730)),
        fileSize: '78.3 KB',
        tags: ['archive', 'old'],
      ),
      PersonalDataItem(
        id: '17',
        title: 'Old Chat Messages',
        description: 'Conversations with doctors from previous years',
        category: DataCategory.chatHistory,
        recordCount: 156,
        lastUpdated: DateTime.now().subtract(const Duration(days: 500)),
        fileSize: '234.1 KB',
        tags: ['old', 'archive'],
      ),
      PersonalDataItem(
        id: '18',
        title: 'Old Notifications',
        description: 'Historical notification records',
        category: DataCategory.notifications,
        recordCount: 89,
        lastUpdated: DateTime.now().subtract(const Duration(days: 200)),
        fileSize: '12.4 KB',
        tags: ['historical', 'old'],
      ),
      PersonalDataItem(
        id: '19',
        title: 'Temporary Files',
        description: 'Temporary documents and cache files',
        category: DataCategory.documents,
        recordCount: 12,
        lastUpdated: DateTime.now().subtract(const Duration(days: 30)),
        fileSize: '45.6 KB',
        tags: ['temporary', 'cache'],
      ),
      PersonalDataItem(
        id: '20',
        title: 'Old Analytics',
        description: 'Historical usage analytics data',
        category: DataCategory.analytics,
        recordCount: 89,
        lastUpdated: DateTime.now().subtract(const Duration(days: 400)),
        fileSize: '67.2 KB',
        tags: ['historical', 'old'],
      ),
      PersonalDataItem(
        id: '21',
        title: 'Backup Data',
        description: 'Backup copies of important documents',
        category: DataCategory.documents,
        recordCount: 5,
        lastUpdated: DateTime.now().subtract(const Duration(days: 60)),
        fileSize: '89.3 KB',
        tags: ['backup', 'copies'],
      ),
      PersonalDataItem(
        id: '22',
        title: 'Old Payment Records',
        description: 'Historical payment transaction records',
        category: DataCategory.payments,
        recordCount: 34,
        lastUpdated: DateTime.now().subtract(const Duration(days: 300)),
        fileSize: '23.7 KB',
        tags: ['historical', 'old'],
      ),
      PersonalDataItem(
        id: '23',
        title: 'Old Invoices',
        description: 'Historical billing and invoice records',
        category: DataCategory.invoices,
        recordCount: 28,
        lastUpdated: DateTime.now().subtract(const Duration(days: 250)),
        fileSize: '56.8 KB',
        tags: ['historical', 'old'],
      ),
      PersonalDataItem(
        id: '24',
        title: 'Test Data',
        description: 'Test records created during development',
        category: DataCategory.healthRecords,
        recordCount: 7,
        lastUpdated: DateTime.now().subtract(const Duration(days: 15)),
        fileSize: '8.9 KB',
        tags: ['test', 'development'],
      ),
      PersonalDataItem(
        id: '25',
        title: 'Old X-Ray Images',
        description: 'Historical X-ray and imaging records',
        category: DataCategory.documents,
        recordCount: 3,
        lastUpdated: DateTime.now().subtract(const Duration(days: 400)),
        fileSize: '234.5 KB',
        tags: ['imaging', 'old'],
      ),
      PersonalDataItem(
        id: '26',
        title: 'Expired Insurance Claims',
        description: 'Old insurance claim records and documents',
        category: DataCategory.documents,
        recordCount: 12,
        lastUpdated: DateTime.now().subtract(const Duration(days: 180)),
        fileSize: '67.8 KB',
        tags: ['insurance', 'expired'],
      ),
      PersonalDataItem(
        id: '27',
        title: 'Old Medication History',
        description: 'Historical medication records and side effects',
        category: DataCategory.healthRecords,
        recordCount: 19,
        lastUpdated: DateTime.now().subtract(const Duration(days: 300)),
        fileSize: '45.2 KB',
        tags: ['medication', 'history'],
      ),
      PersonalDataItem(
        id: '28',
        title: 'Old Allergy Records',
        description: 'Historical allergy test results and records',
        category: DataCategory.healthRecords,
        recordCount: 6,
        lastUpdated: DateTime.now().subtract(const Duration(days: 250)),
        fileSize: '12.3 KB',
        tags: ['allergies', 'old'],
      ),
      PersonalDataItem(
        id: '29',
        title: 'Old Vaccination Records',
        description: 'Historical vaccination and immunization records',
        category: DataCategory.healthRecords,
        recordCount: 8,
        lastUpdated: DateTime.now().subtract(const Duration(days: 200)),
        fileSize: '18.7 KB',
        tags: ['vaccinations', 'old'],
      ),
      PersonalDataItem(
        id: '30',
        title: 'Old Emergency Contacts',
        description: 'Previous emergency contact information',
        category: DataCategory.profile,
        recordCount: 2,
        lastUpdated: DateTime.now().subtract(const Duration(days: 150)),
        fileSize: '1.2 KB',
        tags: ['contacts', 'old'],
      ),
      PersonalDataItem(
        id: '31',
        title: 'Old Insurance Information',
        description: 'Previous insurance policy details',
        category: DataCategory.profile,
        recordCount: 1,
        lastUpdated: DateTime.now().subtract(const Duration(days: 120)),
        fileSize: '2.8 KB',
        tags: ['insurance', 'old'],
      ),
      PersonalDataItem(
        id: '32',
        title: 'Old Address History',
        description: 'Previous residential address records',
        category: DataCategory.profile,
        recordCount: 3,
        lastUpdated: DateTime.now().subtract(const Duration(days: 90)),
        fileSize: '1.5 KB',
        tags: ['address', 'history'],
      ),
      PersonalDataItem(
        id: '33',
        title: 'Old Phone Numbers',
        description: 'Previous contact phone numbers',
        category: DataCategory.profile,
        recordCount: 2,
        lastUpdated: DateTime.now().subtract(const Duration(days: 60)),
        fileSize: '0.8 KB',
        tags: ['phone', 'old'],
      ),
      PersonalDataItem(
        id: '34',
        title: 'Old Email Addresses',
        description: 'Previous email address records',
        category: DataCategory.profile,
        recordCount: 2,
        lastUpdated: DateTime.now().subtract(const Duration(days: 45)),
        fileSize: '0.9 KB',
        tags: ['email', 'old'],
      ),
      // Essential current data items
      PersonalDataItem(
        id: '2',
        title: 'Health Records',
        description: 'Medical records, test results, and health history',
        category: DataCategory.healthRecords,
        recordCount: 15,
        lastUpdated: DateTime.now().subtract(const Duration(hours: 6)),
        fileSize: '45.2 KB',
        tags: ['medical', 'health'],
      ),
      PersonalDataItem(
        id: '3',
        title: 'Appointments',
        description: 'Scheduled appointments and visit history',
        category: DataCategory.appointments,
        recordCount: 8,
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        fileSize: '12.8 KB',
        tags: ['scheduling', 'visits'],
      ),
      PersonalDataItem(
        id: '4',
        title: 'Prescriptions',
        description: 'Medication prescriptions and refill history',
        category: DataCategory.prescriptions,
        recordCount: 12,
        lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
        fileSize: '28.5 KB',
        tags: ['medication', 'prescriptions'],
      ),
      PersonalDataItem(
        id: '5',
        title: 'Family Members',
        description: 'Family member profiles and health records',
        category: DataCategory.familyMembers,
        recordCount: 4,
        lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
        fileSize: '15.7 KB',
        tags: ['family', 'dependents'],
      ),
      PersonalDataItem(
        id: '6',
        title: 'Payment Information',
        description: 'Payment methods and transaction history',
        category: DataCategory.payments,
        recordCount: 6,
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        fileSize: '8.9 KB',
        tags: ['financial', 'payments'],
      ),
      PersonalDataItem(
        id: '7',
        title: 'Invoices',
        description: 'Medical invoices and billing records',
        category: DataCategory.invoices,
        recordCount: 10,
        lastUpdated: DateTime.now().subtract(const Duration(hours: 12)),
        fileSize: '32.1 KB',
        tags: ['billing', 'invoices'],
      ),
      PersonalDataItem(
        id: '8',
        title: 'Chat History',
        description: 'Conversations with healthcare providers',
        category: DataCategory.chatHistory,
        recordCount: 25,
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
        fileSize: '67.3 KB',
        tags: ['communication', 'chat'],
      ),
      PersonalDataItem(
        id: '9',
        title: 'Notifications',
        description: 'App notifications and alerts history',
        category: DataCategory.notifications,
        recordCount: 45,
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
        fileSize: '5.2 KB',
        tags: ['alerts', 'notifications'],
      ),
      PersonalDataItem(
        id: '10',
        title: 'Consent Settings',
        description: 'Privacy and consent preferences',
        category: DataCategory.consentSettings,
        recordCount: 1,
        lastUpdated: DateTime.now().subtract(const Duration(days: 7)),
        isRequired: true,
        canDelete: false,
        fileSize: '1.8 KB',
        tags: ['privacy', 'consent'],
      ),
      PersonalDataItem(
        id: '11',
        title: 'App Preferences',
        description: 'App settings and user preferences',
        category: DataCategory.preferences,
        recordCount: 1,
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        fileSize: '3.4 KB',
        tags: ['settings', 'preferences'],
      ),
      PersonalDataItem(
        id: '12',
        title: 'Documents',
        description: 'Uploaded medical documents and files',
        category: DataCategory.documents,
        recordCount: 7,
        lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
        fileSize: '156.7 KB',
        tags: ['documents', 'files'],
      ),
      PersonalDataItem(
        id: '13',
        title: 'Analytics Data',
        description: 'App usage analytics and performance data',
        category: DataCategory.analytics,
        recordCount: 120,
        lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
        fileSize: '89.4 KB',
        tags: ['analytics', 'usage'],
      ),
    ];
  }

  Future<void> _generateSummary() async {
    final recordsByCategory = <DataCategory, int>{};
    int totalRecords = 0;
    DateTime lastActivity = DateTime.now().subtract(const Duration(days: 365));

    for (final item in _dataItems) {
      recordsByCategory[item.category] = (recordsByCategory[item.category] ?? 0) + item.recordCount;
      totalRecords += item.recordCount;
      if (item.lastUpdated.isAfter(lastActivity)) {
        lastActivity = item.lastUpdated;
      }
    }

    _summary = PersonalDataSummary(
      totalRecords: totalRecords,
      recordsByCategory: recordsByCategory,
      lastActivity: lastActivity,
      totalSize: '456.2 KB',
      availableCategories: DataCategory.values.where((c) => c != DataCategory.all).toList(),
    );
  }

  // Export personal data
  Future<DataExportRequest> exportData({
    required List<DataCategory> categories,
    required DataFormat format,
    Function(double)? onProgress,
  }) async {
    final request = DataExportRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      categories: categories,
      format: format,
      requestedAt: DateTime.now(),
    );

    _exportRequests.insert(0, request);

    try {
      // Simulate export process
      await _simulateExportProcess(request, onProgress);

      final downloadUrl = await _generateExportFile(request);
      
      final updatedRequest = request.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
        downloadUrl: downloadUrl,
      );

      final index = _exportRequests.indexWhere((r) => r.id == request.id);
      if (index != -1) {
        _exportRequests[index] = updatedRequest;
      }

      return updatedRequest;
    } catch (e) {
      final failedRequest = request.copyWith(
        isFailed: true,
        errorMessage: e.toString(),
      );

      final index = _exportRequests.indexWhere((r) => r.id == request.id);
      if (index != -1) {
        _exportRequests[index] = failedRequest;
      }

      rethrow;
    }
  }

  Future<void> _simulateExportProcess(DataExportRequest request, Function(double)? onProgress) async {
    const totalSteps = 5;
    
    for (int i = 0; i < totalSteps; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      onProgress?.call((i + 1) / totalSteps);
    }
  }

  Future<String> _generateExportFile(DataExportRequest request) async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory(path.join(directory.path, 'exports'));
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final fileName = 'personal_data_${request.id}.${request.format.name}';
    final filePath = path.join(exportDir.path, fileName);
    final file = File(filePath);

    // Generate mock export data
    final exportData = await _generateExportData(request.categories, request.format);
    await file.writeAsString(exportData);

    return filePath;
  }

  Future<String> _generateExportData(List<DataCategory> categories, DataFormat format) async {
    final data = <String, dynamic>{
      'exportDate': DateTime.now().toIso8601String(),
      'categories': categories.map((c) => c.name).toList(),
      'format': format.name,
      'data': <String, dynamic>{},
    };

    // Add mock data for each category
    for (final category in categories) {
      switch (category) {
        case DataCategory.profile:
          data['data']['profile'] = {
            'name': 'John Doe',
            'email': 'john.doe@example.com',
            'phone': '+1-555-123-4567',
            'dateOfBirth': '1990-01-01',
            'address': '123 Main St, City, State 12345',
          };
          break;
        case DataCategory.healthRecords:
          data['data']['healthRecords'] = [
            {
              'id': 'hr_001',
              'title': 'Annual Physical Exam',
              'date': '2024-01-15',
              'provider': 'Dr. Sarah Johnson',
              'category': 'Vital Signs',
            },
            {
              'id': 'hr_002',
              'title': 'Blood Test Results',
              'date': '2024-01-10',
              'provider': 'LabCorp',
              'category': 'Lab Results',
            },
          ];
          break;
        case DataCategory.appointments:
          data['data']['appointments'] = [
            {
              'id': 'apt_001',
              'date': '2024-02-15',
              'time': '10:00 AM',
              'doctor': 'Dr. Michael Chen',
              'specialty': 'Cardiology',
              'status': 'Scheduled',
            },
          ];
          break;
        case DataCategory.prescriptions:
          data['data']['prescriptions'] = [
            {
              'id': 'rx_001',
              'medication': 'Metformin',
              'dosage': '500mg',
              'frequency': 'Twice daily',
              'prescribedDate': '2024-01-20',
              'status': 'Active',
            },
          ];
          break;
        default:
          data['data'][category.name] = {
            'message': 'Mock data for ${category.name}',
            'recordCount': _dataItems
                .where((item) => item.category == category)
                .firstOrNull?.recordCount ?? 0,
          };
      }
    }

    switch (format) {
      case DataFormat.json:
        return jsonEncode(data);
      case DataFormat.csv:
        return _convertToCsv(data);
      case DataFormat.xml:
        return _convertToXml(data);
      case DataFormat.pdf:
        return _convertToPdf(data);
    }
  }

  String _convertToCsv(Map<String, dynamic> data) {
    // Simple CSV conversion
    final csv = StringBuffer();
    csv.writeln('Category,Field,Value');
    
    for (final category in data['data'].keys) {
      final categoryData = data['data'][category];
      if (categoryData is Map) {
        for (final field in categoryData.keys) {
          csv.writeln('$category,$field,${categoryData[field]}');
        }
      }
    }
    
    return csv.toString();
  }

  String _convertToXml(Map<String, dynamic> data) {
    // Simple XML conversion
    final xml = StringBuffer();
    xml.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    xml.writeln('<personalData>');
    xml.writeln('  <exportDate>${data['exportDate']}</exportDate>');
    xml.writeln('  <categories>');
    for (final category in data['categories']) {
      xml.writeln('    <category>$category</category>');
    }
    xml.writeln('  </categories>');
    xml.writeln('  <data>');
    // Add data elements here
    xml.writeln('  </data>');
    xml.writeln('</personalData>');
    
    return xml.toString();
  }

  String _convertToPdf(Map<String, dynamic> data) {
    // Simple text representation for PDF
    final pdf = StringBuffer();
    pdf.writeln('PERSONAL DATA EXPORT');
    pdf.writeln('====================');
    pdf.writeln('Export Date: ${data['exportDate']}');
    pdf.writeln('Categories: ${data['categories'].join(', ')}');
    pdf.writeln('Format: ${data['format']}');
    pdf.writeln('');
    pdf.writeln('DATA SUMMARY');
    pdf.writeln('============');
    
    for (final category in data['data'].keys) {
      pdf.writeln('$category:');
      final categoryData = data['data'][category];
      if (categoryData is Map) {
        for (final field in categoryData.keys) {
          pdf.writeln('  $field: ${categoryData[field]}');
        }
      }
      pdf.writeln('');
    }
    
    return pdf.toString();
  }

  // Delete personal data
  Future<DataDeletionRequest> deleteData({
    required List<DataCategory> categories,
    required String reason,
    bool permanent = true,
    Function(double)? onProgress,
  }) async {
    final request = DataDeletionRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      categories: categories,
      requestedAt: DateTime.now(),
      reason: reason,
      permanent: permanent,
    );

    _deletionRequests.insert(0, request);

    try {
      // Simulate deletion process
      await _simulateDeletionProcess(request, onProgress);

      final updatedRequest = request.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      final index = _deletionRequests.indexWhere((r) => r.id == request.id);
      if (index != -1) {
        _deletionRequests[index] = updatedRequest;
      }

      // Remove deleted items from data items list
      _dataItems.removeWhere((item) => categories.contains(item.category));

      return updatedRequest;
    } catch (e) {
      final failedRequest = request.copyWith(
        isFailed: true,
        errorMessage: e.toString(),
      );

      final index = _deletionRequests.indexWhere((r) => r.id == request.id);
      if (index != -1) {
        _deletionRequests[index] = failedRequest;
      }

      rethrow;
    }
  }

  Future<void> _simulateDeletionProcess(DataDeletionRequest request, Function(double)? onProgress) async {
    const totalSteps = 3;
    
    for (int i = 0; i < totalSteps; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      onProgress?.call((i + 1) / totalSteps);
    }
  }

  // Toggle selection of data items
  void toggleDataItemSelection(String itemId) {
    final index = _dataItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _dataItems[index] = _dataItems[index].copyWith(
        isSelected: !_dataItems[index].isSelected,
      );
    }
  }

  // Select all data items
  void selectAllDataItems() {
    _dataItems = _dataItems.map((item) => item.copyWith(isSelected: true)).toList();
  }

  // Deselect all data items
  void deselectAllDataItems() {
    _dataItems = _dataItems.map((item) => item.copyWith(isSelected: false)).toList();
  }

  // Get selected data items
  List<PersonalDataItem> get selectedDataItems {
    return _dataItems.where((item) => item.isSelected).toList();
  }

  // Get selected categories
  List<DataCategory> get selectedCategories {
    return selectedDataItems.map((item) => item.category).toList();
  }

  // Clear export requests
  void clearExportRequests() {
    _exportRequests.clear();
  }

  // Clear deletion requests
  void clearDeletionRequests() {
    _deletionRequests.clear();
  }

  // Get export request by ID
  DataExportRequest? getExportRequest(String id) {
    try {
      return _exportRequests.firstWhere((request) => request.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get deletion request by ID
  DataDeletionRequest? getDeletionRequest(String id) {
    try {
      return _deletionRequests.firstWhere((request) => request.id == id);
    } catch (e) {
      return null;
    }
  }
} 