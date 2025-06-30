import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';

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
  
  // Quick Actions
  List<Map<String, dynamic>> quickActions = [
    {
      'title': 'Book Appointment',
      'icon': Icons.calendar_today,
      'color': Colors.blue,
    },
    {
      'title': 'Refill Medicine',
      'icon': Icons.medication,
      'color': Colors.green,
    },
    {
      'title': 'Health Records',
      'icon': Icons.folder,
      'color': Colors.orange,
    },
    {
      'title': 'Cost Analysis',
      'icon': Icons.analytics,
      'color': Colors.purple,
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
    return notifications.where((notification) => !notification['isRead']).length;
  }
  
  // Currency formatting helper
  String formatCurrency(double amount) {
    return 'Rs. ${amount.toStringAsFixed(0)}';
  }
} 