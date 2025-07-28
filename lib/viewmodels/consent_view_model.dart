import 'package:flutter/material.dart';
import '../models/consent.dart';
import '../core/viewmodels/base_view_model.dart';
import 'package:uuid/uuid.dart';
import '../core/services/api_service.dart'; // Added import for ApiService

class ConsentViewModel extends BaseViewModel {
  final List<ConsentItem> _consentItems = [];
  final List<ConsentLog> _consentLogs = [];
  ConsentSettings? _consentSettings;
  bool _isLoading = false;
  String? _error;

  List<ConsentItem> get consentItems => List.unmodifiable(_consentItems);
  List<ConsentLog> get consentLogs => List.unmodifiable(_consentLogs);
  ConsentSettings? get consentSettings => _consentSettings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered lists
  List<ConsentItem> get activeConsents => 
    _consentItems.where((item) => item.isActive).toList();
  
  List<ConsentItem> get expiredConsents => 
    _consentItems.where((item) => item.isExpired).toList();
  
  List<ConsentItem> get pendingConsents => 
    _consentItems.where((item) => item.status == ConsentStatus.pending).toList();
  
  List<ConsentItem> get revokedConsents => 
    _consentItems.where((item) => item.status == ConsentStatus.revoked).toList();

  // Statistics
  int get totalConsents => _consentItems.length;
  int get activeConsentsCount => activeConsents.length;
  int get expiredConsentsCount => expiredConsents.length;
  int get pendingConsentsCount => pendingConsents.length;
  int get revokedConsentsCount => revokedConsents.length;

  @override
  Future<void> initialize() async {
    await loadConsentData();
  }

