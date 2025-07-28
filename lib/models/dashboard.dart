class Dashboard {
  final String id;
  final String userId;
  final HealthOverview healthOverview;
  final PreApprovalStatus preApprovalStatus;
  final PolicyDocuments policyDocuments;
  final List<CurrentMedication> currentMedications;
  final List<OngoingTreatment> ongoingTreatments;
  final TestCheckups testCheckups;
  final List<RecentMedicalHistory> recentMedicalHistory;
  final HealthTracker healthTracker;
  final InsuranceInfo? insuranceInfo;
  final List<Notification> notifications;
  final DashboardSettings settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  Dashboard({
    required this.id,
    required this.userId,
    required this.healthOverview,
    required this.preApprovalStatus,
    required this.policyDocuments,
    required this.currentMedications,
    required this.ongoingTreatments,
    required this.testCheckups,
    required this.recentMedicalHistory,
    required this.healthTracker,
    this.insuranceInfo,
    required this.notifications,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      healthOverview: HealthOverview.fromJson(json['healthOverview'] ?? {}),
      preApprovalStatus:
          PreApprovalStatus.fromJson(json['preApprovalStatus'] ?? {}),
      policyDocuments: PolicyDocuments.fromJson(json['policyDocuments'] ?? {}),
      currentMedications: (json['currentMedications'] as List<dynamic>?)
              ?.map((e) => CurrentMedication.fromJson(e))
              .toList() ??
          [],
      ongoingTreatments: (json['ongoingTreatments'] as List<dynamic>?)
              ?.map((e) => OngoingTreatment.fromJson(e))
              .toList() ??
          [],
      testCheckups: TestCheckups.fromJson(json['testCheckups'] ?? {}),
      recentMedicalHistory: (json['recentMedicalHistory'] as List<dynamic>?)
              ?.map((e) => RecentMedicalHistory.fromJson(e))
              .toList() ??
          [],
      healthTracker: HealthTracker.fromJson(json['healthTracker'] ?? {}),
      insuranceInfo: json['insuranceInfo'] != null
          ? InsuranceInfo.fromJson(json['insuranceInfo'])
          : null,
      notifications: (json['notifications'] as List<dynamic>?)
              ?.map((e) => Notification.fromJson(e))
              .toList() ??
          [],
      settings: DashboardSettings.fromJson(json['settings'] ?? {}),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  // Helper method to safely parse DateTime
  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'healthOverview': healthOverview.toJson(),
      'preApprovalStatus': preApprovalStatus.toJson(),
      'policyDocuments': policyDocuments.toJson(),
      'currentMedications': currentMedications.map((e) => e.toJson()).toList(),
      'ongoingTreatments': ongoingTreatments.map((e) => e.toJson()).toList(),
      'testCheckups': testCheckups.toJson(),
      'recentMedicalHistory':
          recentMedicalHistory.map((e) => e.toJson()).toList(),
      'healthTracker': healthTracker.toJson(),
      'insuranceInfo': insuranceInfo?.toJson(),
      'notifications': notifications.map((e) => e.toJson()).toList(),
      'settings': settings.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class HealthOverview {
  final double totalSavings;
  final double healthScore;
  final int visitsThisMonth;
  final int totalVisitsThisYear;
  final String insuranceStatus;

  HealthOverview({
    required this.totalSavings,
    required this.healthScore,
    required this.visitsThisMonth,
    required this.totalVisitsThisYear,
    required this.insuranceStatus,
  });

  factory HealthOverview.fromJson(Map<String, dynamic> json) {
    return HealthOverview(
      totalSavings: (json['totalSavings'] ?? 0).toDouble(),
      healthScore: (json['healthScore'] ?? 0).toDouble(),
      visitsThisMonth: json['visitsThisMonth'] ?? 0,
      totalVisitsThisYear: json['totalVisitsThisYear'] ?? 0,
      insuranceStatus: json['insuranceStatus'] ?? 'inactive',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSavings': totalSavings,
      'healthScore': healthScore,
      'visitsThisMonth': visitsThisMonth,
      'totalVisitsThisYear': totalVisitsThisYear,
      'insuranceStatus': insuranceStatus,
    };
  }
}

class PreApprovalStatus {
  final int pending;
  final int approved;
  final int rejected;

  PreApprovalStatus({
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  factory PreApprovalStatus.fromJson(Map<String, dynamic> json) {
    return PreApprovalStatus(
      pending: json['pending'] ?? 0,
      approved: json['approved'] ?? 0,
      rejected: json['rejected'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
    };
  }
}

class PolicyDocuments {
  final int insurance;
  final int medical;
  final int idCards;

  PolicyDocuments({
    required this.insurance,
    required this.medical,
    required this.idCards,
  });

  factory PolicyDocuments.fromJson(Map<String, dynamic> json) {
    return PolicyDocuments(
      insurance: json['insurance'] ?? 0,
      medical: json['medical'] ?? 0,
      idCards: json['idCards'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'insurance': insurance,
      'medical': medical,
      'idCards': idCards,
    };
  }
}

class CurrentMedication {
  final String name;
  final String dosage;
  final String frequency;
  final DateTime? nextDose;
  final int quantityRemaining;
  final bool needsRefill;

  CurrentMedication({
    required this.name,
    required this.dosage,
    required this.frequency,
    this.nextDose,
    required this.quantityRemaining,
    required this.needsRefill,
  });

  factory CurrentMedication.fromJson(Map<String, dynamic> json) {
    return CurrentMedication(
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      nextDose: _parseDateTime(json['nextDose']),
      quantityRemaining: json['quantityRemaining'] ?? 0,
      needsRefill: json['needsRefill'] ?? false,
    );
  }

  // Helper method to safely parse DateTime
  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'nextDose': nextDose?.toIso8601String(),
      'quantityRemaining': quantityRemaining,
      'needsRefill': needsRefill,
    };
  }
}

class OngoingTreatment {
  final String name;
  final int completedSessions;
  final int totalSessions;
  final DateTime? nextSession;
  final double progress;

  OngoingTreatment({
    required this.name,
    required this.completedSessions,
    required this.totalSessions,
    this.nextSession,
    required this.progress,
  });

  factory OngoingTreatment.fromJson(Map<String, dynamic> json) {
    return OngoingTreatment(
      name: json['name'] ?? '',
      completedSessions: json['completedSessions'] ?? 0,
      totalSessions: json['totalSessions'] ?? 0,
      nextSession: _parseDateTime(json['nextSession']),
      progress: (json['progress'] ?? 0).toDouble(),
    );
  }

  // Helper method to safely parse DateTime
  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'completedSessions': completedSessions,
      'totalSessions': totalSessions,
      'nextSession': nextSession?.toIso8601String(),
      'progress': progress,
    };
  }
}

class TestCheckups {
  final int all;
  final int today;
  final int upcoming;
  final int completed;

  TestCheckups({
    required this.all,
    required this.today,
    required this.upcoming,
    required this.completed,
  });

  factory TestCheckups.fromJson(Map<String, dynamic> json) {
    return TestCheckups(
      all: json['all'] ?? 0,
      today: json['today'] ?? 0,
      upcoming: json['upcoming'] ?? 0,
      completed: json['completed'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'all': all,
      'today': today,
      'upcoming': upcoming,
      'completed': completed,
    };
  }
}

class RecentMedicalHistory {
  final String title;
  final String doctor;
  final String provider;
  final DateTime date;
  final String status;
  final String outcome;
  final FinancialDetails financialDetails;

  RecentMedicalHistory({
    required this.title,
    required this.doctor,
    required this.provider,
    required this.date,
    required this.status,
    required this.outcome,
    required this.financialDetails,
  });

  factory RecentMedicalHistory.fromJson(Map<String, dynamic> json) {
    return RecentMedicalHistory(
      title: json['title'] ?? '',
      doctor: json['doctor'] ?? '',
      provider: json['provider'] ?? '',
      date: _parseDateTime(json['date']),
      status: json['status'] ?? 'pending',
      outcome: json['outcome'] ?? '',
      financialDetails:
          FinancialDetails.fromJson(json['financialDetails'] ?? {}),
    );
  }

  // Helper method to safely parse DateTime
  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'doctor': doctor,
      'provider': provider,
      'date': date.toIso8601String(),
      'status': status,
      'outcome': outcome,
      'financialDetails': financialDetails.toJson(),
    };
  }
}

class FinancialDetails {
  final double youPaid;
  final double marketRate;
  final double saved;

  FinancialDetails({
    required this.youPaid,
    required this.marketRate,
    required this.saved,
  });

  factory FinancialDetails.fromJson(Map<String, dynamic> json) {
    return FinancialDetails(
      youPaid: (json['youPaid'] ?? 0).toDouble(),
      marketRate: (json['marketRate'] ?? 0).toDouble(),
      saved: (json['saved'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'youPaid': youPaid,
      'marketRate': marketRate,
      'saved': saved,
    };
  }
}

class HealthTracker {
  final DateTime lastUpdated;
  final HealthMetrics metrics;

  HealthTracker({
    required this.lastUpdated,
    required this.metrics,
  });

  factory HealthTracker.fromJson(Map<String, dynamic> json) {
    return HealthTracker(
      lastUpdated: _parseDateTime(json['lastUpdated']),
      metrics: HealthMetrics.fromJson(json['metrics'] ?? {}),
    );
  }

  // Helper method to safely parse DateTime
  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'lastUpdated': lastUpdated.toIso8601String(),
      'metrics': metrics.toJson(),
    };
  }
}

class HealthMetrics {
  final String bloodPressure;
  final int heartRate;
  final double weight;
  final double temperature;
  final double bloodSugar;

  HealthMetrics({
    required this.bloodPressure,
    required this.heartRate,
    required this.weight,
    required this.temperature,
    required this.bloodSugar,
  });

  factory HealthMetrics.fromJson(Map<String, dynamic> json) {
    return HealthMetrics(
      bloodPressure: json['bloodPressure'] ?? '',
      heartRate: json['heartRate'] ?? 0,
      weight: (json['weight'] ?? 0).toDouble(),
      temperature: (json['temperature'] ?? 0).toDouble(),
      bloodSugar: (json['bloodSugar'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bloodPressure': bloodPressure,
      'heartRate': heartRate,
      'weight': weight,
      'temperature': temperature,
      'bloodSugar': bloodSugar,
    };
  }
}

class InsuranceInfo {
  final String provider;
  final String policyNumber;
  final String coverageType;
  final DateTime validFrom;
  final DateTime validTo;
  final double coverageAmount;
  final double deductible;
  final double copay;

  InsuranceInfo({
    required this.provider,
    required this.policyNumber,
    required this.coverageType,
    required this.validFrom,
    required this.validTo,
    required this.coverageAmount,
    required this.deductible,
    required this.copay,
  });

  factory InsuranceInfo.fromJson(Map<String, dynamic> json) {
    return InsuranceInfo(
      provider: json['provider'] ?? '',
      policyNumber: json['policyNumber'] ?? '',
      coverageType: json['coverageType'] ?? '',
      validFrom: _parseDateTime(json['validFrom']),
      validTo: _parseDateTime(json['validTo']),
      coverageAmount: (json['coverageAmount'] ?? 0).toDouble(),
      deductible: (json['deductible'] ?? 0).toDouble(),
      copay: (json['copay'] ?? 0).toDouble(),
    );
  }

  // Helper method to safely parse DateTime
  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'policyNumber': policyNumber,
      'coverageType': coverageType,
      'validFrom': validFrom.toIso8601String(),
      'validTo': validTo.toIso8601String(),
      'coverageAmount': coverageAmount,
      'deductible': deductible,
      'copay': copay,
    };
  }
}

class Notification {
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  Notification({
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  // Helper method to safely parse DateTime
  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class DashboardSettings {
  final int refreshInterval;
  final bool showNotifications;
  final String theme;

  DashboardSettings({
    required this.refreshInterval,
    required this.showNotifications,
    required this.theme,
  });

  factory DashboardSettings.fromJson(Map<String, dynamic> json) {
    return DashboardSettings(
      refreshInterval: json['refreshInterval'] ?? 300000,
      showNotifications: json['showNotifications'] ?? true,
      theme: json['theme'] ?? 'light',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'refreshInterval': refreshInterval,
      'showNotifications': showNotifications,
      'theme': theme,
    };
  }
}
