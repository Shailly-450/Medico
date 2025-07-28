import 'medical_service.dart';
import 'hospital.dart';

class ServiceProvider {
  final String id;
  final String name;
  final String type;
  final String description;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final bool isOpen;
  final String workingHours;
  final List<String> facilities;
  final List<String> specialties;
  final List<String> accreditation;
  final double averagePrice;
  final int totalServices;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Location information
  final ProviderLocation location;
  
  // Contact information
  final ProviderContact contact;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.isOpen,
    required this.workingHours,
    required this.facilities,
    required this.specialties,
    required this.accreditation,
    required this.averagePrice,
    required this.totalServices,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.location,
    required this.contact,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      isOpen: json['isOpen'] ?? true,
      workingHours: json['workingHours'] ?? '',
      facilities: List<String>.from(json['facilities'] ?? []),
      specialties: List<String>.from(json['specialties'] ?? []),
      accreditation: List<String>.from(json['accreditation'] ?? []),
      averagePrice: (json['averagePrice'] ?? 0.0).toDouble(),
      totalServices: json['totalServices'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      location: ProviderLocation.fromJson(json['location'] ?? {}),
      contact: ProviderContact.fromJson(json['contact'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'type': type,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'isOpen': isOpen,
      'workingHours': workingHours,
      'facilities': facilities,
      'specialties': specialties,
      'accreditation': accreditation,
      'averagePrice': averagePrice,
      'totalServices': totalServices,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'location': location.toJson(),
      'contact': contact.toJson(),
    };
  }

  ServiceProvider copyWith({
    String? id,
    String? name,
    String? type,
    String? description,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    bool? isOpen,
    String? workingHours,
    List<String>? facilities,
    List<String>? specialties,
    List<String>? accreditation,
    double? averagePrice,
    int? totalServices,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProviderLocation? location,
    ProviderContact? contact,
  }) {
    return ServiceProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isOpen: isOpen ?? this.isOpen,
      workingHours: workingHours ?? this.workingHours,
      facilities: facilities ?? this.facilities,
      specialties: specialties ?? this.specialties,
      accreditation: accreditation ?? this.accreditation,
      averagePrice: averagePrice ?? this.averagePrice,
      totalServices: totalServices ?? this.totalServices,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
      contact: contact ?? this.contact,
    );
  }

  @override
  String toString() {
    return 'ServiceProvider(id: $id, name: $name, type: $type, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceProvider && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ProviderLocation {
  final String address;
  final List<double> coordinates;
  final String area;
  final String city;
  final String state;
  final String pincode;
  final double distance;

  ProviderLocation({
    required this.address,
    required this.coordinates,
    required this.area,
    required this.city,
    required this.state,
    required this.pincode,
    required this.distance,
  });

  factory ProviderLocation.fromJson(Map<String, dynamic> json) {
    return ProviderLocation(
      address: json['address'] ?? '',
      coordinates: List<double>.from(json['coordinates'] ?? []),
      area: json['area'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      distance: (json['distance'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'coordinates': coordinates,
      'area': area,
      'city': city,
      'state': state,
      'pincode': pincode,
      'distance': distance,
    };
  }

  String get fullAddress => '$address, $area, $city, $state - $pincode';
  
  String get shortAddress => '$area, $city';
}

class ProviderContact {
  final String phone;
  final String email;
  final String website;
  final String emergencyContact;

  ProviderContact({
    required this.phone,
    required this.email,
    required this.website,
    required this.emergencyContact,
  });

  factory ProviderContact.fromJson(Map<String, dynamic> json) {
    return ProviderContact(
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      emergencyContact: json['emergencyContact'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'email': email,
      'website': website,
      'emergencyContact': emergencyContact,
    };
  }
} 