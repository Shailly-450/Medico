class OfferPackage {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double originalPrice;
  final double discountedPrice;
  final int discountPercentage;
  final DateTime validUntil;
  final List<String> includedServices;
  final String terms;
  final bool isActive;

  OfferPackage({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercentage,
    required this.validUntil,
    required this.includedServices,
    required this.terms,
    this.isActive = true,
  });

  factory OfferPackage.fromJson(Map<String, dynamic> json) {
    return OfferPackage(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      originalPrice: (json['originalPrice'] is int ? (json['originalPrice'] as int).toDouble() : json['originalPrice'] ?? 0.0),
      discountedPrice: (json['discountedPrice'] is int ? (json['discountedPrice'] as int).toDouble() : json['discountedPrice'] ?? 0.0),
      discountPercentage: json['discountPercentage'] is String ? int.tryParse(json['discountPercentage']) ?? 0 : (json['discountPercentage'] ?? 0),
      validUntil: DateTime.tryParse(json['validUntil'] ?? '') ?? DateTime.now(),
      includedServices: (json['includedServices'] as List?)?.map((e) => e.toString()).toList() ?? [],
      terms: json['terms'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }
}
