import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../core/viewmodels/base_view_model.dart';
import '../core/services/dashboard_service.dart';
import '../core/services/auth_service.dart';
import '../core/services/medicine_reminder_service.dart';
import '../core/services/medical_journey_service.dart';
import '../models/dashboard.dart';
import '../models/medicine_reminder.dart';
import '../models/journey_stage.dart';
import '../views/dashboard/widgets/quick_action_card.dart';
import '../views/appointments/book_appointment_screen.dart';
import '../views/medicine_reminders/medicine_reminders_screen.dart';
import '../views/test_checkups/test_checkups_screen.dart';
import '../views/health_records/health_records_screen.dart';
import '../views/insurance/insurance_screen.dart';
import '../views/ai_symptom/ai_symptom_chat_screen.dart';
import '../views/journey_tracker/journey_tracker_screen.dart';
import '../views/workflow/medical_workflow_screen.dart';
import '../views/invoices/invoices_screen.dart';
import '../views/prescriptions/prescription_screen.dart';

class DashboardViewModel extends BaseViewModel {
  String userName = 'John Doe';
  String userLocation = 'New York, NY';

  // Dashboard data from API
  Dashboard? _dashboardData;
  Dashboard? get dashboardData => _dashboardData;

  // Medicine reminders data
  List<MedicineReminder> _medicineReminders = [];
  List<MedicineReminder> get medicineReminders => _medicineReminders;

  // Health Overview Data (from API or fallback)
  double get totalSavings =>
      _dashboardData?.healthOverview.totalSavings ?? 2450.00;
  int get visitsThisMonth =>
      _dashboardData?.healthOverview.visitsThisMonth ?? 3;
  int get visitsThisYear =>
      _dashboardData?.healthOverview.totalVisitsThisYear ?? 12;
  double get healthScore => _dashboardData?.healthOverview.healthScore ?? 85.0;
  bool get hasInsurance =>
      _dashboardData?.healthOverview.insuranceStatus == 'active';

  // Health Tracker Data
  VitalSigns? _latestVitals;
  final List<VitalSigns> _vitalSignsHistory = [];
  List<Map<String, dynamic>> _healthMetrics = [];

  // Getters for health tracking
  VitalSigns? get latestVitals => _latestVitals;
  List<VitalSigns> get vitalSignsHistory => _vitalSignsHistory;
  List<Map<String, dynamic>> get healthMetrics => _healthMetrics;

  // Journey data
  List<MedicalJourney> _journeys = [];
  List<JourneyStage> get activeJourneyStages => _journeys.expand((j) => j.stages).where((s) => s.status == JourneyStatus.inProgress || s.status == JourneyStatus.notStarted).toList();

  // Recent Medical History (from API or fallback)
  List<Map<String, dynamic>> get recentVisits {
    if (_dashboardData?.recentMedicalHistory.isNotEmpty == true) {
      return _dashboardData!.recentMedicalHistory
          .map((history) => {
                'type': history.title,
                'date': history.date.toIso8601String().split('T')[0],
                'cost': history.financialDetails.youPaid,
                'marketCost': history.financialDetails.marketRate,
                'savings': history.financialDetails.saved,
                'status': history.status,
                'provider': history.provider,
                'outcome': history.outcome,
              })
          .toList();
    }

    // Fallback data
    return [
      {
        'type': 'Physiotherapy',
        'date': '2024-01-15',
        'cost': 120.00,
        'marketCost': 180.00,
        'savings': 60.00,
        'status': 'completed',
        'provider': 'Dr. Sarah Johnson',
        'outcome': 'Improved mobility',
      },
      {
        'type': 'Dental Cleaning',
        'date': '2024-01-10',
        'cost': 85.00,
        'marketCost': 150.00,
        'savings': 65.00,
        'status': 'completed',
        'provider': 'Dr. Michael Chen',
        'outcome': 'Good oral health',
      },
      {
        'type': 'Blood Test',
        'date': '2024-01-05',
        'cost': 45.00,
        'marketCost': 120.00,
        'savings': 75.00,
        'status': 'completed',
        'provider': 'LabCorp',
        'outcome': 'Normal results',
      },
    ];
  }

