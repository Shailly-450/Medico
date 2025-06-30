import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/offer_package.dart';
import '../models/hospital_clinic.dart';
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

  // Offers & Packages data
  List<OfferPackage> offers = [
    OfferPackage(
      id: '1',
      title: 'Health Checkup Package',
      description:
          'Complete body checkup with blood tests, ECG, and consultation',
      imageUrl:
          'https://img.freepik.com/free-photo/medical-stethoscope-laptop-keyboard_23-2147862719.jpg',
      originalPrice: 299.99,
      discountedPrice: 199.99,
      discountPercentage: 33,
      validUntil: DateTime.now().add(const Duration(days: 15)),
      includedServices: ['Blood Test', 'ECG', 'Consultation', 'X-Ray'],
      terms: 'Valid for 15 days. Non-refundable. Prior appointment required.',
    ),
    OfferPackage(
      id: '2',
      title: 'Dental Care Special',
      description: 'Complete dental checkup with cleaning and consultation',
      imageUrl:
          'https://img.freepik.com/free-photo/medical-equipment-dentistry_23-2148847898.jpg',
      originalPrice: 149.99,
      discountedPrice: 99.99,
      discountPercentage: 33,
      validUntil: DateTime.now().add(const Duration(days: 10)),
      includedServices: ['Dental Cleaning', 'Consultation', 'X-Ray'],
      terms: 'Valid for 10 days. Includes basic cleaning only.',
    ),
    OfferPackage(
      id: '3',
      title: 'Eye Care Bundle',
      description: 'Complete eye examination with prescription glasses',
      imageUrl:
          'https://img.freepik.com/free-photo/medical-equipment-dentistry_23-2148847898.jpg',
      originalPrice: 199.99,
      discountedPrice: 149.99,
      discountPercentage: 25,
      validUntil: DateTime.now().add(const Duration(days: 20)),
      includedServices: ['Eye Test', 'Consultation', 'Prescription'],
      terms: 'Valid for 20 days. Frame selection limited to basic models.',
    ),
  ];

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

  // Hospitals & Clinics data
  List<HospitalClinic> hospitals = [
    HospitalClinic(
      id: '1',
      name: 'Mount Sinai Hospital',
      address: '1 Gustave L. Levy Place, New York, NY 10029',
      phone: '+1 (212) 241-6500',
      email: 'info@mountsinai.org',
      imageUrl:
          'https://images.unsplash.com/photo-1516841273335-e39b37888115?auto=format&fit=crop&w=800&q=80',
      rating: 4.8,
      reviewCount: 1250,
      specialties: ['Cardiology', 'Neurology', 'Emergency Care', 'Surgery'],
      isOpen: true,
      workingHours: '24/7',
      distance: 2.5,
      facilities: ['ICU', 'Emergency Room', 'Surgery Center', 'Laboratory'],
    ),
    HospitalClinic(
      id: '2',
      name: 'NYU Langone Medical Center',
      address: '550 First Avenue, New York, NY 10016',
      phone: '+1 (212) 263-7300',
      email: 'info@nyulangone.org',
      imageUrl:
          'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=800&q=80',
      rating: 4.7,
      reviewCount: 980,
      specialties: [
        'Dental Care',
        'Orthopedics',
        'Cancer Treatment',
        'Pediatrics'
      ],
      isOpen: true,
      workingHours: '6:00 AM - 10:00 PM',
      distance: 3.2,
      facilities: [
        'Dental Clinic',
        'Cancer Center',
        'Pediatric Ward',
        'Pharmacy'
      ],
    ),
    HospitalClinic(
      id: '3',
      name: 'Columbia Presbyterian',
      address: '622 West 168th Street, New York, NY 10032',
      phone: '+1 (212) 305-2500',
      email: 'info@columbia.org',
      imageUrl:
          'https://images.unsplash.com/photo-1587351021759-3e566b6af7cc?auto=format&fit=crop&w=800&q=80',
      rating: 4.9,
      reviewCount: 1450,
      specialties: ['Eye Care', 'Mental Health', 'Women\'s Health', 'Research'],
      isOpen: true,
      workingHours: '7:00 AM - 9:00 PM',
      distance: 4.1,
      facilities: [
        'Eye Clinic',
        'Mental Health Center',
        'Women\'s Health',
        'Research Lab'
      ],
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
