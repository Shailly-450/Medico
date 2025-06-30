import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/hospital.dart';

class HomeViewModel extends BaseViewModel {
  String userName = "John Doe";
  String userLocation = "San Francisco, CA";

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
      doctorImage: "https://img.freepik.com/free-photo/woman-doctor-wearing-lab-coat-with-stethoscope-isolated_1303-29791.jpg",
      specialty: "Cardiologist",
      isVideoCall: true,
      date: "Jun 30, 2025",
      time: "10:00 AM",
    ),
    Appointment(
      doctorName: "Dr. Michael Chen",
      doctorImage: "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
      specialty: "Dentist",
      isVideoCall: false,
      date: "Jul 01, 2025",
      time: "2:30 PM",
    ),
    Appointment(
      doctorName: "Dr. Emily Brown",
      doctorImage: "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
      specialty: "Pediatrician",
      isVideoCall: true,
      date: "Jul 03, 2025",
      time: "4:00 PM",
    ),
  ];

  List<String> specialties = ['All', 'General', 'Cardiology', 'Dental', 'Eye Care'];
  String selectedSpecialty = 'All';

  List<Doctor> doctors = [
    Doctor(
      name: "Dr. Sarah Johnson",
      imageUrl: "https://img.freepik.com/free-photo/woman-doctor-wearing-lab-coat-with-stethoscope-isolated_1303-29791.jpg",
      specialty: "Cardiologist",
      hospital: "Mount Sinai Hospital",
      rating: 4.8,
      reviews: 128,
      price: 100.0,
      isOnline: true,
    ),
    Doctor(
      name: "Dr. Michael Chen",
      imageUrl: "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
      specialty: "Dentist",
      hospital: "NYU Langone",
      rating: 4.7,
      reviews: 89,
      price: 90.0,
      isOnline: false,
    ),
    Doctor(
      name: "Dr. Emily Brown",
      imageUrl: "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
      specialty: "Pediatrician",
      hospital: "Columbia Presbyterian",
      rating: 4.9,
      reviews: 175,
      price: 110.0,
      isOnline: true,
    ),
  ];

  List<Hospital> hospitals = [
    Hospital(
      id: '1',
      name: 'Mount Sinai Hospital',
      type: 'General Hospital',
      location: 'Manhattan, NY',
      rating: 4.8,
      distance: 2.3,
      availableDoctors: 45,
      isOpen: true,
      imageUrl: 'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=400',
      specialties: ['Cardiology', 'Neurology', 'Orthopedics', 'Emergency Medicine'],
    ),
    Hospital(
      id: '2',
      name: 'NYU Langone Medical Center',
      type: 'Academic Medical Center',
      location: 'Brooklyn, NY',
      rating: 4.7,
      distance: 3.1,
      availableDoctors: 38,
      isOpen: true,
      imageUrl: 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=400',
      specialties: ['Dental', 'Pediatrics', 'Dermatology', 'Internal Medicine'],
    ),
    Hospital(
      id: '3',
      name: 'Columbia Presbyterian',
      type: 'University Hospital',
      location: 'Queens, NY',
      rating: 4.9,
      distance: 4.2,
      availableDoctors: 52,
      isOpen: false,
      imageUrl: 'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=400',
      specialties: ['Pediatrics', 'Cardiology', 'Oncology', 'Surgery'],
    ),
    Hospital(
      id: '4',
      name: 'Memorial Sloan Kettering',
      type: 'Specialty Hospital',
      location: 'Bronx, NY',
      rating: 4.6,
      distance: 5.8,
      availableDoctors: 28,
      isOpen: true,
      imageUrl: 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=400',
      specialties: ['Oncology', 'Radiation Therapy', 'Palliative Care'],
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