  // Active Care Items (from Medicine Reminder API or fallback)
  List<Map<String, dynamic>> get activeMedications {
    // Try to use medicine reminder API data first
    if (_medicineReminders.isNotEmpty) {
      return _medicineReminders
          .where((reminder) => reminder.isActive && reminder.status == ReminderStatus.active)
          .map((reminder) {
            final medicine = reminder.medicine;
            final nextDoseTime = _getNextDoseTime(reminder);
            
            return {
              'name': medicine?.name ?? reminder.reminderName,
              'dosage': medicine?.dosage ?? 'As prescribed',
              'frequency': _getFrequencyText(reminder.frequency),
              'nextDose': nextDoseTime?.toIso8601String() ?? '',
              'remaining': medicine?.remainingQuantity ?? 0,
              'refillNeeded': medicine?.needsRefill ?? false,
              'instructions': reminder.instructions,
              'takeWithFood': reminder.takeWithFood,
              'takeWithWater': reminder.takeWithWater,
              'dosesPerDay': reminder.dosesPerDay,
              'dosesCompleted': reminder.dosesCompleted,
              'totalDoses': reminder.totalDoses,
              'startDate': reminder.startDate.toIso8601String(),
              'endDate': reminder.endDate?.toIso8601String(),
            };
          })
          .toList();
    }

    // Fallback to dashboard API data if available
    if (_dashboardData?.currentMedications.isNotEmpty == true) {
      return _dashboardData!.currentMedications
          .map((med) => {
                'name': med.name,
                'dosage': med.dosage,
                'frequency': med.frequency,
                'nextDose': med.nextDose?.toIso8601String() ?? '',
                'remaining': med.quantityRemaining,
                'refillNeeded': med.needsRefill,
              })
          .toList();
    }

    // Fallback data
    return [
      {
        'name': 'Vitamin D3',
        'dosage': '1000 IU',
        'frequency': 'Daily',
        'nextDose': '2024-01-16 08:00',
        'remaining': 15,
        'refillNeeded': false,
      },
      {
        'name': 'Omega-3',
        'dosage': '1000mg',
        'frequency': 'Daily',
        'nextDose': '2024-01-16 20:00',
        'remaining': 8,
        'refillNeeded': true,
      },
    ];
  }

  List<Map<String, dynamic>> get ongoingTreatments {
    if (_dashboardData?.ongoingTreatments.isNotEmpty == true) {
      return _dashboardData!.ongoingTreatments
          .map((treatment) => {
                'type': treatment.name,
                'sessions':
                    '${treatment.completedSessions}/${treatment.totalSessions} completed',
                'nextSession': treatment.nextSession?.toIso8601String() ?? '',
                'progress': treatment.progress / 100,
                'provider':
                    'Dr. Sarah Johnson', // This would need to come from API
              })
          .toList();
    }

    // Fallback data
    return [
      {
        'type': 'Physiotherapy',
        'sessions': '3/8 completed',
        'nextSession': '2024-01-18 14:00',
        'progress': 0.375,
        'provider': 'Dr. Sarah Johnson',
      },
    ];
  }

  // Test Checkups (from API or fallback)
  Map<String, dynamic> get testCheckupsData {
    if (_dashboardData != null) {
      return {
        'all': _dashboardData!.testCheckups.all,
        'today': _dashboardData!.testCheckups.today,
        'upcoming': _dashboardData!.testCheckups.upcoming,
        'completed': _dashboardData!.testCheckups.completed,
      };
    }

    // Fallback data - updated to match sample data
    return {
      'all': 3,
      'today': 1,
      'upcoming': 1,
      'completed': 1,
    };
  }

