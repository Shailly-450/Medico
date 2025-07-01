import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/hospital.dart';
import '../models/offer_package.dart';
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
      id: '1',
      name: "Dr. Sarah Johnson",
      imageUrl:
          "https://img.freepik.com/free-photo/woman-doctor-wearing-lab-coat-with-stethoscope-isolated_1303-29791.jpg",
      specialty: "Cardiologist",
      hospital: "Mount Sinai Hospital",
      rating: 4.8,
      reviews: 128,
      price: 100.0,
      isOnline: true,
      isAvailable: true,
      experience: 15,
      education: 'MBBS, MD - Cardiology, Harvard Medical School',
      languages: ['English', 'Spanish'],
      specializations: [
        'Interventional Cardiology',
        'Heart Failure',
        'Preventive Cardiology'
      ],
      about:
          'Dr. Sarah Johnson is a board-certified cardiologist with over 15 years of experience.',
      availability: {
        'Monday': '9:00 AM - 5:00 PM',
        'Tuesday': '9:00 AM - 5:00 PM',
        'Wednesday': '9:00 AM - 5:00 PM',
        'Thursday': '9:00 AM - 5:00 PM',
        'Friday': '9:00 AM - 5:00 PM',
        'Saturday': '9:00 AM - 2:00 PM',
        'Sunday': 'Closed',
      },
      awards: ['Best Cardiologist 2023', 'Excellence in Patient Care Award'],
      consultationFee: '₹1200',
      acceptsInsurance: true,
      insuranceProviders: ['Max Bupa', 'HDFC Health', 'ICICI Lombard'],
      location: 'New York, NY',
      distance: 0.8,
      isVerified: true,
      phoneNumber: '+1 555-123-4567',
      email: 'dr.sarah.johnson@hospital.com',
      symptoms: ['Chest Pain', 'Heart Palpitations', 'High Blood Pressure'],
      videoCall: true,
    ),
    Doctor(
      id: '2',
      name: "Dr. Michael Chen",
      imageUrl:
          "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
      specialty: "Dentist",
      hospital: "NYU Langone",
      rating: 4.7,
      reviews: 89,
      price: 90.0,
      isOnline: false,
      isAvailable: true,
      experience: 12,
      education: 'BDS, MDS - Orthodontics, NYU School of Dentistry',
      languages: ['English', 'Mandarin'],
      specializations: [
        'Orthodontics',
        'Cosmetic Dentistry',
        'Root Canal Treatment'
      ],
      about:
          'Dr. Michael Chen is a skilled dentist with expertise in orthodontics.',
      availability: {
        'Monday': '10:00 AM - 6:00 PM',
        'Tuesday': '10:00 AM - 6:00 PM',
        'Wednesday': '10:00 AM - 6:00 PM',
        'Thursday': '10:00 AM - 6:00 PM',
        'Friday': '10:00 AM - 6:00 PM',
        'Saturday': '9:00 AM - 3:00 PM',
        'Sunday': 'Closed',
      },
      awards: ['Best Dentist Award 2022', 'Patient Choice Award'],
      consultationFee: '₹800',
      acceptsInsurance: true,
      insuranceProviders: ['Max Bupa', 'Star Health'],
      location: 'New York, NY',
      distance: 1.2,
      isVerified: true,
      phoneNumber: '+1 555-234-5678',
      email: 'dr.michael.chen@dental.com',
      symptoms: ['Tooth Pain', 'Gum Problems', 'Teeth Whitening'],
      videoCall: false,
    ),
    Doctor(
      id: '3',
      name: "Dr. Emily Brown",
      imageUrl:
          "https://img.freepik.com/free-photo/beautiful-young-female-doctor-looking-camera-office_1301-7807.jpg",
      specialty: "Pediatrician",
      hospital: "Columbia Presbyterian",
      rating: 4.9,
      reviews: 175,
      price: 110.0,
      isOnline: true,
      isAvailable: true,
      experience: 18,
      education: 'MBBS, MD - Pediatrics, Columbia University',
      languages: ['English', 'Spanish'],
      specializations: [
        'General Pediatrics',
        'Child Development',
        'Vaccination'
      ],
      about:
          'Dr. Emily Brown is a compassionate pediatrician with 18 years of experience.',
      availability: {
        'Monday': '8:00 AM - 4:00 PM',
        'Tuesday': '8:00 AM - 4:00 PM',
        'Wednesday': '8:00 AM - 4:00 PM',
        'Thursday': '8:00 AM - 4:00 PM',
        'Friday': '8:00 AM - 4:00 PM',
        'Saturday': '8:00 AM - 12:00 PM',
        'Sunday': 'Closed',
      },
      awards: ['Best Pediatrician 2023', 'Child Care Excellence Award'],
      consultationFee: '₹1000',
      acceptsInsurance: true,
      insuranceProviders: ['Max Bupa', 'HDFC Health', 'Star Health'],
      location: 'New York, NY',
      distance: 2.5,
      isVerified: true,
      phoneNumber: '+1 555-345-6789',
      email: 'dr.emily.brown@children.com',
      symptoms: ['Fever', 'Cough', 'Growth Concerns', 'Vaccination'],
      videoCall: true,
    ),
  ];

  List<Hospital> hospitals = [
    Hospital(
      id: '1',
      name: 'Mount Sinai Hospital',
      type: 'General Hospital',
      location: '1468 Madison Ave, New York, NY 10029',
      rating: 4.8,
      distance: 0.8,
      availableDoctors: 45,
      isOpen: true,
      imageUrl:
          'https://img.freepik.com/free-photo/modern-hospital-building_1417-1205.jpg',
      specialties: ['Cardiology', 'Emergency Medicine', 'Surgery', 'Neurology'],
      description: 'A leading hospital in New York with 24/7 emergency care.',
    ),
    Hospital(
      id: '2',
      name: 'NYU Langone Health',
      type: 'Academic Medical Center',
      location: '550 1st Ave, New York, NY 10016',
      rating: 4.7,
      distance: 1.2,
      availableDoctors: 38,
      isOpen: true,
      imageUrl:
          'https://img.freepik.com/free-photo/hospital-building_1417-1206.jpg',
      specialties: ['Orthopedics', 'Dental Care', 'Dermatology', 'Pediatrics'],
      description: 'Comprehensive care and advanced medical research.',
    ),
    Hospital(
      id: '3',
      name: 'Columbia Presbyterian Hospital',
      type: 'University Hospital',
      location: '622 W 168th St, New York, NY 10032',
      rating: 4.9,
      distance: 2.5,
      availableDoctors: 52,
      isOpen: false,
      imageUrl:
          'https://img.freepik.com/free-photo/hospital-entrance_1417-1207.jpg',
      specialties: ['Pediatrics', 'Cardiology', 'Oncology', 'Surgery'],
      description: 'Renowned for pediatric and cardiac care.',
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
