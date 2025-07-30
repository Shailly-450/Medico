class MedicalService {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? subcategory;
  final double price;
  final String currency;
  final int duration; // in minutes
  final List<String> includedTests;
  final List<String> requirements;
  final String? notes;
  final bool isAvailable;
  final bool isActive;
  final bool requiresPrescription;
  final bool requiresAppointment;
  final String? preparationInstructions;
  final String? postServiceInstructions;
  final List<String> risks;
  final List<String> contraindications;
  final List<String> tags;
  final String? provider;
  final String? location;
  final bool insuranceCoverage;
  final List<Map<String, dynamic>> insuranceCodes;
  final double rating;
  final int reviewCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MedicalService({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.subcategory,
    required this.price,
    this.currency = 'USD',
    required this.duration,
    this.includedTests = const [],
    this.requirements = const [],
    this.notes,
    this.isAvailable = true,
    this.isActive = true,
    this.requiresPrescription = false,
    this.requiresAppointment = false,
    this.preparationInstructions,
    this.postServiceInstructions,
    this.risks = const [],
    this.contraindications = const [],
    this.tags = const [],
    this.provider,
    this.location,
    this.insuranceCoverage = false,
    this.insuranceCodes = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory MedicalService.fromJson(Map<String, dynamic> json) {
    final price = (json['price'] is num)
        ? (json['price'] as num).toDouble()
        : (json['averagePrice'] is num)
            ? (json['averagePrice'] as num).toDouble()
            : 0.0;
    
    return MedicalService(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      subcategory: json['subcategory'],
      price: price,
      currency: json['currency'] ?? 'USD',
      duration: json['duration'] ?? json['averageDuration'] ?? 0,
      includedTests: List<String>.from(json['includedTests'] ?? []),
      requirements: List<String>.from(json['requirements'] ?? []),
      notes: json['notes'],
      isAvailable: json['isAvailable'] ?? true,
      isActive: json['isActive'] ?? true,
      requiresPrescription: json['requiresPrescription'] ?? false,
      requiresAppointment: json['requiresAppointment'] ?? false,
      preparationInstructions: json['preparationInstructions'],
      postServiceInstructions: json['postServiceInstructions'],
      risks: List<String>.from(json['risks'] ?? []),
      contraindications: List<String>.from(json['contraindications'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      provider: json['provider'],
      location: json['location'],
      insuranceCoverage: json['insuranceCoverage'] ?? false,
      insuranceCodes: List<Map<String, dynamic>>.from(json['insuranceCodes'] ?? []),
      rating: (json['rating'] != null && json['rating']['average'] is num)
          ? (json['rating']['average'] as num).toDouble()
          : 0.0,
      reviewCount: (json['rating'] != null && json['rating']['count'] is int)
          ? json['rating']['count'] as int
          : 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'subcategory': subcategory,
      'price': price,
      'currency': currency,
      'duration': duration,
      'includedTests': includedTests,
      'requirements': requirements,
      'notes': notes,
      'isAvailable': isAvailable,
      'isActive': isActive,
      'requiresPrescription': requiresPrescription,
      'requiresAppointment': requiresAppointment,
      'preparationInstructions': preparationInstructions,
      'postServiceInstructions': postServiceInstructions,
      'risks': risks,
      'contraindications': contraindications,
      'tags': tags,
      'provider': provider,
      'location': location,
      'insuranceCoverage': insuranceCoverage,
      'insuranceCodes': insuranceCodes,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Helper methods
  String get displayName => name;
  String get displayCategory => subcategory ?? category;
  String get displayPrice => '$currency $price';
  String get displayDuration => '${duration} min';
  bool get hasInsurance => insuranceCoverage;
  bool get needsPrescription => requiresPrescription;
  bool get needsAppointment => requiresAppointment;
} 