  // Pre-approval Status (from API or fallback)
  Map<String, dynamic> get preApprovalData {
    if (_dashboardData != null) {
      return {
        'pending': _dashboardData!.preApprovalStatus.pending,
        'approved': _dashboardData!.preApprovalStatus.approved,
        'rejected': _dashboardData!.preApprovalStatus.rejected,
      };
    }

    // Fallback data
    return {
      'pending': 2,
      'approved': 8,
      'rejected': 1,
    };
  }

  // Policy Documents (from API or fallback)
  Map<String, dynamic> get policyDocumentsData {
    if (_dashboardData != null) {
      return {
        'insurance': _dashboardData!.policyDocuments.insurance,
        'medical': _dashboardData!.policyDocuments.medical,
        'idCards': _dashboardData!.policyDocuments.idCards,
      };
    }

    // Fallback data
    return {
      'insurance': 3,
      'medical': 5,
      'idCards': 2,
    };
  }

  // Health Tracker Metrics (from API or fallback)
  Map<String, dynamic> get healthMetricsData {
    if (_dashboardData != null) {
      final metrics = _dashboardData!.healthTracker.metrics;
      return {
        'bloodPressure': metrics.bloodPressure,
        'heartRate': metrics.heartRate,
        'weight': metrics.weight,
        'temperature': metrics.temperature,
        'bloodSugar': metrics.bloodSugar,
        'lastUpdated': _dashboardData!.healthTracker.lastUpdated,
      };
    }

    // Fallback data
    return {
      'bloodPressure': '120/80',
      'heartRate': 72,
      'weight': 70.5,
      'temperature': 98.6,
      'bloodSugar': 95,
      'lastUpdated': DateTime.now(),
    };
  }

  // Notifications (from API or fallback)
  List<Map<String, dynamic>> get notifications {
    if (_dashboardData?.notifications.isNotEmpty == true) {
      return _dashboardData!.notifications
          .map((notification) => {
                'type': notification.type,
                'title': notification.title,
                'message': notification.message,
                'isRead': notification.isRead,
                'createdAt': notification.createdAt,
              })
          .toList();
    }

    // Fallback data
    return [
      {
        'type': 'appointment',
        'title': 'Appointment Reminder',
        'message': 'You have an appointment tomorrow at 2:00 PM',
        'isRead': false,
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'type': 'medication',
        'title': 'Medication Due',
        'message': 'Time to take your Vitamin D3',
        'isRead': true,
        'createdAt': DateTime.now().subtract(const Duration(hours: 4)),
      },
    ];
  }

  // Load dashboard data from API
  Future<void> loadDashboardData() async {
    try {
      setBusy(true);

      // Initialize auth service if needed
      await AuthService.initialize();

      final dashboard = await DashboardService.getDashboardData();
      if (dashboard != null) {
        _dashboardData = dashboard;
      }
      
      // Also load medicine reminders
      await loadMedicineReminders();
    } catch (e) {
      // Handle error silently in production
    } finally {
      setBusy(false);
    }
  }

  // Load medicine reminders from API
  Future<void> loadMedicineReminders() async {
    try {
      final reminders = await MedicineReminderService().getReminders();
      _medicineReminders = reminders;
      notifyListeners();
    } catch (e) {
      // Handle error silently in production
      developer.log('Error loading medicine reminders: $e');
    }
  }

  // Load journeys from API
  Future<void> loadJourneys() async {
    try {
      final apiJourneys = await MedicalJourneyService().getJourneys();
      _journeys = apiJourneys.map((json) => MedicalJourney.fromJson(json as Map<String, dynamic>)).toList();
      notifyListeners();
    } catch (e) {
      // handle error
    }
  }

