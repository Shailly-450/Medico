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
}