  Future<void> loadConsentData() async {
    setLoading(true);
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      _loadMockConsentItems();
      _loadMockConsentLogs();
      _loadMockConsentSettings();
      
      setError(null);
    } catch (e) {
      setError('Failed to load consent data: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> grantConsent(String consentId, {String? reason}) async {
    try {
      final consentIndex = _consentItems.indexWhere((item) => item.id == consentId);
      if (consentIndex == -1) {
        throw Exception('Consent not found');
      }

      final consent = _consentItems[consentIndex];
      final previousStatus = consent.status;
      
      // Update consent status
      _consentItems[consentIndex] = consent.copyWith(
        status: ConsentStatus.granted,
        grantedAt: DateTime.now(),
        grantedBy: 'Current User',
        updatedAt: DateTime.now(),
      );

      // Create consent log
      final log = ConsentLog(
        id: const Uuid().v4(),
        consentId: consentId,
        previousStatus: previousStatus,
        newStatus: ConsentStatus.granted,
        action: 'granted',
        reason: reason,
        performedBy: 'Current User',
        timestamp: DateTime.now(),
        ipAddress: '127.0.0.1',
        userAgent: 'Medico App',
      );

      _consentLogs.insert(0, log);
      notifyListeners();
    } catch (e) {
      setError('Failed to grant consent: $e');
    }
  }

  Future<void> revokeConsent(String consentId, {String? reason}) async {
    try {
      final consentIndex = _consentItems.indexWhere((item) => item.id == consentId);
      if (consentIndex == -1) {
        throw Exception('Consent not found');
      }

      final consent = _consentItems[consentIndex];
      if (!consent.canRevoke) {
        throw Exception('This consent cannot be revoked');
      }

      final previousStatus = consent.status;
      
      // Update consent status
      _consentItems[consentIndex] = consent.copyWith(
        status: ConsentStatus.revoked,
        revokedAt: DateTime.now(),
        revokedBy: 'Current User',
        updatedAt: DateTime.now(),
      );

      // Create consent log
      final log = ConsentLog(
        id: const Uuid().v4(),
        consentId: consentId,
        previousStatus: previousStatus,
        newStatus: ConsentStatus.revoked,
        action: 'revoked',
        reason: reason,
        performedBy: 'Current User',
        timestamp: DateTime.now(),
        ipAddress: '127.0.0.1',
        userAgent: 'Medico App',
      );

      _consentLogs.insert(0, log);
      notifyListeners();
    } catch (e) {
      setError('Failed to revoke consent: $e');
    }
  }

  Future<void> updateConsentSettings(ConsentSettings newSettings) async {
    try {
      _consentSettings = newSettings.copyWith(
        lastUpdated: DateTime.now(),
        updatedBy: 'Current User',
      );
      notifyListeners();
    } catch (e) {
      setError('Failed to update consent settings: $e');
    }
  }

  Future<void> renewConsent(String consentId) async {
    try {
      final consentIndex = _consentItems.indexWhere((item) => item.id == consentId);
      if (consentIndex == -1) {
        throw Exception('Consent not found');
      }

      final consent = _consentItems[consentIndex];
      if (!consent.autoRenew) {
        throw Exception('This consent does not support auto-renewal');
      }

      final renewalPeriod = consent.renewalPeriodDays ?? 365;
      final newExpiryDate = DateTime.now().add(Duration(days: renewalPeriod));

      _consentItems[consentIndex] = consent.copyWith(
        expiresAt: newExpiryDate,
        updatedAt: DateTime.now(),
      );

      // Create consent log
      final log = ConsentLog(
        id: const Uuid().v4(),
        consentId: consentId,
        previousStatus: consent.status,
        newStatus: consent.status,
        action: 'renewed',
        reason: 'Auto-renewal',
        performedBy: 'System',
        timestamp: DateTime.now(),
        ipAddress: '127.0.0.1',
        userAgent: 'Medico App',
      );

      _consentLogs.insert(0, log);
      notifyListeners();
    } catch (e) {
      setError('Failed to renew consent: $e');
    }
  }

  Future<Map<String, dynamic>> giveOrUpdateConsent(Map<String, dynamic> consentData) async {
    setLoading(true);
    try {
      final result = await ApiService.giveOrUpdateConsent(consentData);
      if (result['success'] == true && result['data'] != null) {
        // Optionally update local state with new consent data
        // For example, update _consentSettings or _consentItems if needed
        setError(null);
      } else {
        setError(result['message'] ?? 'Failed to update consent');
      }
      return result;
    } catch (e) {
      setError('Failed to update consent: $e');
      return {'success': false, 'message': e.toString()};
    } finally {
      setLoading(false);
    }
  }

  ConsentType _mapType(String? type) {
    switch (type) {
      case 'data_sharing':
        return ConsentType.dataSharing;
      case 'data_collection':
        return ConsentType.dataCollection;
      case 'marketing':
        return ConsentType.marketing;
      case 'analytics':
        return ConsentType.analytics;
      case 'location':
        return ConsentType.location;
      case 'notifications':
        return ConsentType.notifications;
      case 'health_data':
        return ConsentType.healthData;
      case 'third_party':
        return ConsentType.thirdPartyServices;
      case 'biometric':
        return ConsentType.biometric;
      case 'cloud_storage':
        return ConsentType.cloudStorage;
      case 'research':
        return ConsentType.research;
      case 'personalized_content':
        return ConsentType.personalizedContent;
      default:
        return ConsentType.dataSharing;
    }
  }

  String _typeTitle(ConsentType type) {
    switch (type) {
      case ConsentType.dataSharing:
        return 'Data Sharing';
      case ConsentType.dataCollection:
        return 'Data Collection';
      case ConsentType.marketing:
        return 'Marketing';
      case ConsentType.analytics:
        return 'Analytics';
      case ConsentType.location:
        return 'Location Services';
      case ConsentType.notifications:
        return 'Notifications';
      case ConsentType.healthData:
        return 'Health Data';
      case ConsentType.thirdPartyServices:
        return 'Third-Party Services';
      case ConsentType.biometric:
        return 'Biometric Authentication';
      case ConsentType.cloudStorage:
        return 'Cloud Storage';
      case ConsentType.research:
        return 'Research Participation';
      case ConsentType.personalizedContent:
        return 'Personalized Content';
      default:
        return 'Consent';
    }
  }

  String _typeDescription(ConsentType type) {
    switch (type) {
      case ConsentType.dataSharing:
        return 'Allow sharing your data for research or service improvement.';
      case ConsentType.dataCollection:
        return 'Allow collection of your personal and health data.';
      case ConsentType.marketing:
        return 'Receive marketing communications and offers.';
      case ConsentType.analytics:
        return 'Help us improve our services with usage analytics.';
      case ConsentType.location:
        return 'Allow access to your location for better service.';
      case ConsentType.notifications:
        return 'Receive important notifications and reminders.';
      case ConsentType.healthData:
        return 'Allow processing of your health and medical data.';
      case ConsentType.thirdPartyServices:
        return 'Allow sharing data with trusted third-party providers.';
      case ConsentType.biometric:
        return 'Use biometric authentication for secure access.';
      case ConsentType.cloudStorage:
        return 'Store your data securely in the cloud.';
      case ConsentType.research:
        return 'Participate in anonymized medical research.';
      case ConsentType.personalizedContent:
        return 'Receive personalized health recommendations.';
      default:
        return 'Consent description.';
    }
  }

  IconData typeIcon(ConsentType type) {
    switch (type) {
      case ConsentType.dataSharing:
        return Icons.share;
      case ConsentType.dataCollection:
        return Icons.folder_shared;
      case ConsentType.marketing:
        return Icons.campaign;
      case ConsentType.analytics:
        return Icons.analytics;
      case ConsentType.location:
        return Icons.location_on;
      case ConsentType.notifications:
        return Icons.notifications;
      case ConsentType.healthData:
        return Icons.health_and_safety;
      case ConsentType.thirdPartyServices:
        return Icons.business;
      case ConsentType.biometric:
        return Icons.fingerprint;
      case ConsentType.cloudStorage:
        return Icons.cloud;
      case ConsentType.research:
        return Icons.science;
      case ConsentType.personalizedContent:
        return Icons.person;
      default:
        return Icons.verified_user;
    }
  }

  Future<Map<String, dynamic>> fetchConsents() async {
    setLoading(true);
    try {
      final result = await ApiService.getConsents();
      print('API consent data: ${result['data']}'); // Debug print
      if (result['success'] == true && result['data'] is List) {
        _consentItems.clear();
        for (final data in result['data']) {
          // Defensive: fallback to dataSharing if type is unknown
          ConsentType type;
          try {
            type = _mapType(data['type']);
          } catch (_) {
            type = ConsentType.dataSharing;
          }
          _consentItems.add(ConsentItem(
            id: data['_id']?.toString() ?? '',
            type: type,
            title: _typeTitle(type),
            description: _typeDescription(type),
            detailedDescription: data['details'] ?? _typeDescription(type),
            category: ConsentCategory.essential, // Optionally map category
            status: data['granted'] == true ? ConsentStatus.granted : ConsentStatus.denied,
            grantedAt: data['grantedAt'] != null ? DateTime.tryParse(data['grantedAt']) : null,
            revokedAt: null,
            expiresAt: null,
            grantedBy: null,
            revokedBy: null,
            ipAddress: null,
            userAgent: null,
            metadata: null,
            isRequired: false,
            canRevoke: true,
            autoRenew: false,
            renewalPeriodDays: null,
            dependencies: null,
            version: null,
            createdAt: data['createdAt'] != null ? DateTime.tryParse(data['createdAt']) ?? DateTime.now() : DateTime.now(),
            updatedAt: data['updatedAt'] != null ? DateTime.tryParse(data['updatedAt']) ?? DateTime.now() : DateTime.now(),
          ));
        }
        setError(null);
        notifyListeners();
      } else {
        setError(result['message'] ?? 'Failed to fetch consents');
      }
      return result;
    } catch (e) {
      setError('Failed to fetch consents: $e');
      return {'success': false, 'message': e.toString()};
    } finally {
      setLoading(false);
    }
  }

  List<ConsentItem> getConsentsByCategory(ConsentCategory category) {
    return _consentItems.where((item) => item.category == category).toList();
  }

  List<ConsentItem> getConsentsByType(ConsentType type) {
    return _consentItems.where((item) => item.type == type).toList();
  }

  List<ConsentLog> getLogsForConsent(String consentId) {
    return _consentLogs.where((log) => log.consentId == consentId).toList();
  }

  List<ConsentLog> getRecentLogs({int limit = 10}) {
    return _consentLogs.take(limit).toList();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void updateConsentStatus(String id, bool granted) {
    final idx = _consentItems.indexWhere((c) => c.id == id);
    if (idx != -1) {
      final old = _consentItems[idx];
      _consentItems[idx] = old.copyWith(
        status: granted ? ConsentStatus.granted : ConsentStatus.denied,
        grantedAt: granted ? DateTime.now() : null,
      );
      notifyListeners();
    }
  }

  // Mock data loading methods
  void _loadMockConsentItems() {
    _consentItems.clear();
    _consentItems.addAll([
      ConsentItem(
        id: '1',
        type: ConsentType.dataCollection,
        title: 'Data Collection',
        description: 'Collect and process your personal information',
        detailedDescription: 'We collect your personal information including name, email, phone number, and health data to provide healthcare services.',
        category: ConsentCategory.essential,
        status: ConsentStatus.granted,
        grantedAt: DateTime.now().subtract(const Duration(days: 30)),
        grantedBy: 'User',
        isRequired: true,
        canRevoke: false,
        autoRenew: true,
        renewalPeriodDays: 365,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      ConsentItem(
        id: '2',
        type: ConsentType.marketing,
        title: 'Marketing Communications',
        description: 'Receive promotional emails and notifications',
        detailedDescription: 'We may send you promotional emails, newsletters, and special offers about our services and healthcare products.',
        category: ConsentCategory.marketing,
        status: ConsentStatus.granted,
        grantedAt: DateTime.now().subtract(const Duration(days: 15)),
        grantedBy: 'User',
        isRequired: false,
        canRevoke: true,
        autoRenew: false,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      ConsentItem(
        id: '3',
        type: ConsentType.analytics,
        title: 'Analytics and Performance',
        description: 'Help us improve our services',
        detailedDescription: 'We use analytics tools to understand how you use our app and improve our services.',
        category: ConsentCategory.analytics,
        status: ConsentStatus.granted,
        grantedAt: DateTime.now().subtract(const Duration(days: 20)),
        grantedBy: 'User',
        isRequired: false,
        canRevoke: true,
        autoRenew: true,
        renewalPeriodDays: 180,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      ConsentItem(
        id: '4',
        type: ConsentType.location,
        title: 'Location Services',
        description: 'Access your location for nearby services',
        detailedDescription: 'We use your location to show nearby hospitals, clinics, and provide location-based services.',
        category: ConsentCategory.functional,
        status: ConsentStatus.pending,
        isRequired: false,
        canRevoke: true,
        autoRenew: false,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ConsentItem(
        id: '5',
        type: ConsentType.healthData,
        title: 'Health Data Processing',
        description: 'Process your health information',
        detailedDescription: 'We process your health data including medical records, prescriptions, and health metrics to provide personalized care.',
        category: ConsentCategory.health,
        status: ConsentStatus.granted,
        grantedAt: DateTime.now().subtract(const Duration(days: 25)),
        grantedBy: 'User',
        isRequired: true,
        canRevoke: false,
        autoRenew: true,
        renewalPeriodDays: 365,
        expiresAt: DateTime.now().add(const Duration(days: 340)),
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      ConsentItem(
        id: '6',
        type: ConsentType.thirdPartyServices,
        title: 'Third-Party Services',
        description: 'Share data with trusted partners',
        detailedDescription: 'We may share your information with trusted third-party service providers for payment processing, analytics, and other services.',
        category: ConsentCategory.thirdParty,
        status: ConsentStatus.denied,
        revokedAt: DateTime.now().subtract(const Duration(days: 10)),
        revokedBy: 'User',
        isRequired: false,
        canRevoke: true,
        autoRenew: false,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      ConsentItem(
        id: '7',
        type: ConsentType.notifications,
        title: 'Push Notifications',
        description: 'Receive important updates and reminders',
        detailedDescription: 'We send push notifications for appointment reminders, medication alerts, and important health updates.',
        category: ConsentCategory.functional,
        status: ConsentStatus.granted,
        grantedAt: DateTime.now().subtract(const Duration(days: 12)),
        grantedBy: 'User',
        isRequired: false,
        canRevoke: true,
        autoRenew: true,
        renewalPeriodDays: 365,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        updatedAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      ConsentItem(
        id: '8',
        type: ConsentType.biometric,
        title: 'Biometric Authentication',
        description: 'Use fingerprint or face ID for login',
        detailedDescription: 'We use biometric authentication to provide secure and convenient access to your account.',
        category: ConsentCategory.privacy,
        status: ConsentStatus.granted,
        grantedAt: DateTime.now().subtract(const Duration(days: 8)),
        grantedBy: 'User',
        isRequired: false,
        canRevoke: true,
        autoRenew: false,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      ConsentItem(
        id: '9',
        type: ConsentType.camera,
        title: 'Camera Access',
        description: 'Use camera for document scanning and video calls',
        detailedDescription: 'We use your camera to scan medical documents, insurance cards, and for video consultations with healthcare providers.',
        category: ConsentCategory.functional,
        status: ConsentStatus.granted,
        grantedAt: DateTime.now().subtract(const Duration(days: 3)),
        grantedBy: 'User',
        isRequired: false,
        canRevoke: true,
        autoRenew: true,
        renewalPeriodDays: 180,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ConsentItem(
        id: '10',
        type: ConsentType.microphone,
        title: 'Microphone Access',
        description: 'Use microphone for voice notes and calls',
        detailedDescription: 'We use your microphone for voice-to-text features, voice notes, and video consultations.',
        category: ConsentCategory.functional,
        status: ConsentStatus.denied,
        revokedAt: DateTime.now().subtract(const Duration(days: 2)),
        revokedBy: 'User',
        isRequired: false,
        canRevoke: true,
        autoRenew: false,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ConsentItem(
        id: '11',
        type: ConsentType.storage,
        title: 'File Storage Access',
        description: 'Access files for document uploads',
        detailedDescription: 'We access your device storage to upload medical documents, prescriptions, and health records.',
        category: ConsentCategory.functional,
        status: ConsentStatus.granted,
        grantedAt: DateTime.now().subtract(const Duration(days: 7)),
        grantedBy: 'User',
        isRequired: false,
        canRevoke: true,
        autoRenew: true,
        renewalPeriodDays: 365,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      ConsentItem(
        id: '12',
        type: ConsentType.research,
        title: 'Research Participation',
        description: 'Contribute to medical research',
        detailedDescription: 'We may use anonymized data for medical research to improve healthcare outcomes and develop new treatments.',
        category: ConsentCategory.research,
        status: ConsentStatus.pending,
        isRequired: false,
        canRevoke: true,
        autoRenew: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ConsentItem(
        id: '13',
        type: ConsentType.socialMedia,
        title: 'Social Media Integration',
        description: 'Connect with social media accounts',
        detailedDescription: 'We integrate with social media platforms to provide social features and share health achievements.',
        category: ConsentCategory.marketing,
        status: ConsentStatus.denied,
        revokedAt: DateTime.now().subtract(const Duration(days: 14)),
        revokedBy: 'User',
        isRequired: false,
        canRevoke: true,
        autoRenew: false,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
      ConsentItem(
        id: '14',
        type: ConsentType.emergencyContacts,
        title: 'Emergency Contact Access',
        description: 'Access emergency contact information',
        detailedDescription: 'We access your emergency contacts to provide critical information to healthcare providers in emergencies.',
        category: ConsentCategory.essential,
        status: ConsentStatus.granted,
        grantedAt: DateTime.now().subtract(const Duration(days: 18)),
        grantedBy: 'User',
        isRequired: true,
        canRevoke: false,
        autoRenew: true,
        renewalPeriodDays: 365,
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
        updatedAt: DateTime.now().subtract(const Duration(days: 18)),
      ),
      ConsentItem(
        id: '15',
        type: ConsentType.familyAccess,
        title: 'Family Member Access',
        description: 'Allow family members to view your health data',
        detailedDescription: 'We allow designated family members to view your health information for care coordination purposes.',
        category: ConsentCategory.privacy,
        status: ConsentStatus.granted,
        grantedAt: DateTime.now().subtract(const Duration(days: 22)),
        grantedBy: 'User',
        isRequired: false,
        canRevoke: true,
        autoRenew: true,
        renewalPeriodDays: 365,
        createdAt: DateTime.now().subtract(const Duration(days: 22)),
        updatedAt: DateTime.now().subtract(const Duration(days: 22)),
      ),
      ConsentItem(
        id: '16',
        type: ConsentType.cloudBackup,
        title: 'Cloud Backup',
        description: 'Backup your health data to cloud',
        detailedDescription: 'We backup your health data to secure cloud storage to ensure data availability and disaster recovery.',
        category: ConsentCategory.essential,
        status: ConsentStatus.granted,
        grantedAt: DateTime.now().subtract(const Duration(days: 35)),
        grantedBy: 'User',
        isRequired: true,
        canRevoke: false,
        autoRenew: true,
        renewalPeriodDays: 365,
        expiresAt: DateTime.now().add(const Duration(days: 330)),
        createdAt: DateTime.now().subtract(const Duration(days: 35)),
        updatedAt: DateTime.now().subtract(const Duration(days: 35)),
      ),
      ConsentItem(
        id: '17',
        type: ConsentType.personalizedContent,
        title: 'Personalized Content',
        description: 'Receive personalized health recommendations',
        detailedDescription: 'We use your health data to provide personalized health tips, medication reminders, and wellness recommendations.',
        category: ConsentCategory.analytics,
        status: ConsentStatus.granted,
        grantedAt: DateTime.now().subtract(const Duration(days: 12)),
        grantedBy: 'User',
        isRequired: false,
        canRevoke: true,
        autoRenew: true,
        renewalPeriodDays: 180,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        updatedAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      ConsentItem(
        id: '18',
        type: ConsentType.dataExport,
        title: 'Data Export',
        description: 'Export your health data',
        detailedDescription: 'We allow you to export your health data in various formats for your personal records or to share with other healthcare providers.',
        category: ConsentCategory.functional,
        status: ConsentStatus.granted,
        grantedAt: DateTime.now().subtract(const Duration(days: 9)),
        grantedBy: 'User',
        isRequired: false,
        canRevoke: true,
        autoRenew: false,
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
        updatedAt: DateTime.now().subtract(const Duration(days: 9)),
      ),
      ConsentItem(
        id: '19',
        type: ConsentType.telemedicine,
        title: 'Telemedicine Services',
        description: 'Use video consultation features',
        detailedDescription: 'We provide telemedicine services including video consultations, remote monitoring, and virtual health assessments.',
        category: ConsentCategory.health,
        status: ConsentStatus.pending,
        isRequired: false,
        canRevoke: true,
        autoRenew: true,
        renewalPeriodDays: 365,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      ConsentItem(
        id: '20',
        type: ConsentType.medicationTracking,
        title: 'Medication Tracking',
        description: 'Track medication adherence',
        detailedDescription: 'We track your medication adherence to help you stay on schedule and provide reminders for missed doses.',
        category: ConsentCategory.health,
        status: ConsentStatus.granted,
        grantedAt: DateTime.now().subtract(const Duration(days: 16)),
        grantedBy: 'User',
        isRequired: false,
        canRevoke: true,
        autoRenew: true,
        renewalPeriodDays: 365,
        createdAt: DateTime.now().subtract(const Duration(days: 16)),
        updatedAt: DateTime.now().subtract(const Duration(days: 16)),
      ),
    ]);
  }

  void _loadMockConsentLogs() {
    _consentLogs.clear();
    _consentLogs.addAll([
      ConsentLog(
        id: '1',
        consentId: '1',
        previousStatus: ConsentStatus.notRequested,
        newStatus: ConsentStatus.granted,
        action: 'granted',
        reason: 'User registration',
        performedBy: 'User',
        timestamp: DateTime.now().subtract(const Duration(days: 30)),
        ipAddress: '192.168.1.100',
        userAgent: 'Medico App v1.0',
      ),
      ConsentLog(
        id: '2',
        consentId: '2',
        previousStatus: ConsentStatus.notRequested,
        newStatus: ConsentStatus.granted,
        action: 'granted',
        reason: 'Marketing preferences',
        performedBy: 'User',
        timestamp: DateTime.now().subtract(const Duration(days: 15)),
        ipAddress: '192.168.1.100',
        userAgent: 'Medico App v1.0',
      ),
      ConsentLog(
        id: '3',
        consentId: '3',
        previousStatus: ConsentStatus.notRequested,
        newStatus: ConsentStatus.granted,
        action: 'granted',
        reason: 'App improvement',
        performedBy: 'User',
        timestamp: DateTime.now().subtract(const Duration(days: 20)),
        ipAddress: '192.168.1.100',
        userAgent: 'Medico App v1.0',
      ),
      ConsentLog(
        id: '4',
        consentId: '6',
        previousStatus: ConsentStatus.notRequested,
        newStatus: ConsentStatus.denied,
        action: 'denied',
        reason: 'Privacy concerns',
        performedBy: 'User',
        timestamp: DateTime.now().subtract(const Duration(days: 10)),
        ipAddress: '192.168.1.100',
        userAgent: 'Medico App v1.0',
      ),
      ConsentLog(
        id: '5',
        consentId: '7',
        previousStatus: ConsentStatus.notRequested,
        newStatus: ConsentStatus.granted,
        action: 'granted',
        reason: 'Appointment reminders',
        performedBy: 'User',
        timestamp: DateTime.now().subtract(const Duration(days: 12)),
        ipAddress: '192.168.1.100',
        userAgent: 'Medico App v1.0',
      ),
      ConsentLog(
        id: '6',
        consentId: '6',
        previousStatus: ConsentStatus.notRequested,
        newStatus: ConsentStatus.denied,
        action: 'denied',
        reason: 'Privacy concerns',
        performedBy: 'User',
        timestamp: DateTime.now().subtract(const Duration(days: 10)),
        ipAddress: '192.168.1.100',
        userAgent: 'Medico App v1.0',
      ),
      ConsentLog(
        id: '7',
        consentId: '9',
        previousStatus: ConsentStatus.notRequested,
        newStatus: ConsentStatus.granted,
        action: 'granted',
        reason: 'Document scanning',
        performedBy: 'User',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        ipAddress: '192.168.1.100',
        userAgent: 'Medico App v1.0',
      ),
      ConsentLog(
        id: '8',
        consentId: '10',
        previousStatus: ConsentStatus.notRequested,
        newStatus: ConsentStatus.granted,
        action: 'granted',
        reason: 'Voice features',
        performedBy: 'User',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        ipAddress: '192.168.1.100',
        userAgent: 'Medico App v1.0',
      ),
      ConsentLog(
        id: '9',
        consentId: '10',
        previousStatus: ConsentStatus.granted,
        newStatus: ConsentStatus.denied,
        action: 'revoked',
        reason: 'Changed mind',
        performedBy: 'User',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        ipAddress: '192.168.1.100',
        userAgent: 'Medico App v1.0',
      ),
      ConsentLog(
        id: '10',
        consentId: '11',
        previousStatus: ConsentStatus.notRequested,
        newStatus: ConsentStatus.granted,
        action: 'granted',
        reason: 'File uploads',
        performedBy: 'User',
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
        ipAddress: '192.168.1.100',
        userAgent: 'Medico App v1.0',
      ),
      ConsentLog(
        id: '11',
        consentId: '13',
        previousStatus: ConsentStatus.notRequested,
        newStatus: ConsentStatus.granted,
        action: 'granted',
        reason: 'Social features',
        performedBy: 'User',
        timestamp: DateTime.now().subtract(const Duration(days: 20)),
        ipAddress: '192.168.1.100',
        userAgent: 'Medico App v1.0',
      ),
      ConsentLog(
        id: '12',
        consentId: '13',
        previousStatus: ConsentStatus.granted,
        newStatus: ConsentStatus.denied,
        action: 'revoked',
        reason: 'Privacy concerns',
        performedBy: 'User',
        timestamp: DateTime.now().subtract(const Duration(days: 14)),
        ipAddress: '192.168.1.100',
        userAgent: 'Medico App v1.0',
      ),
      ConsentLog(
        id: '13',
        consentId: '14',
        previousStatus: ConsentStatus.notRequested,
        newStatus: ConsentStatus.granted,
        action: 'granted',
        reason: 'Emergency safety',
        performedBy: 'User',
        timestamp: DateTime.now().subtract(const Duration(days: 18)),
        ipAddress: '192.168.1.100',
        userAgent: 'Medico App v1.0',
      ),
      ConsentLog(
        id: '14',
        consentId: '15',
        previousStatus: ConsentStatus.notRequested,
        newStatus: ConsentStatus.granted,
        action: 'granted',
        reason: 'Family coordination',
        performedBy: 'User',
        timestamp: DateTime.now().subtract(const Duration(days: 22)),
        ipAddress: '192.168.1.100',
        userAgent: 'Medico App v1.0',
      ),
      ConsentLog(
        id: '15',
        consentId: '16',
        previousStatus: ConsentStatus.notRequested,
        newStatus: ConsentStatus.granted,
        action: 'granted',
        reason: 'Data backup',
        performedBy: 'User',
        timestamp: DateTime.now().subtract(const Duration(days: 35)),
        ipAddress: '192.168.1.100',
        userAgent: 'Medico App v1.0',
      ),
      ConsentLog(
        id: '16',
        consentId: '17',
        previousStatus: ConsentStatus.notRequested,
        newStatus: ConsentStatus.granted,
        action: 'granted',
        reason: 'Personalized care',
        performedBy: 'User',
        timestamp: DateTime.now().subtract(const Duration(days: 12)),
        ipAddress: '192.168.1.100',
        userAgent: 'Medico App v1.0',
      ),
      ConsentLog(
        id: '17',
        consentId: '18',
        previousStatus: ConsentStatus.notRequested,
        newStatus: ConsentStatus.granted,
        action: 'granted',
        reason: 'Data portability',
        performedBy: 'User',
        timestamp: DateTime.now().subtract(const Duration(days: 9)),
        ipAddress: '192.168.1.100',
        userAgent: 'Medico App v1.0',
      ),
      ConsentLog(
        id: '18',
        consentId: '20',
        previousStatus: ConsentStatus.notRequested,
        newStatus: ConsentStatus.granted,
        action: 'granted',
        reason: 'Medication management',
        performedBy: 'User',
        timestamp: DateTime.now().subtract(const Duration(days: 16)),
        ipAddress: '192.168.1.100',
        userAgent: 'Medico App v1.0',
      ),
      ConsentLog(
        id: '19',
        consentId: '5',
        previousStatus: ConsentStatus.granted,
        newStatus: ConsentStatus.expired,
        action: 'expired',
        reason: 'Consent period ended',
        performedBy: 'System',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ipAddress: 'System',
        userAgent: 'Medico App v1.0',
      ),
      ConsentLog(
        id: '20',
        consentId: '5',
        previousStatus: ConsentStatus.expired,
        newStatus: ConsentStatus.granted,
        action: 'renewed',
        reason: 'Auto-renewal',
        performedBy: 'System',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ipAddress: 'System',
        userAgent: 'Medico App v1.0',
      ),
    ]);
  }

  void _loadMockConsentSettings() {
    _consentSettings = ConsentSettings(
      allowMarketing: true,
      allowAnalytics: true,
      allowThirdPartyServices: false,
      allowLocationServices: false,
      allowNotifications: true,
      allowBiometricAuth: true,
      allowCloudStorage: true,
      allowResearchParticipation: false,
      allowPersonalizedContent: true,
      allowEmergencyContacts: true,
      allowFamilyMemberAccess: true,
      lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
      updatedBy: 'User',
    );
  }
} 