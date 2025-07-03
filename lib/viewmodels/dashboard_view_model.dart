import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/test_checkup.dart';

class DashboardViewModel extends BaseViewModel {
  String userName = 'John Doe';
  String userLocation = 'New York, NY';

  // Health Overview Data
  double totalSavings = 2450.00;
  int visitsThisMonth = 3;
  int visitsThisYear = 12;
  double healthScore = 85.0;
  bool hasInsurance = true;

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
    'Overdue'
  ];

  // Quick Actions
  List<Map<String, dynamic>> quickActions = [
    {
      'title': 'Book Appointment',
      'icon': Icons.calendar_today,
      'color': Colors.blue,
    },
    {
      'title': 'Calendar View',
      'icon': Icons.calendar_month,
      'color': Colors.indigo,
    },
    {
      'title': 'Medicine Reminders',
      'icon': Icons.medication,
      'color': Colors.green,
    },
    {
      'title': 'Test Checkups',
      'icon': Icons.science,
      'color': Colors.purple,
    },
    {
      'title': 'Health Records',
      'icon': Icons.folder,
      'color': Colors.orange,
    },
  ];

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

  // Currency formatting helper
  String formatCurrency(double amount) {
    return 'Rs. ${amount.toStringAsFixed(0)}';
  }
}
