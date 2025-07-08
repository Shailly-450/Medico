import 'package:flutter/material.dart';

// Workflow stages enum
enum WorkflowStage {
  consultation,
  testing,
  surgery,
  completed,
}

// Workflow status enum
enum WorkflowStatus {
  pending,
  inProgress,
  completed,
  cancelled,
  onHold,
}

// Stage type for different medical procedures
enum StageType {
  consultation,
  diagnosticTest,
  labTest,
  imaging,
  procedure,
  surgery,
  followUp,
}

class WorkflowStageData {
  final String id;
  final StageType type;
  final String title;
  final String description;
  final WorkflowStatus status;
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final String? doctorId;
  final String? doctorName;
  final String? location;
  final List<String> requirements;
  final List<String> notes;
  final Map<String, dynamic>? results;
  final double? cost;
  final bool isRequired;
  final int order;

  WorkflowStageData({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.status,
    this.scheduledDate,
    this.completedDate,
    this.doctorId,
    this.doctorName,
    this.location,
    this.requirements = const [],
    this.notes = const [],
    this.results,
    this.cost,
    this.isRequired = true,
    required this.order,
  });

  WorkflowStageData copyWith({
    String? id,
    StageType? type,
    String? title,
    String? description,
    WorkflowStatus? status,
    DateTime? scheduledDate,
    DateTime? completedDate,
    String? doctorId,
    String? doctorName,
    String? location,
    List<String>? requirements,
    List<String>? notes,
    Map<String, dynamic>? results,
    double? cost,
    bool? isRequired,
    int? order,
  }) {
    return WorkflowStageData(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedDate: completedDate ?? this.completedDate,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      location: location ?? this.location,
      requirements: requirements ?? this.requirements,
      notes: notes ?? this.notes,
      results: results ?? this.results,
      cost: cost ?? this.cost,
      isRequired: isRequired ?? this.isRequired,
      order: order ?? this.order,
    );
  }

  factory WorkflowStageData.fromJson(Map<String, dynamic> json) {
    return WorkflowStageData(
      id: json['id'] ?? '',
      type: StageType.values.firstWhere(
        (e) => e.toString() == 'StageType.${json['type']}',
        orElse: () => StageType.consultation,
      ),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: WorkflowStatus.values.firstWhere(
        (e) => e.toString() == 'WorkflowStatus.${json['status']}',
        orElse: () => WorkflowStatus.pending,
      ),
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'])
          : null,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
      doctorId: json['doctorId'],
      doctorName: json['doctorName'],
      location: json['location'],
      requirements: List<String>.from(json['requirements'] ?? []),
      notes: List<String>.from(json['notes'] ?? []),
      results: json['results'],
      cost: json['cost']?.toDouble(),
      isRequired: json['isRequired'] ?? true,
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'status': status.toString().split('.').last,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'doctorId': doctorId,
      'doctorName': doctorName,
      'location': location,
      'requirements': requirements,
      'notes': notes,
      'results': results,
      'cost': cost,
      'isRequired': isRequired,
      'order': order,
    };
  }
}

class MedicalWorkflow {
  final String id;
  final String patientId;
  final String patientName;
  final String condition;
  final String primaryDoctorId;
  final String primaryDoctorName;
  final WorkflowStage currentStage;
  final WorkflowStatus overallStatus;
  final DateTime createdDate;
  final DateTime? lastUpdated;
  final List<WorkflowStageData> stages;
  final double totalCost;
  final String? notes;
  final bool isUrgent;

  MedicalWorkflow({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.condition,
    required this.primaryDoctorId,
    required this.primaryDoctorName,
    required this.currentStage,
    required this.overallStatus,
    required this.createdDate,
    this.lastUpdated,
    required this.stages,
    this.totalCost = 0.0,
    this.notes,
    this.isUrgent = false,
  });

  // Get current stage data
  WorkflowStageData? get currentStageData {
    return stages
        .where((stage) => stage.status == WorkflowStatus.inProgress)
        .cast<WorkflowStageData?>()
        .firstWhere((stage) => stage != null, orElse: () => null);
  }

