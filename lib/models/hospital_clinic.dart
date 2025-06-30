class HospitalClinic {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final List<String> specialties;
  final bool isOpen;
  final String workingHours;
  final double distance;
  final List<String> facilities;

  HospitalClinic({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.specialties,
    required this.isOpen,
    required this.workingHours,
    required this.distance,
    required this.facilities,
  });
}