  // Helper method to get next dose time
  DateTime? _getNextDoseTime(MedicineReminder reminder) {
    if (reminder.reminderTimes.isEmpty) return null;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Find the next reminder time for today
    for (final reminderTime in reminder.reminderTimes) {
      final timeOfDay = TimeOfDay.fromDateTime(reminderTime);
      final nextDose = DateTime(
        today.year,
        today.month,
        today.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );
      
      if (nextDose.isAfter(now)) {
        return nextDose;
      }
    }
    
    // If no more doses today, return the first dose of tomorrow
    if (reminder.reminderTimes.isNotEmpty) {
      final firstTime = reminder.reminderTimes.first;
      final timeOfDay = TimeOfDay.fromDateTime(firstTime);
      return DateTime(
        today.year,
        today.month,
        today.day + 1,
        timeOfDay.hour,
        timeOfDay.minute,
      );
    }
    
    return null;
  }

  // Helper method to get frequency text
  String _getFrequencyText(ReminderFrequency frequency) {
    switch (frequency) {
      case ReminderFrequency.once:
        return 'Once';
      case ReminderFrequency.daily:
        return 'Daily';
      case ReminderFrequency.everyOtherDay:
        return 'Every Other Day';
      case ReminderFrequency.weekly:
        return 'Weekly';
      case ReminderFrequency.biWeekly:
        return 'Bi-Weekly';
      case ReminderFrequency.monthly:
        return 'Monthly';
      case ReminderFrequency.asNeeded:
        return 'As Needed';
      case ReminderFrequency.custom:
        return 'Custom';
    }
  }





  // Quick Actions - Keep existing structure
  List<QuickAction> get quickActions => const [
        QuickAction(
          title: 'AI Symptom Check',
          subtitle: 'Check your symptoms',
          icon: Icons.smart_toy,
          color: Colors.purple,
          screen: const AISymptomChatScreen(),
        ),
        QuickAction(
          title: 'Book Appointment',
          subtitle: 'Schedule a visit',
          icon: Icons.calendar_today,
          color: Colors.blue,
          screen: const BookAppointmentScreen(),
        ),
        QuickAction(
          title: 'Journey Tracker',
          subtitle: 'Track your progress',
          icon: Icons.timeline,
          color: Colors.teal,
          screen: const JourneyTrackerScreen(),
        ),
        QuickAction(
          title: 'Medical Workflow',
          subtitle: 'View your workflow',
          icon: Icons.account_tree,
          color: Colors.indigo,
          screen: const MedicalWorkflowScreen(),
        ),
        QuickAction(
          title: 'Medicine Reminders',
          subtitle: 'Set medicine alerts',
          icon: Icons.medication,
          color: Colors.orange,
          screen: const MedicineRemindersScreen(),
        ),
        QuickAction(
          title: 'Test Checkups',
          subtitle: 'Schedule tests',
          icon: Icons.science,
          color: Colors.purple,
          screen: const TestCheckupsScreen(),
        ),
        QuickAction(
          title: 'Health Records',
          subtitle: 'View your records',
          icon: Icons.folder,
          color: Colors.indigo,
          screen: const HealthRecordsScreen(),
        ),
        QuickAction(
          title: 'Insurance',
          subtitle: 'Manage your policies',
          icon: Icons.health_and_safety,
          color: Colors.green,
          screen: const InsuranceScreen(),
        ),
        QuickAction(
          title: 'E-Prescriptions',
          subtitle: 'Get your prescriptions',
          icon: Icons.receipt,
          color: Colors.red,
          screen: const PrescriptionsScreen(),
        ),
        QuickAction(
          title: 'Invoices',
          subtitle: 'View your bills',
          icon: Icons.receipt,
          color: Colors.amber,
          screen: const InvoicesScreen(),
        ),
      ];

