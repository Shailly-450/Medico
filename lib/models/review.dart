class Review {
  final String id;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final double rating;
  final String comment;
  final DateTime timestamp;
  final bool isVerified;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.rating,
    required this.comment,
    required this.timestamp,
    this.isVerified = false,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatarUrl: json['userAvatarUrl'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
      'isVerified': isVerified,
    };
  }
}

class HospitalStats {
  final Map<String, int> ratingDistribution;
  final double averageRating;
  final int totalReviews;
  final Map<String, double> serviceRatings;
  final List<String> topFeatures;

  HospitalStats({
    required this.ratingDistribution,
    required this.averageRating,
    required this.totalReviews,
    required this.serviceRatings,
    required this.topFeatures,
  });

  factory HospitalStats.fromJson(Map<String, dynamic> json) {
    return HospitalStats(
      ratingDistribution:
          Map<String, int>.from(json['ratingDistribution'] ?? {}),
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      serviceRatings: Map<String, double>.from(json['serviceRatings'] ?? {}),
      topFeatures: List<String>.from(json['topFeatures'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ratingDistribution': ratingDistribution,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'serviceRatings': serviceRatings,
      'topFeatures': topFeatures,
    };
  }
}
