class SpecialOffer {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double discountPercentage;
  final double originalPrice;
  final double discountedPrice;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> targetAudience; // ['all', 'premium', 'new_users', etc.]
  final bool isActive;
  final String category; // ['appointment', 'medicine', 'test', 'consultation']
  final Map<String, dynamic>? additionalData;

  SpecialOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.discountPercentage,
    required this.originalPrice,
    required this.discountedPrice,
    required this.startDate,
    required this.endDate,
    required this.targetAudience,
    required this.isActive,
    required this.category,
    this.additionalData,
  });

  factory SpecialOffer.fromJson(Map<String, dynamic> json) {
    return SpecialOffer(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      discountedPrice: (json['discountedPrice'] ?? 0).toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      targetAudience: List<String>.from(json['targetAudience'] ?? []),
      isActive: json['isActive'] ?? false,
      category: json['category'] ?? 'general',
      additionalData: json['additionalData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'discountPercentage': discountPercentage,
      'originalPrice': originalPrice,
      'discountedPrice': discountedPrice,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'targetAudience': targetAudience,
      'isActive': isActive,
      'category': category,
      'additionalData': additionalData,
    };
  }

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isUpcoming => DateTime.now().isBefore(startDate);
  bool get isCurrentlyActive => !isExpired && !isUpcoming && isActive;

  String get formattedDiscount => '${discountPercentage.toInt()}% OFF';
  String get formattedSavings => '\$${(originalPrice - discountedPrice).toStringAsFixed(2)}';
} 