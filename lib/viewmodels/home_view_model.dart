import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';
import 'notification_view_model.dart';

class HomeViewModel extends BaseViewModel {
  String userName = "John Doe";
  String userLocation = "San Francisco, CA";

  // Unread notification count (matches the notification data)
  int get unreadCount => 5; // 5 unread notifications in the dummy data

  List<Map<String, dynamic>> categories = [
    {'name': 'General', 'icon': Icons.medical_services},
    {'name': 'Cardiology', 'icon': Icons.favorite},
    {'name': 'Dental', 'icon': Icons.face},
    {'name': 'Eye Care', 'icon': Icons.remove_red_eye},
    {'name': 'Pediatric', 'icon': Icons.child_care},
  ];

  String selectedCategory = 'General';

  List<Appointment> upcomingAppointments = [
    Appointment(
      doctorName: "Dr. Sarah Johnson",
      doctorImage:
          "https://img.freepik.com/free-photo/woman-doctor-wearing-lab-coat-with-stethoscope-isolated_1303-29791.jpg",
      specialty: "Cardiologist",
      isVideoCall: true,
      date: "Jun 30, 2025",
      time: "10:00 AM",
    ),
    Appointment(
      doctorName: "Dr. Michael Chen",
      doctorImage:
          "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
      specialty: "Dentist",
      isVideoCall: false,
      date: "Jul 01, 2025",
      time: "2:30 PM",
    ),
    Appointment(
      doctorName: "Dr. Emily Brown",
      doctorImage:
          "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
      specialty: "Pediatrician",
      isVideoCall: true,
      date: "Jul 03, 2025",
      time: "4:00 PM",
    ),
  ];

  List<String> specialties = [
    'All',
    'General',
    'Cardiology',
    'Dental',
    'Eye Care'
  ];
  String selectedSpecialty = 'All';

  List<Doctor> doctors = [
    Doctor(
      name: "Dr. Sarah Johnson",
      imageUrl:
          "https://img.freepik.com/free-photo/woman-doctor-wearing-lab-coat-with-stethoscope-isolated_1303-29791.jpg",
      specialty: "Cardiologist",
      hospital: "Mount Sinai Hospital",
      rating: 4.8,
      reviews: 128,
      price: 100.0,
      isOnline: true,
    ),
    Doctor(
      name: "Dr. Michael Chen",
      imageUrl:
          "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
      specialty: "Dentist",
      hospital: "NYU Langone",
      rating: 4.7,
      reviews: 89,
      price: 90.0,
      isOnline: false,
    ),
    Doctor(
      name: "Dr. Emily Brown",
      imageUrl:
          "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
      specialty: "Pediatrician",
      hospital: "Columbia Presbyterian",
      rating: 4.9,
      reviews: 175,
      price: 110.0,
      isOnline: true,
    ),
  ];

  void setSpecialty(String specialty) {
    selectedSpecialty = specialty;
    notifyListeners();
  }

  void setCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }
}