  // Recommendations - Keep existing structure
  List<Map<String, dynamic>> get recommendations => const [
        {
          'type': 'appointment',
          'title': 'Annual Checkup Due',
          'message': 'It\'s been 11 months since your last checkup',
          'action': 'Book Now',
          'color': const Color(0xFF4CAF50),
        },
        {
          'type': 'medication',
          'title': 'Refill Reminder',
          'message': 'Your Omega-3 supplement is running low',
          'action': 'Order Refill',
          'color': const Color(0xFF2196F3),
        },
        {
          'type': 'test',
          'title': 'Blood Test Recommended',
          'message': 'Consider getting your annual blood work done',
          'action': 'Schedule Test',
          'color': const Color(0xFF9C27B0),
        },
      ];

  // Initialize the view model
  Future<void> initialize() async {
    await loadDashboardData();
    await loadMedicineReminders(); // Load medicine reminders from API
    await loadJourneys(); // Load journeys from API
    
    // Initialize sample vital signs data if not available from API
    if (_latestVitals == null) {
      _latestVitals = VitalSigns(
        bloodPressureSystolic: 120.0,
        bloodPressureDiastolic: 80.0,
        heartRate: 72,
        weight: 70.5,
        temperature: 98.6,
        bloodSugar: 95.0,
        oxygenSaturation: 98.0,
        height: 175.0,
        timestamp: DateTime.now(),
      );
    }
    
    // Initialize sample health metrics
    _healthMetrics = [
      {
        'name': 'Steps',
        'value': 8500,
        'target': 10000,
        'unit': 'steps',
        'progress': 0.85,
        'status': 'Good',
        'color': Colors.green,
        'icon': Icons.directions_walk,
      },
      {
        'name': 'Water Intake',
        'value': 6,
        'target': 8,
        'unit': 'glasses',
        'progress': 0.75,
        'status': 'Good',
        'color': Colors.blue,
        'icon': Icons.water_drop,
      },
      {
        'name': 'Sleep',
        'value': 7.5,
        'target': 8,
        'unit': 'hours',
        'progress': 0.94,
        'status': 'Excellent',
        'color': Colors.purple,
        'icon': Icons.bedtime,
      },
    ];
    
    // Notify listeners to update the UI
    notifyListeners();
  }

  // Helper method to get screen for navigation
  Widget? getScreenForQuickAction(int index) {
    if (index >= 0 && index < quickActions.length) {
      return quickActions[index].screen;
    }
    return null;
  }

  // Helper method to format date
  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper method to get vital sign status
  String getVitalSignStatus(String vitalType, Map<String, dynamic> values) {
    switch (vitalType) {
      case 'bloodPressure':
        final systolic = values['systolic'] ?? 0;
        final diastolic = values['diastolic'] ?? 0;
        if (systolic < 120 && diastolic < 80) return 'Normal';
        if (systolic < 130 && diastolic < 80) return 'Elevated';
        if (systolic >= 130 || diastolic >= 80) return 'High';
        return 'Unknown';
      case 'heartRate':
        final rate = values['rate'] ?? 0;
        if (rate >= 60 && rate <= 100) return 'Normal';
        if (rate < 60) return 'Low';
        if (rate > 100) return 'High';
        return 'Unknown';
      case 'temperature':
        final temp = values['temp'] ?? 0;
        if (temp >= 97.8 && temp <= 99.0) return 'Normal';
        if (temp > 99.0) return 'Elevated';
        if (temp < 97.8) return 'Low';
        return 'Unknown';
      default:
        return 'Normal';
    }
  }

  // Medication refill method
  void refillMedication(String medicationName) {
    // This would typically make an API call to refill medication
    developer
        .log('🔄 DashboardViewModel: Refilling medication: $medicationName');
  }

  // Test checkup filter options
  List<String> get testFilterOptions =>
      ['All', 'Today', 'Upcoming', 'Completed'];

  // Selected test filter
  String _selectedTestFilter = 'All';
  String get selectedTestFilter => _selectedTestFilter;

  // Set test filter
  void setTestFilter(String filter) {
    _selectedTestFilter = filter;
    notifyListeners();
  }

