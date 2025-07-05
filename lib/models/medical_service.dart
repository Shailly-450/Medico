class MedicalService {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String currency;
  final int duration; // in minutes
  final List<String> includedTests;
  final List<String> requirements;
  final String? notes;
  final bool isAvailable;
  final double rating;
  final int reviewCount;

  MedicalService({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.currency = 'INR',
    required this.duration,
    this.includedTests = const [],
    this.requirements = const [],
    this.notes,
    this.isAvailable = true,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  factory MedicalService.fromJson(Map<String, dynamic> json) {
    return MedicalService(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'INR',
      duration: json['duration'] ?? 0,
      includedTests: List<String>.from(json['includedTests'] ?? []),
      requirements: List<String>.from(json['requirements'] ?? []),
      notes: json['notes'],
      isAvailable: json['isAvailable'] ?? true,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'currency': currency,
      'duration': duration,
      'includedTests': includedTests,
      'requirements': requirements,
      'notes': notes,
      'isAvailable': isAvailable,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }
} 