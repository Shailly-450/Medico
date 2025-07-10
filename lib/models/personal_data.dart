import 'package:flutter/material.dart';

enum DataCategory {
  profile,
  healthRecords,
  appointments,
  prescriptions,
  medications,
  familyMembers,
  payments,
  invoices,
  chatHistory,
  notifications,
  consentSettings,
  preferences,
  documents,
  analytics,
  all,
}

enum DataFormat {
  json,
  csv,
  pdf,
  xml,
}

class PersonalDataItem {
  final String id;
  final String title;
  final String description;
  final DataCategory category;
  final int recordCount;
  final DateTime lastUpdated;
  final bool isSelected;
  final bool isRequired;
  final bool canDelete;
  final bool canExport;
  final String? fileSize;
  final List<String>? tags;

  PersonalDataItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.recordCount,
    required this.lastUpdated,
    this.isSelected = false,
    this.isRequired = false,
    this.canDelete = true,
    this.canExport = true,
    this.fileSize,
    this.tags,
  });

  PersonalDataItem copyWith({
    String? id,
    String? title,
    String? description,
    DataCategory? category,
    int? recordCount,
    DateTime? lastUpdated,
    bool? isSelected,
    bool? isRequired,
    bool? canDelete,
    bool? canExport,
    String? fileSize,
    List<String>? tags,
  }) {
    return PersonalDataItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      recordCount: recordCount ?? this.recordCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSelected: isSelected ?? this.isSelected,
      isRequired: isRequired ?? this.isRequired,
      canDelete: canDelete ?? this.canDelete,
      canExport: canExport ?? this.canExport,
      fileSize: fileSize ?? this.fileSize,
      tags: tags ?? this.tags,
    );
  }
}

class DataExportRequest {
  final String id;
  final List<DataCategory> categories;
  final DataFormat format;
  final DateTime requestedAt;
  final DateTime? completedAt;
  final String? downloadUrl;
  final String? errorMessage;
  final bool isCompleted;
  final bool isFailed;

  DataExportRequest({
    required this.id,
    required this.categories,
    required this.format,
    required this.requestedAt,
    this.completedAt,
    this.downloadUrl,
    this.errorMessage,
    this.isCompleted = false,
    this.isFailed = false,
  });

  DataExportRequest copyWith({
    String? id,
    List<DataCategory>? categories,
    DataFormat? format,
    DateTime? requestedAt,
    DateTime? completedAt,
    String? downloadUrl,
    String? errorMessage,
    bool? isCompleted,
    bool? isFailed,
  }) {
    return DataExportRequest(
      id: id ?? this.id,
      categories: categories ?? this.categories,
      format: format ?? this.format,
      requestedAt: requestedAt ?? this.requestedAt,
      completedAt: completedAt ?? this.completedAt,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      errorMessage: errorMessage ?? this.errorMessage,
      isCompleted: isCompleted ?? this.isCompleted,
      isFailed: isFailed ?? this.isFailed,
    );
  }
}

class DataDeletionRequest {
  final String id;
  final List<DataCategory> categories;
  final DateTime requestedAt;
  final DateTime? completedAt;
  final String? errorMessage;
  final bool isCompleted;
  final bool isFailed;
  final String reason;
  final bool permanent;

  DataDeletionRequest({
    required this.id,
    required this.categories,
    required this.requestedAt,
    required this.reason,
    this.completedAt,
    this.errorMessage,
    this.isCompleted = false,
    this.isFailed = false,
    this.permanent = true,
  });

  DataDeletionRequest copyWith({
    String? id,
    List<DataCategory>? categories,
    DateTime? requestedAt,
    DateTime? completedAt,
    String? errorMessage,
    bool? isCompleted,
    bool? isFailed,
    String? reason,
    bool? permanent,
  }) {
    return DataDeletionRequest(
      id: id ?? this.id,
      categories: categories ?? this.categories,
      requestedAt: requestedAt ?? this.requestedAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      isCompleted: isCompleted ?? this.isCompleted,
      isFailed: isFailed ?? this.isFailed,
      reason: reason ?? this.reason,
      permanent: permanent ?? this.permanent,
    );
  }
}

class PersonalDataSummary {
  final int totalRecords;
  final Map<DataCategory, int> recordsByCategory;
  final DateTime lastActivity;
  final String totalSize;
  final List<DataCategory> availableCategories;

  PersonalDataSummary({
    required this.totalRecords,
    required this.recordsByCategory,
    required this.lastActivity,
    required this.totalSize,
    required this.availableCategories,
  });
} 