import 'package:flutter/material.dart';

// AI Chat Message Types
enum MessageType {
  user,
  ai,
  system,
}

// Symptom Severity Levels
enum SymptomSeverity {
  mild,
  moderate,
  severe,
  emergency,
}

// Prediction Confidence Levels
enum PredictionConfidence {
  low,
  medium,
  high,
  veryHigh,
}

class AIChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final bool isTyping;

  AIChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.metadata,
    this.isTyping = false,
  });

  factory AIChatMessage.fromJson(Map<String, dynamic> json) {
    return AIChatMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.user,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['metadata'],
      isTyping: json['isTyping'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'isTyping': isTyping,
    };
  }
}

class SymptomData {
  final String symptom;
  final SymptomSeverity severity;
  final Duration duration;
  final List<String> associatedSymptoms;
  final Map<String, dynamic> additionalInfo;

  SymptomData({
    required this.symptom,
    required this.severity,
    required this.duration,
    this.associatedSymptoms = const [],
    this.additionalInfo = const {},
  });

  factory SymptomData.fromJson(Map<String, dynamic> json) {
    return SymptomData(
      symptom: json['symptom'] ?? '',
      severity: SymptomSeverity.values.firstWhere(
        (e) => e.toString() == 'SymptomSeverity.${json['severity']}',
        orElse: () => SymptomSeverity.mild,
      ),
      duration: Duration(minutes: json['durationMinutes'] ?? 0),
      associatedSymptoms: List<String>.from(json['associatedSymptoms'] ?? []),
      additionalInfo: Map<String, dynamic>.from(json['additionalInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symptom': symptom,
      'severity': severity.toString().split('.').last,
      'durationMinutes': duration.inMinutes,
      'associatedSymptoms': associatedSymptoms,
      'additionalInfo': additionalInfo,
    };
  }
}

class AIPrediction {
  final String id;
  final String diagnosis;
  final String description;
  final PredictionConfidence confidence;
  final List<String> recommendedActions;
  final List<String> warningFlags;
  final Map<String, double> alternativeDiagnoses;
  final bool requiresImmediateAttention;
  final String specialty;
  final DateTime createdAt;

  AIPrediction({
    required this.id,
    required this.diagnosis,
    required this.description,
    required this.confidence,
    this.recommendedActions = const [],
    this.warningFlags = const [],
    this.alternativeDiagnoses = const {},
    this.requiresImmediateAttention = false,
    this.specialty = 'General Medicine',
    required this.createdAt,
  });

  Color get confidenceColor {
    switch (confidence) {
      case PredictionConfidence.low:
        return Colors.grey;
      case PredictionConfidence.medium:
        return Colors.orange;
      case PredictionConfidence.high:
        return Colors.blue;
      case PredictionConfidence.veryHigh:
        return Colors.green;
    }
  }

  String get confidenceText {
    switch (confidence) {
      case PredictionConfidence.low:
        return 'Low Confidence';
      case PredictionConfidence.medium:
        return 'Medium Confidence';
      case PredictionConfidence.high:
        return 'High Confidence';
      case PredictionConfidence.veryHigh:
        return 'Very High Confidence';
    }
  }

  factory AIPrediction.fromJson(Map<String, dynamic> json) {
    return AIPrediction(
      id: json['id'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      description: json['description'] ?? '',
      confidence: PredictionConfidence.values.firstWhere(
        (e) => e.toString() == 'PredictionConfidence.${json['confidence']}',
        orElse: () => PredictionConfidence.low,
      ),
      recommendedActions: List<String>.from(json['recommendedActions'] ?? []),
      warningFlags: List<String>.from(json['warningFlags'] ?? []),
      alternativeDiagnoses:
          Map<String, double>.from(json['alternativeDiagnoses'] ?? {}),
      requiresImmediateAttention: json['requiresImmediateAttention'] ?? false,
      specialty: json['specialty'] ?? 'General Medicine',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'diagnosis': diagnosis,
      'description': description,
      'confidence': confidence.toString().split('.').last,
      'recommendedActions': recommendedActions,
      'warningFlags': warningFlags,
      'alternativeDiagnoses': alternativeDiagnoses,
      'requiresImmediateAttention': requiresImmediateAttention,
      'specialty': specialty,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class AIConsultationSession {
  final String id;
  final String patientId;
  final List<AIChatMessage> messages;
  final List<SymptomData> symptoms;
  final AIPrediction? currentPrediction;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isActive;
  final Map<String, dynamic> sessionMetadata;

  AIConsultationSession({
    required this.id,
    required this.patientId,
    this.messages = const [],
    this.symptoms = const [],
    this.currentPrediction,
    required this.startTime,
    this.endTime,
    this.isActive = true,
    this.sessionMetadata = const {},
  });

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  AIConsultationSession copyWith({
    String? id,
    String? patientId,
    List<AIChatMessage>? messages,
    List<SymptomData>? symptoms,
    AIPrediction? currentPrediction,
    DateTime? startTime,
    DateTime? endTime,
    bool? isActive,
    Map<String, dynamic>? sessionMetadata,
  }) {
    return AIConsultationSession(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      messages: messages ?? this.messages,
      symptoms: symptoms ?? this.symptoms,
      currentPrediction: currentPrediction ?? this.currentPrediction,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
      sessionMetadata: sessionMetadata ?? this.sessionMetadata,
    );
  }

  factory AIConsultationSession.fromJson(Map<String, dynamic> json) {
    return AIConsultationSession(
      id: json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      messages: (json['messages'] as List? ?? [])
          .map((m) => AIChatMessage.fromJson(m))
          .toList(),
      symptoms: (json['symptoms'] as List? ?? [])
          .map((s) => SymptomData.fromJson(s))
          .toList(),
      currentPrediction: json['currentPrediction'] != null
          ? AIPrediction.fromJson(json['currentPrediction'])
          : null,
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      isActive: json['isActive'] ?? true,
      sessionMetadata: Map<String, dynamic>.from(json['sessionMetadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'messages': messages.map((m) => m.toJson()).toList(),
      'symptoms': symptoms.map((s) => s.toJson()).toList(),
      'currentPrediction': currentPrediction?.toJson(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isActive': isActive,
      'sessionMetadata': sessionMetadata,
    };
  }
}
