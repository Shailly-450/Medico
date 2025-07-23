import 'package:flutter/material.dart';

enum TestCheckupType {
  bloodTest,
  urineTest,
  xRay,
  mri,
  ctScan,
  ultrasound,
  ecg,
  endoscopy,
  colonoscopy,
  mammogram,
  papSmear,
  dentalCheckup,
  eyeExam,
  hearingTest,
  skinCheck,
  physicalExam,
  vaccination,
  allergyTest,
  stressTest,
  sleepStudy,
  custom,
}

enum TestCheckupStatus {
  scheduled,
  completed,
  cancelled,
  rescheduled,
  overdue,
  pendingResults,
}

enum TestCheckupPriority { low, medium, high, urgent }

class TestCheckup {
  final String id;
  final String title;
  final String description;
  final TestCheckupType type;
  final TestCheckupStatus status;
  final TestCheckupPriority priority;
  final DateTime scheduledDate;
  final TimeOfDay scheduledTime;
  final String? location;
  final String? doctorName;
  final String? doctorSpecialty;
  final String? doctorImage;
  final double? estimatedCost;
  final String? instructions;
  final bool requiresFasting;
  final bool requiresPreparation;
  final String? preparationInstructions;
  final List<String> requiredDocuments;
  final bool hasReminder;
  final DateTime? reminderTime;
  final DateTime? completedDate;
  final String? results;
  final String? resultsFile;
  final bool isRecurring;
  final String? recurrencePattern; // "monthly", "quarterly", "yearly", "custom"
  final DateTime? nextDueDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  TestCheckup({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.status = TestCheckupStatus.scheduled,
    this.priority = TestCheckupPriority.medium,
    required this.scheduledDate,
    required this.scheduledTime,
    this.location,
    this.doctorName,
    this.doctorSpecialty,
    this.doctorImage,
    this.estimatedCost,
    this.instructions,
    this.requiresFasting = false,
    this.requiresPreparation = false,
    this.preparationInstructions,
    this.requiredDocuments = const [],
    this.hasReminder = true,
    this.reminderTime,
    this.completedDate,
    this.results,
    this.resultsFile,
    this.isRecurring = false,
    this.recurrencePattern,
    this.nextDueDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Check if checkup is overdue
  bool get isOverdue {
    if (status == TestCheckupStatus.completed) return false;
    return DateTime.now().isAfter(scheduledDate);
  }

  // Check if checkup is today
  bool get isToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
        scheduledDate.month == now.month &&
        scheduledDate.day == now.day;
  }

  // Check if checkup is upcoming (within next 7 days)
  bool get isUpcoming {
    if (status == TestCheckupStatus.completed) return false;
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    return scheduledDate.isAfter(now) && scheduledDate.isBefore(nextWeek);
  }

  // Get days until checkup
  int get daysUntilCheckup {
    if (status == TestCheckupStatus.completed) return 0;
    return scheduledDate.difference(DateTime.now()).inDays;
  }

  // Get formatted scheduled date and time
  String get formattedDateTime {
    final date =
        '${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year}';
    final time =
        '${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}';
    return '$date at $time';
  }

  // Get type display name
  String get typeDisplayName {
    switch (type) {
      case TestCheckupType.bloodTest:
        return 'Blood Test';
      case TestCheckupType.urineTest:
        return 'Urine Test';
      case TestCheckupType.xRay:
        return 'X-Ray';
      case TestCheckupType.mri:
        return 'MRI Scan';
      case TestCheckupType.ctScan:
        return 'CT Scan';
      case TestCheckupType.ultrasound:
        return 'Ultrasound';
      case TestCheckupType.ecg:
        return 'ECG';
      case TestCheckupType.endoscopy:
        return 'Endoscopy';
      case TestCheckupType.colonoscopy:
        return 'Colonoscopy';
      case TestCheckupType.mammogram:
        return 'Mammogram';
      case TestCheckupType.papSmear:
        return 'Pap Smear';
      case TestCheckupType.dentalCheckup:
        return 'Dental Checkup';
      case TestCheckupType.eyeExam:
        return 'Eye Exam';
      case TestCheckupType.hearingTest:
        return 'Hearing Test';
      case TestCheckupType.skinCheck:
        return 'Skin Check';
      case TestCheckupType.physicalExam:
        return 'Physical Exam';
      case TestCheckupType.vaccination:
        return 'Vaccination';
      case TestCheckupType.allergyTest:
        return 'Allergy Test';
      case TestCheckupType.stressTest:
        return 'Stress Test';
      case TestCheckupType.sleepStudy:
        return 'Sleep Study';
      case TestCheckupType.custom:
        return 'Custom Test';
    }
  }

  // Get status display name
  String get statusDisplayName {
    switch (status) {
      case TestCheckupStatus.scheduled:
        return 'Scheduled';
      case TestCheckupStatus.completed:
        return 'Completed';
      case TestCheckupStatus.cancelled:
        return 'Cancelled';
      case TestCheckupStatus.rescheduled:
        return 'Rescheduled';
      case TestCheckupStatus.overdue:
        return 'Overdue';
      case TestCheckupStatus.pendingResults:
        return 'Pending Results';
    }
  }

  // Get priority display name
  String get priorityDisplayName {
    switch (priority) {
      case TestCheckupPriority.low:
        return 'Low';
      case TestCheckupPriority.medium:
        return 'Medium';
      case TestCheckupPriority.high:
        return 'High';
      case TestCheckupPriority.urgent:
        return 'Urgent';
    }
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString(),
      'status': status.toString(),
      'priority': priority.toString(),
      'scheduledDate': scheduledDate.toIso8601String(),
      'scheduledTime': '${scheduledTime.hour}:${scheduledTime.minute}',
      'location': location,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'doctorImage': doctorImage,
      'estimatedCost': estimatedCost,
      'instructions': instructions,
      'requiresFasting': requiresFasting,
      'requiresPreparation': requiresPreparation,
      'preparationInstructions': preparationInstructions,
      'requiredDocuments': requiredDocuments,
      'hasReminder': hasReminder,
      'reminderTime': reminderTime?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'results': results,
      'resultsFile': resultsFile,
      'isRecurring': isRecurring,
      'recurrencePattern': recurrencePattern,
      'nextDueDate': nextDueDate?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory TestCheckup.fromJson(Map<String, dynamic> json) {
    // Parse scheduled time from the scheduledAt field
    final scheduledDateTime = DateTime.parse(json['scheduledAt']);
    final scheduledTime = TimeOfDay(
      hour: scheduledDateTime.hour,
      minute: scheduledDateTime.minute,
    );

    // Map status string to enum
    final statusStr = json['status'].toString().toLowerCase();
    final status = TestCheckupStatus.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == statusStr,
      orElse: () => TestCheckupStatus.scheduled,
    );

    // Map type string to enum
    final typeStr = json['type'].toString().replaceAll('-', '').toLowerCase();
    final type = TestCheckupType.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == typeStr,
      orElse: () => TestCheckupType.custom,
    );

    // Map priority string to enum
    final priorityStr = json['priority'].toString().toLowerCase();
    final priority = TestCheckupPriority.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == priorityStr,
      orElse: () => TestCheckupPriority.medium,
    );

