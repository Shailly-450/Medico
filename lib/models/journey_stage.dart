enum JourneyStageType {
  consult,
  test,
  surgery,
}

enum JourneyStatus {
  notStarted,
  inProgress,
  completed,
  cancelled,
}

class JourneyStage {
  final String id;
  final JourneyStageType type;
  final String title;
  final String description;
  final JourneyStatus status;
  final DateTime? startDate;
  final DateTime? completedDate;
  final String? notes;
  final List<String> attachments;
  final Map<String, dynamic> metadata;

  JourneyStage({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.status = JourneyStatus.notStarted,
    this.startDate,
    this.completedDate,
    this.notes,
    this.attachments = const [],
    this.metadata = const {},
  });

  factory JourneyStage.fromJson(Map<String, dynamic> json) {
    return JourneyStage(
      id: json['id'] as String,
      type: JourneyStageType.values.firstWhere(
        (e) => e.toString() == 'JourneyStageType.${json['type']}',
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      status: JourneyStatus.values.firstWhere(
        (e) => e.toString() == 'JourneyStatus.${json['status']}',
      ),
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate'] as String) 
          : null,
      completedDate: json['completedDate'] != null 
          ? DateTime.parse(json['completedDate'] as String) 
          : null,
      notes: json['notes'] as String?,
      attachments: List<String>.from(json['attachments'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'status': status.toString().split('.').last,
      'startDate': startDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'notes': notes,
      'attachments': attachments,
      'metadata': metadata,
    };
  }

  JourneyStage copyWith({
    String? id,
    JourneyStageType? type,
    String? title,
    String? description,
    JourneyStatus? status,
    DateTime? startDate,
    DateTime? completedDate,
    String? notes,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
  }) {
    return JourneyStage(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      completedDate: completedDate ?? this.completedDate,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
    );
  }
}

class MedicalJourney {
  final String id;
  final String patientId;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<JourneyStage> stages;
  final String? doctorId;
  final String? hospitalId;
  final Map<String, dynamic> metadata;

  MedicalJourney({
    required this.id,
    required this.patientId,
    required this.title,
    required this.description,
    required this.createdAt,
    this.completedAt,
    required this.stages,
    this.doctorId,
    this.hospitalId,
    this.metadata = const {},
  });

  factory MedicalJourney.fromJson(Map<String, dynamic> json) {
    return MedicalJourney(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
      stages: (json['stages'] as List<dynamic>)
          .map((stage) => JourneyStage.fromJson(stage as Map<String, dynamic>))
          .toList(),
      doctorId: json['doctorId'] as String?,
      hospitalId: json['hospitalId'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'stages': stages.map((stage) => stage.toJson()).toList(),
      'doctorId': doctorId,
      'hospitalId': hospitalId,
      'metadata': metadata,
    };
  }

  double get progressPercentage {
    if (stages.isEmpty) return 0.0;
    final completedStages = stages.where((stage) => 
        stage.status == JourneyStatus.completed).length;
    return completedStages / stages.length;
  }

  JourneyStatus get overallStatus {
    if (stages.isEmpty) return JourneyStatus.notStarted;
    
    final hasCompleted = stages.any((stage) => 
        stage.status == JourneyStatus.completed);
    final hasInProgress = stages.any((stage) => 
        stage.status == JourneyStatus.inProgress);
    final hasCancelled = stages.any((stage) => 
        stage.status == JourneyStatus.cancelled);
    
    if (hasCancelled) return JourneyStatus.cancelled;
    if (hasInProgress) return JourneyStatus.inProgress;
    if (hasCompleted) return JourneyStatus.completed;
    return JourneyStatus.notStarted;
  }
} 