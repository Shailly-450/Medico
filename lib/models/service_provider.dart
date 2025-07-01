import 'medical_service.dart';
import 'hospital.dart';

class ServiceProvider {
  final String id;
  final String name;
  final String type; // 'hospital' or 'clinic'
  final String location;
  final double rating;
  final int reviewCount;
  final double distance;
  final bool isOpen;
  final String? imageUrl;
  final String? description;
  final List<String> specialties;
  final Map<String, dynamic>? contactInfo;
  final List<MedicalService> services;
  final String workingHours;
  final List<String> facilities;
  final double averagePrice;
  final int totalServices;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.isOpen,
    this.imageUrl,
    this.description,
    this.specialties = const [],
    this.contactInfo,
    this.services = const [],
    this.workingHours = '',
    this.facilities = const [],
    this.averagePrice = 0.0,
    this.totalServices = 0,
  });

  factory ServiceProvider.fromHospital(Hospital hospital, List<MedicalService> services) {
    double avgPrice = services.isNotEmpty 
        ? services.map((s) => s.price).reduce((a, b) => a + b) / services.length 
        : 0.0;
    
    return ServiceProvider(
      id: hospital.id,
      name: hospital.name,
      type: hospital.type,
      location: hospital.location,
      rating: hospital.rating,
      reviewCount: 0, // Hospital model doesn't have reviewCount
      distance: hospital.distance,
      isOpen: hospital.isOpen,
      imageUrl: hospital.imageUrl,
      description: hospital.description,
      specialties: hospital.specialties,
      contactInfo: hospital.contactInfo,
      services: services,
      averagePrice: avgPrice,
      totalServices: services.length,
    );
  }

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      location: json['location'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      distance: (json['distance'] ?? 0.0).toDouble(),
      isOpen: json['isOpen'] ?? false,
      imageUrl: json['imageUrl'],
      description: json['description'],
      specialties: List<String>.from(json['specialties'] ?? []),
      contactInfo: json['contactInfo'],
      services: (json['services'] as List<dynamic>?)
          ?.map((service) => MedicalService.fromJson(service))
          .toList() ?? [],
      workingHours: json['workingHours'] ?? '',
      facilities: List<String>.from(json['facilities'] ?? []),
      averagePrice: (json['averagePrice'] ?? 0.0).toDouble(),
      totalServices: json['totalServices'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'location': location,
      'rating': rating,
      'reviewCount': reviewCount,
      'distance': distance,
      'isOpen': isOpen,
      'imageUrl': imageUrl,
      'description': description,
      'specialties': specialties,
      'contactInfo': contactInfo,
      'services': services.map((service) => service.toJson()).toList(),
      'workingHours': workingHours,
      'facilities': facilities,
      'averagePrice': averagePrice,
      'totalServices': totalServices,
    };
  }
} 