  // Get test checkup count
  int getTestCheckupCount(String filter) {
    switch (filter.toLowerCase()) {
      case 'all':
        return testCheckupsData['all'] ?? 0;
      case 'today':
        return testCheckupsData['today'] ?? 0;
      case 'upcoming':
        return testCheckupsData['upcoming'] ?? 0;
      case 'completed':
        return testCheckupsData['completed'] ?? 0;
      default:
        return 0;
    }
  }

  // Get filtered test checkups (placeholder - would return actual data)
  List<Map<String, dynamic>> getFilteredTestCheckups() {
    // Sample test checkup data
    final sampleData = [
      {
        'title': 'Blood Test',
        'description': 'Complete blood count and metabolic panel',
        'type': 'TestCheckupType.bloodTest',
        'status': 'TestCheckupStatus.scheduled',
        'statusDisplayName': 'Scheduled',
        'formattedDateTime': 'Jan 20, 2024 - 9:00 AM',
        'estimatedCost': 120.0,
        'location': 'City Medical Lab',
      },
      {
        'title': 'Chest X-Ray',
        'description': 'Routine chest examination',
        'type': 'TestCheckupType.xRay',
        'status': 'TestCheckupStatus.completed',
        'statusDisplayName': 'Completed',
        'formattedDateTime': 'Jan 15, 2024 - 2:30 PM',
        'estimatedCost': 85.0,
        'location': 'Radiology Center',
      },
      {
        'title': 'MRI Scan',
        'description': 'Brain MRI for headache evaluation',
        'type': 'TestCheckupType.mri',
        'status': 'TestCheckupStatus.upcoming',
        'statusDisplayName': 'Upcoming',
        'formattedDateTime': 'Jan 25, 2024 - 11:00 AM',
        'estimatedCost': 450.0,
        'location': 'Advanced Imaging Center',
      },
    ];
    
    // Filter based on selected filter
    switch (_selectedTestFilter.toLowerCase()) {
      case 'today':
        return sampleData.where((test) => 
          test['status'] == 'TestCheckupStatus.scheduled' && 
          (test['formattedDateTime'] as String?)?.contains('Jan 20') == true
        ).toList();
      case 'upcoming':
        return sampleData.where((test) => 
          test['status'] == 'TestCheckupStatus.upcoming'
        ).toList();
      case 'completed':
        return sampleData.where((test) => 
          test['status'] == 'TestCheckupStatus.completed'
        ).toList();
      default:
        return sampleData;
    }
  }

  // Mark notification as read
  void markNotificationAsRead(int index) {
    if (index >= 0 && index < notifications.length) {
      // In a real app, you would make an API call here to update the notification status
      // For now, we'll just log the action since we're using getters
      // In a real implementation, you would update the actual data source
      // and call notifyListeners() to update the UI
    }
  }

  // Mark all notifications as read
  void markAllNotificationsAsRead() {
    // In a real app, you would make an API call here to update all notifications
    // For now, we'll just log the action
    // In a real implementation, you would update the actual data source
    // and call notifyListeners() to update the UI
  }

  // Get unread notifications count
  int get unreadNotificationsCount {
    return notifications
        .where((notification) => notification['isRead'] == false)
        .length;
  }

  // Get read notifications count
  int get readNotificationsCount {
    return notifications
        .where((notification) => notification['isRead'] == true)
        .length;
  }
}

// Keep existing VitalSigns class
class VitalSigns {
  final double bloodPressureSystolic;
  final double bloodPressureDiastolic;
  final int heartRate;
  final double weight;
  final double temperature;
  final double bloodSugar;
  final double oxygenSaturation;
  final double height;
  final DateTime timestamp;

  VitalSigns({
    required this.bloodPressureSystolic,
    required this.bloodPressureDiastolic,
    required this.heartRate,
    required this.weight,
    required this.temperature,
    required this.bloodSugar,
    required this.oxygenSaturation,
    required this.height,
    required this.timestamp,
  });

  // Getter for backward compatibility
  double get bloodPressure => bloodPressureSystolic;
}
