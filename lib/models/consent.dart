import 'package:flutter/material.dart';

enum ConsentType {
  dataCollection,
  dataSharing,
  marketing,
  analytics,
  location,
  camera,
  microphone,
  notifications,
  healthData,
  thirdPartyServices,
  aiProcessing,
  emergencyContacts,
  familyMembers,
  insurance,
  payment,
  biometric,
  cloudStorage,
  research,
  advertising,
  personalizedContent,
  // Added for UI test data:
  storage,
  socialMedia,
  familyAccess,
  cloudBackup,
  dataExport,
  telemedicine,
  medicationTracking,
}

enum ConsentStatus {
  granted,
  denied,
  pending,
  expired,
  revoked,
  notRequested,
}

enum ConsentCategory {
  essential,
  functional,
  analytics,
  marketing,
  thirdParty,
  health,
  privacy,
  // Added for UI test data:
  research,
}

class ConsentItem {
  final String id;
  final ConsentType type;
  final String title;
  final String description;
  final String detailedDescription;
  final ConsentCategory category;
  final ConsentStatus status;
  final DateTime? grantedAt;
  final DateTime? revokedAt;
  final DateTime? expiresAt;
  final String? grantedBy;
  final String? revokedBy;
  final String? ipAddress;
  final String? userAgent;
  final Map<String, dynamic>? metadata;
  final bool isRequired;
  final bool canRevoke;
  final bool autoRenew;
  final int? renewalPeriodDays;
  final List<String>? dependencies;
  final String? version;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConsentItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.detailedDescription,
    required this.category,
    required this.status,
    this.grantedAt,
    this.revokedAt,
    this.expiresAt,
    this.grantedBy,
    this.revokedBy,
    this.ipAddress,
    this.userAgent,
    this.metadata,
    required this.isRequired,
    required this.canRevoke,
    required this.autoRenew,
    this.renewalPeriodDays,
    this.dependencies,
    this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status == ConsentStatus.granted && 
    (expiresAt == null || expiresAt!.isAfter(DateTime.now()));

  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());

  bool get needsRenewal => isExpired && autoRenew;

  Duration? get timeUntilExpiry {
    if (expiresAt == null) return null;
    return expiresAt!.difference(DateTime.now());
  }

  ConsentItem copyWith({
    String? id,
    ConsentType? type,
    String? title,
    String? description,
    String? detailedDescription,
    ConsentCategory? category,
    ConsentStatus? status,
    DateTime? grantedAt,
    DateTime? revokedAt,
    DateTime? expiresAt,
    String? grantedBy,
    String? revokedBy,
    String? ipAddress,
    String? userAgent,
    Map<String, dynamic>? metadata,
    bool? isRequired,
    bool? canRevoke,
    bool? autoRenew,
    int? renewalPeriodDays,
    List<String>? dependencies,
    String? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConsentItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      detailedDescription: detailedDescription ?? this.detailedDescription,
      category: category ?? this.category,
      status: status ?? this.status,
      grantedAt: grantedAt ?? this.grantedAt,
      revokedAt: revokedAt ?? this.revokedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      grantedBy: grantedBy ?? this.grantedBy,
      revokedBy: revokedBy ?? this.revokedBy,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      metadata: metadata ?? this.metadata,
      isRequired: isRequired ?? this.isRequired,
      canRevoke: canRevoke ?? this.canRevoke,
      autoRenew: autoRenew ?? this.autoRenew,
      renewalPeriodDays: renewalPeriodDays ?? this.renewalPeriodDays,
      dependencies: dependencies ?? this.dependencies,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'title': title,
      'description': description,
      'detailedDescription': detailedDescription,
      'category': category.toString(),
      'status': status.toString(),
      'grantedAt': grantedAt?.toIso8601String(),
      'revokedAt': revokedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'grantedBy': grantedBy,
      'revokedBy': revokedBy,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'metadata': metadata,
      'isRequired': isRequired,
      'canRevoke': canRevoke,
      'autoRenew': autoRenew,
      'renewalPeriodDays': renewalPeriodDays,
      'dependencies': dependencies,
      'version': version,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ConsentItem.fromJson(Map<String, dynamic> json) {
    return ConsentItem(
      id: json['id'],
      type: ConsentType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      title: json['title'],
      description: json['description'],
      detailedDescription: json['detailedDescription'],
      category: ConsentCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
      ),
      status: ConsentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      grantedAt: json['grantedAt'] != null 
        ? DateTime.parse(json['grantedAt']) 
        : null,
      revokedAt: json['revokedAt'] != null 
        ? DateTime.parse(json['revokedAt']) 
        : null,
      expiresAt: json['expiresAt'] != null 
        ? DateTime.parse(json['expiresAt']) 
        : null,
      grantedBy: json['grantedBy'],
      revokedBy: json['revokedBy'],
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
      metadata: json['metadata'],
      isRequired: json['isRequired'],
      canRevoke: json['canRevoke'],
      autoRenew: json['autoRenew'],
      renewalPeriodDays: json['renewalPeriodDays'],
      dependencies: json['dependencies'] != null 
        ? List<String>.from(json['dependencies']) 
        : null,
      version: json['version'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class ConsentLog {
  final String id;
  final String consentId;
  final ConsentStatus previousStatus;
  final ConsentStatus newStatus;
  final String action; // 'granted', 'revoked', 'expired', 'renewed'
  final String? reason;
  final String? performedBy;
  final DateTime timestamp;
  final String? ipAddress;
  final String? userAgent;
  final Map<String, dynamic>? metadata;

  ConsentLog({
    required this.id,
    required this.consentId,
    required this.previousStatus,
    required this.newStatus,
    required this.action,
    this.reason,
    this.performedBy,
    required this.timestamp,
    this.ipAddress,
    this.userAgent,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'consentId': consentId,
      'previousStatus': previousStatus.toString(),
      'newStatus': newStatus.toString(),
      'action': action,
      'reason': reason,
      'performedBy': performedBy,
      'timestamp': timestamp.toIso8601String(),
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'metadata': metadata,
    };
  }

  factory ConsentLog.fromJson(Map<String, dynamic> json) {
    return ConsentLog(
      id: json['id'],
      consentId: json['consentId'],
      previousStatus: ConsentStatus.values.firstWhere(
        (e) => e.toString() == json['previousStatus'],
      ),
      newStatus: ConsentStatus.values.firstWhere(
        (e) => e.toString() == json['newStatus'],
      ),
      action: json['action'],
      reason: json['reason'],
      performedBy: json['performedBy'],
      timestamp: DateTime.parse(json['timestamp']),
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
      metadata: json['metadata'],
    );
  }
}

class ConsentSettings {
  final bool allowMarketing;
  final bool allowAnalytics;
  final bool allowThirdPartyServices;
  final bool allowLocationServices;
  final bool allowNotifications;
  final bool allowBiometricAuth;
  final bool allowCloudStorage;
  final bool allowResearchParticipation;
  final bool allowPersonalizedContent;
  final bool allowEmergencyContacts;
  final bool allowFamilyMemberAccess;
  final DateTime lastUpdated;
  final String? updatedBy;

  ConsentSettings({
    required this.allowMarketing,
    required this.allowAnalytics,
    required this.allowThirdPartyServices,
    required this.allowLocationServices,
    required this.allowNotifications,
    required this.allowBiometricAuth,
    required this.allowCloudStorage,
    required this.allowResearchParticipation,
    required this.allowPersonalizedContent,
    required this.allowEmergencyContacts,
    required this.allowFamilyMemberAccess,
    required this.lastUpdated,
    this.updatedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'allowMarketing': allowMarketing,
      'allowAnalytics': allowAnalytics,
      'allowThirdPartyServices': allowThirdPartyServices,
      'allowLocationServices': allowLocationServices,
      'allowNotifications': allowNotifications,
      'allowBiometricAuth': allowBiometricAuth,
      'allowCloudStorage': allowCloudStorage,
      'allowResearchParticipation': allowResearchParticipation,
      'allowPersonalizedContent': allowPersonalizedContent,
      'allowEmergencyContacts': allowEmergencyContacts,
      'allowFamilyMemberAccess': allowFamilyMemberAccess,
      'lastUpdated': lastUpdated.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }

  factory ConsentSettings.fromJson(Map<String, dynamic> json) {
    return ConsentSettings(
      allowMarketing: json['allowMarketing'],
      allowAnalytics: json['allowAnalytics'],
      allowThirdPartyServices: json['allowThirdPartyServices'],
      allowLocationServices: json['allowLocationServices'],
      allowNotifications: json['allowNotifications'],
      allowBiometricAuth: json['allowBiometricAuth'],
      allowCloudStorage: json['allowCloudStorage'],
      allowResearchParticipation: json['allowResearchParticipation'],
      allowPersonalizedContent: json['allowPersonalizedContent'],
      allowEmergencyContacts: json['allowEmergencyContacts'],
      allowFamilyMemberAccess: json['allowFamilyMemberAccess'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      updatedBy: json['updatedBy'],
    );
  }

  ConsentSettings copyWith({
    bool? allowMarketing,
    bool? allowAnalytics,
    bool? allowThirdPartyServices,
    bool? allowLocationServices,
    bool? allowNotifications,
    bool? allowBiometricAuth,
    bool? allowCloudStorage,
    bool? allowResearchParticipation,
    bool? allowPersonalizedContent,
    bool? allowEmergencyContacts,
    bool? allowFamilyMemberAccess,
    DateTime? lastUpdated,
    String? updatedBy,
  }) {
    return ConsentSettings(
      allowMarketing: allowMarketing ?? this.allowMarketing,
      allowAnalytics: allowAnalytics ?? this.allowAnalytics,
      allowThirdPartyServices: allowThirdPartyServices ?? this.allowThirdPartyServices,
      allowLocationServices: allowLocationServices ?? this.allowLocationServices,
      allowNotifications: allowNotifications ?? this.allowNotifications,
      allowBiometricAuth: allowBiometricAuth ?? this.allowBiometricAuth,
      allowCloudStorage: allowCloudStorage ?? this.allowCloudStorage,
      allowResearchParticipation: allowResearchParticipation ?? this.allowResearchParticipation,
      allowPersonalizedContent: allowPersonalizedContent ?? this.allowPersonalizedContent,
      allowEmergencyContacts: allowEmergencyContacts ?? this.allowEmergencyContacts,
      allowFamilyMemberAccess: allowFamilyMemberAccess ?? this.allowFamilyMemberAccess,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
} 