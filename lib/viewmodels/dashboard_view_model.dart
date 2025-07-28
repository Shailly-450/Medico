import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/test_checkup.dart';
import '../models/health_record.dart';
import '../views/dashboard/widgets/quick_action_card.dart';
import '../views/appointments/appointment_calendar_screen.dart';
import '../views/medicine_reminders/medicine_reminders_screen.dart';
import '../views/test_checkups/test_checkups_screen.dart';
import '../views/health_records/health_records_screen.dart';
import '../views/insurance/insurance_screen.dart';
import '../views/ai_symptom/ai_symptom_chat_screen.dart';
import '../views/journey_tracker/journey_tracker_screen.dart';
import '../views/workflow/medical_workflow_screen.dart';
import '../views/invoices/invoices_screen.dart';
import '../views/appointments/book_appointment_screen.dart';
import '../views/prescriptions/prescription_screen.dart';

class DashboardViewModel extends BaseViewModel {
  String userName = 'John Doe';
  String userLocation = 'New York, NY';

  // Health Overview Data
  double totalSavings = 2450.00;
  int visitsThisMonth = 3;
  int visitsThisYear = 12;
  double healthScore = 85.0;
  bool hasInsurance = true;

  // Health Tracker Data
  VitalSigns? _latestVitals;
  List<VitalSigns> _vitalSignsHistory = [];
  List<Map<String, dynamic>> _healthMetrics = [];

  // Getters for health tracking
  VitalSigns? get latestVitals => _latestVitals;
  List<VitalSigns> get vitalSignsHistory => _vitalSignsHistory;
  List<Map<String, dynamic>> get healthMetrics => _healthMetrics;