  // Get next stage
  WorkflowStageData? get nextStage {
    final currentStageIndex = stages.indexWhere(
      (stage) => stage.status == WorkflowStatus.inProgress,
    );
    if (currentStageIndex >= 0 && currentStageIndex < stages.length - 1) {
      return stages[currentStageIndex + 1];
    }
    return null;
  }

  // Get completed stages
  List<WorkflowStageData> get completedStages {
    return stages
        .where((stage) => stage.status == WorkflowStatus.completed)
        .toList();
  }

  // Get pending stages
  List<WorkflowStageData> get pendingStages {
    return stages
        .where((stage) => stage.status == WorkflowStatus.pending)
        .toList();
  }

  // Calculate progress percentage
  double get progressPercentage {
    if (stages.isEmpty) return 0.0;
    final completedCount = completedStages.length;
    return (completedCount / stages.length) * 100;
  }

  // Get stage by type
  List<WorkflowStageData> getStagesByType(StageType type) {
    return stages.where((stage) => stage.type == type).toList();
  }

  // Check if workflow is completed
  bool get isCompleted {
    return overallStatus == WorkflowStatus.completed ||
        stages.every((stage) => stage.status == WorkflowStatus.completed);
  }

  // Get workflow duration
  Duration? get duration {
    if (lastUpdated != null) {
      return lastUpdated!.difference(createdDate);
    }
    return null;
  }

  MedicalWorkflow copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? condition,
    String? primaryDoctorId,
    String? primaryDoctorName,
    WorkflowStage? currentStage,
    WorkflowStatus? overallStatus,
    DateTime? createdDate,
    DateTime? lastUpdated,
    List<WorkflowStageData>? stages,
    double? totalCost,
    String? notes,
    bool? isUrgent,
  }) {
    return MedicalWorkflow(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      condition: condition ?? this.condition,
      primaryDoctorId: primaryDoctorId ?? this.primaryDoctorId,
      primaryDoctorName: primaryDoctorName ?? this.primaryDoctorName,
      currentStage: currentStage ?? this.currentStage,
      overallStatus: overallStatus ?? this.overallStatus,
      createdDate: createdDate ?? this.createdDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      stages: stages ?? this.stages,
      totalCost: totalCost ?? this.totalCost,
      notes: notes ?? this.notes,
      isUrgent: isUrgent ?? this.isUrgent,
    );
  }

  factory MedicalWorkflow.fromJson(Map<String, dynamic> json) {
    return MedicalWorkflow(
      id: json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      patientName: json['patientName'] ?? '',
      condition: json['condition'] ?? '',
      primaryDoctorId: json['primaryDoctorId'] ?? '',
      primaryDoctorName: json['primaryDoctorName'] ?? '',
      currentStage: WorkflowStage.values.firstWhere(
        (e) => e.toString() == 'WorkflowStage.${json['currentStage']}',
        orElse: () => WorkflowStage.consultation,
      ),
      overallStatus: WorkflowStatus.values.firstWhere(
        (e) => e.toString() == 'WorkflowStatus.${json['overallStatus']}',
        orElse: () => WorkflowStatus.pending,
      ),
      createdDate: DateTime.parse(json['createdDate']),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
      stages: (json['stages'] as List? ?? [])
          .map((stage) => WorkflowStageData.fromJson(stage))
          .toList(),
      totalCost: (json['totalCost'] ?? 0.0).toDouble(),
      notes: json['notes'],
      isUrgent: json['isUrgent'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'condition': condition,
      'primaryDoctorId': primaryDoctorId,
      'primaryDoctorName': primaryDoctorName,
      'currentStage': currentStage.toString().split('.').last,
      'overallStatus': overallStatus.toString().split('.').last,
      'createdDate': createdDate.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'stages': stages.map((stage) => stage.toJson()).toList(),
      'totalCost': totalCost,
      'notes': notes,
      'isUrgent': isUrgent,
    };
  }
}
