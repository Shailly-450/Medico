class DoctorReview {
  final String id;
  final String doctorId;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final double rating;
  final String comment;
  final DateTime timestamp;
  final bool isVerified;
  final String consultationType; // 'In-person', 'Online', 'Emergency'
  final String? treatmentOutcome;
  final bool wouldRecommend;
  final Map<String, double>? categoryRatings; // bedside manner, expertise, etc.

  DoctorReview({
    required this.id,
    required this.doctorId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.rating,
    required this.comment,
    required this.timestamp,
    required this.isVerified,
    required this.consultationType,
    this.treatmentOutcome,
    required this.wouldRecommend,
    this.categoryRatings,
  });

  factory DoctorReview.fromJson(Map<String, dynamic> json) {
    return DoctorReview(
      id: json['id'] ?? '',
      doctorId: json['doctorId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatarUrl: json['userAvatarUrl'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isVerified: json['isVerified'] ?? false,
      consultationType: json['consultationType'] ?? 'In-person',
      treatmentOutcome: json['treatmentOutcome'],
      wouldRecommend: json['wouldRecommend'] ?? true,
      categoryRatings: json['categoryRatings'] != null
          ? Map<String, double>.from(json['categoryRatings'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
      'isVerified': isVerified,
      'consultationType': consultationType,
      'treatmentOutcome': treatmentOutcome,
      'wouldRecommend': wouldRecommend,
      'categoryRatings': categoryRatings,
    };
  }
}