  // Recent Medical History
  List<Map<String, dynamic>> recentVisits = [
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

  // Active Care Items
  List<Map<String, dynamic>> activeMedications = [
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

  List<Map<String, dynamic>> ongoingTreatments = [
    {
      'type': 'Physiotherapy',
      'sessions': '3/8 completed',
      'nextSession': '2024-01-18 14:00',
      'progress': 0.375,
      'provider': 'Dr. Sarah Johnson',
    },
  ];

  // Recommendations
  List<Map<String, dynamic>> recommendations = [
    {
      'type': 'preventive',
      'title': 'Annual Physical Checkup',
      'description': 'Due in 2 months based on your last visit',
      'estimatedCost': 95.00,
      'marketCost': 200.00,
      'priority': 'high',
    },
    {
      'type': 'cost_saving',
      'title': 'Switch to Generic Medication',
      'description': 'Save Rs. 250/month on your current prescription',
      'estimatedCost': 25.00,
      'marketCost': 70.00,
      'priority': 'medium',
    },
    {
      'type': 'health',
      'title': 'Blood Pressure Monitoring',
      'description': 'Consider home monitoring based on family history',
      'estimatedCost': 35.00,
      'marketCost': 80.00,
      'priority': 'low',
    },
  ];

  // Notifications
  List<Map<String, dynamic>> notifications = [
    {
      'type': 'medication',
      'title': 'Medicine Reminder',
      'message': 'Time to take Vitamin D3',
      'time': '2024-01-16 08:00',
      'isRead': false,
    },
    {
      'type': 'appointment',
      'title': 'Appointment Tomorrow',
      'message': 'Physiotherapy session at 2:00 PM',
      'time': '2024-01-17 14:00',
      'isRead': false,
    },
    {
      'type': 'health_tip',
      'title': 'Health Tip',
      'message': 'Stay hydrated! Drink 8 glasses of water daily',
      'time': '2024-01-16 10:00',
      'isRead': true,
    },
  ];

  // Test Checkups
  List<TestCheckup> testCheckups = [
    TestCheckup(
      id: '1',
      title: 'Complete Blood Count (CBC)',
      description: 'Blood test to check overall health',
      type: TestCheckupType.bloodTest,
      scheduledDate: DateTime.now().add(Duration(days: 2)),
      scheduledTime: TimeOfDay(hour: 9, minute: 30),
      doctorName: 'Dr. Smith',
      location: 'Central Lab',
      estimatedCost: 450.0,
      status: TestCheckupStatus.scheduled,
      priority: TestCheckupPriority.medium,
      instructions: 'Fasting required for 12 hours before test',
      requiresPreparation: true,
      preparationInstructions:
          'No food or drinks except water after 9 PM the night before',
      createdAt: DateTime.now().subtract(Duration(days: 5)),
      updatedAt: DateTime.now().subtract(Duration(days: 1)),
    ),
    TestCheckup(
      id: '2',
      title: 'Chest X-Ray',
      description: 'X-ray imaging of chest area',
      type: TestCheckupType.xRay,
      scheduledDate: DateTime.now().add(Duration(days: 1)),
      scheduledTime: TimeOfDay(hour: 14, minute: 0),
      doctorName: 'Dr. Johnson',
      location: 'Medical Imaging Center',
      estimatedCost: 800.0,
      status: TestCheckupStatus.scheduled,
      priority: TestCheckupPriority.high,
      instructions: 'Remove all jewelry and metal objects',
      requiresPreparation: false,
      createdAt: DateTime.now().subtract(Duration(days: 3)),
      updatedAt: DateTime.now().subtract(Duration(days: 1)),
    ),
    TestCheckup(
      id: '3',
      title: 'Annual Physical Checkup',
      description: 'Comprehensive health examination',
      type: TestCheckupType.physicalExam,
      scheduledDate: DateTime.now().add(Duration(days: 7)),
      scheduledTime: TimeOfDay(hour: 10, minute: 0),
      doctorName: 'Dr. Wilson',
      location: 'Family Health Clinic',
      estimatedCost: 1200.0,
      status: TestCheckupStatus.scheduled,
      priority: TestCheckupPriority.medium,
      instructions: 'Bring previous medical records',
      requiresPreparation: true,
      preparationInstructions: 'Fast for 8 hours, bring insurance card and ID',
      createdAt: DateTime.now().subtract(Duration(days: 10)),
      updatedAt: DateTime.now().subtract(Duration(days: 2)),
    ),
    TestCheckup(
      id: '4',
      title: 'Diabetes Screening',
      description: 'Blood glucose level test',
      type: TestCheckupType.bloodTest,
      scheduledDate: DateTime.now().subtract(Duration(days: 3)),
      scheduledTime: TimeOfDay(hour: 8, minute: 0),
      doctorName: 'Dr. Brown',
      location: 'Diabetes Care Center',
      estimatedCost: 300.0,
      status: TestCheckupStatus.completed,
      priority: TestCheckupPriority.medium,
      results: 'Blood glucose levels normal',
      createdAt: DateTime.now().subtract(Duration(days: 15)),
      updatedAt: DateTime.now().subtract(Duration(days: 3)),
    ),
    TestCheckup(
      id: '5',
      title: 'MRI Brain Scan',
      description: 'Magnetic resonance imaging of brain',
      type: TestCheckupType.mri,
      scheduledDate: DateTime.now().add(Duration(days: 14)),
      scheduledTime: TimeOfDay(hour: 11, minute: 30),
      doctorName: 'Dr. Davis',
      location: 'Advanced Imaging',
      estimatedCost: 5500.0,
      status: TestCheckupStatus.scheduled,
      priority: TestCheckupPriority.high,
      instructions: 'Inform about any metal implants',
      requiresPreparation: true,
      preparationInstructions:
          'No metal objects, comfortable clothing, arrive 30 minutes early',
      createdAt: DateTime.now().subtract(Duration(days: 7)),
      updatedAt: DateTime.now().subtract(Duration(days: 1)),
    ),
  ];

  // Test Checkup Filter
  String selectedTestFilter = 'All';
  List<String> testFilterOptions = [
    'All',
    'Today',
    'Upcoming',
    'Completed',
    'Overdue',
  ];

  // Quick Actions
  List<QuickAction> get quickActions => [
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

  @override
  void init() {
    super.init();
    _loadHealthTrackingData();
  }

  void _loadHealthTrackingData() {
    // Mock vital signs data
    _vitalSignsHistory = [
      VitalSigns(
        bloodPressureSystolic: 120,
        bloodPressureDiastolic: 80,
        heartRate: 72,
        temperature: 98.6,
        oxygenSaturation: 98,
        weight: 70.0,
        height: 175.0,
        date: DateTime.now().subtract(Duration(days: 2)),
      ),
      VitalSigns(
        bloodPressureSystolic: 118,
        bloodPressureDiastolic: 78,
        heartRate: 70,
        temperature: 98.4,
        oxygenSaturation: 99,
        weight: 69.5,
        height: 175.0,
        date: DateTime.now().subtract(Duration(days: 7)),
      ),
      VitalSigns(
        bloodPressureSystolic: 125,
        bloodPressureDiastolic: 82,
        heartRate: 75,
        temperature: 98.8,
        oxygenSaturation: 97,
        weight: 70.2,
        height: 175.0,
        date: DateTime.now().subtract(Duration(days: 14)),
      ),
    ];

    _latestVitals =
        _vitalSignsHistory.isNotEmpty ? _vitalSignsHistory.first : null;

    // Mock health metrics
    _healthMetrics = [
      {
        'name': 'Steps Today',
        'value': '8,432',
        'target': '10,000',
        'unit': 'steps',
        'icon': Icons.directions_walk,
        'color': Colors.blue,
        'progress': 0.84,
        'status': 'good',
      },
      {
        'name': 'Sleep Last Night',
        'value': '7.5',
        'target': '8.0',
        'unit': 'hours',
        'icon': Icons.bedtime,
        'color': Colors.indigo,
        'progress': 0.94,
        'status': 'good',
      },
      {
        'name': 'Water Intake',
        'value': '1.8',
        'target': '2.5',
        'unit': 'liters',
        'icon': Icons.water_drop,
        'color': Colors.cyan,
        'progress': 0.72,
        'status': 'warning',
      },
      {
        'name': 'Calories Burned',
        'value': '420',
        'target': '500',
        'unit': 'calories',
        'icon': Icons.local_fire_department,
        'color': Colors.orange,
        'progress': 0.84,
        'status': 'good',
      },
    ];
  }

  // Methods
  void markNotificationAsRead(int index) {
    notifications[index]['isRead'] = true;
    notifyListeners();
  }

  void refillMedication(int index) {
    activeMedications[index]['remaining'] += 30;
    activeMedications[index]['refillNeeded'] = false;
    notifyListeners();
  }

  void updateHealthScore(double newScore) {
    healthScore = newScore;
    notifyListeners();
  }

  double getTotalSavings() {
    return recentVisits.fold(0.0, (sum, visit) => sum + visit['savings']);
  }

  int getUnreadNotificationsCount() {
    return notifications
        .where((notification) => !notification['isRead'])
        .length;
  }

  // Test Checkup Methods
  void setTestFilter(String filter) {
    selectedTestFilter = filter;
    notifyListeners();
  }

  List<TestCheckup> getFilteredTestCheckups() {
    switch (selectedTestFilter) {
      case 'Today':
        return testCheckups.where((test) => test.isToday).toList();
      case 'Upcoming':
        return testCheckups
            .where((test) => test.isUpcoming && !test.isToday)
            .toList();
      case 'Completed':
        return testCheckups
            .where((test) => test.status == TestCheckupStatus.completed)
            .toList();
      case 'Overdue':
        return testCheckups.where((test) => test.isOverdue).toList();
      default:
        return testCheckups;
    }
  }

  int getTestCheckupCount(String filter) {
    switch (filter) {
      case 'Today':
        return testCheckups.where((test) => test.isToday).length;
      case 'Upcoming':
        return testCheckups
            .where((test) => test.isUpcoming && !test.isToday)
            .length;
      case 'Completed':
        return testCheckups
            .where((test) => test.status == TestCheckupStatus.completed)
            .length;
      case 'Overdue':
        return testCheckups.where((test) => test.isOverdue).length;
      default:
        return testCheckups.length;
    }
  }

  // Health Tracking Methods
  String getVitalSignStatus(String vitalType, dynamic value) {
    switch (vitalType) {
      case 'bloodPressure':
        final systolic = value['systolic'] as double;
        final diastolic = value['diastolic'] as double;
        if (systolic < 120 && diastolic < 80) return 'normal';
        if (systolic >= 120 && systolic < 130 && diastolic < 80)
          return 'elevated';
        if (systolic >= 130 || diastolic >= 80) return 'high';
        return 'normal';
      case 'heartRate':
        final hr = value as int;
        if (hr >= 60 && hr <= 100) return 'normal';
        if (hr < 60) return 'low';
        return 'high';
      case 'temperature':
        final temp = value as double;
        if (temp >= 97.0 && temp <= 99.0) return 'normal';
        if (temp > 99.0) return 'high';
        return 'low';
      case 'oxygenSaturation':
        final o2 = value as int;
        if (o2 >= 95) return 'normal';
        if (o2 >= 90) return 'low';
        return 'critical';
      default:
        return 'normal';
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
      case 'good':
        return Colors.green;
      case 'elevated':
      case 'low':
      case 'high':
      case 'warning':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Currency formatting helper
  String formatCurrency(double amount) {
    return 'Rs. ${amount.toStringAsFixed(0)}';
  }
}