    return TestCheckup(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['name'] ?? '',
      description: json['description'] ?? '',
      type: type,
      status: status,
      priority: priority,
      scheduledDate: scheduledDateTime,
      scheduledTime: scheduledTime,
      location: json['provider']?['clinic'],
      doctorName: json['provider']?['name'],
      doctorSpecialty: json['provider']?['specialty'],
      estimatedCost: (json['cost'] ?? 0.0).toDouble(),
      instructions: json['instructions'],
      requiresFasting: json['requiresFasting'] ?? false,
      requiresPreparation: json['requiresPreparation'] ?? false,
      preparationInstructions: json['preparationInstructions'],
      requiredDocuments: List<String>.from(json['requiredDocuments'] ?? []),
      hasReminder: json['hasReminder'] ?? true,
      reminderTime: json['reminderTime'] != null
          ? DateTime.parse(json['reminderTime'])
          : null,
      completedDate: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      results: json['results'],
      resultsFile: json['resultsFile'],
      isRecurring: json['isRecurring'] ?? false,
      recurrencePattern: json['recurrencePattern'],
      nextDueDate: json['nextDueDate'] != null
          ? DateTime.parse(json['nextDueDate'])
          : null,
      notes: json['notes'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  // Copy with method for updates
  TestCheckup copyWith({
    String? id,
    String? title,
    String? description,
    TestCheckupType? type,
    TestCheckupStatus? status,
    TestCheckupPriority? priority,
    DateTime? scheduledDate,
    TimeOfDay? scheduledTime,
    String? location,
    String? doctorName,
    String? doctorSpecialty,
    String? doctorImage,
    double? estimatedCost,
    String? instructions,
    bool? requiresFasting,
    bool? requiresPreparation,
    String? preparationInstructions,
    List<String>? requiredDocuments,
    bool? hasReminder,
    DateTime? reminderTime,
    DateTime? completedDate,
    String? results,
    String? resultsFile,
    bool? isRecurring,
    String? recurrencePattern,
    DateTime? nextDueDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TestCheckup(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      location: location ?? this.location,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      doctorImage: doctorImage ?? this.doctorImage,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      instructions: instructions ?? this.instructions,
      requiresFasting: requiresFasting ?? this.requiresFasting,
      requiresPreparation: requiresPreparation ?? this.requiresPreparation,
      preparationInstructions:
          preparationInstructions ?? this.preparationInstructions,
      requiredDocuments: requiredDocuments ?? this.requiredDocuments,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderTime: reminderTime ?? this.reminderTime,
      completedDate: completedDate ?? this.completedDate,
      results: results ?? this.results,
      resultsFile: resultsFile ?? this.resultsFile,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
