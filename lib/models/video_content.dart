class VideoContent {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final String duration; // Format: "MM:SS"
  final String author;
  final String authorAvatarUrl;
  final DateTime publishedAt;
  final int views;
  final int likes;
  final List<String> tags;
  final String category;
  final bool isPremium;
  final double rating;

  VideoContent({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.duration,
    required this.author,
    required this.authorAvatarUrl,
    required this.publishedAt,
    required this.views,
    required this.likes,
    required this.tags,
    required this.category,
    this.isPremium = false,
    this.rating = 0.0,
  });

  factory VideoContent.fromJson(Map<String, dynamic> json) {
    return VideoContent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      duration: json['duration'] ?? '00:00',
      author: json['author'] ?? '',
      authorAvatarUrl: json['authorAvatarUrl'] ?? '',
      publishedAt: DateTime.parse(
          json['publishedAt'] ?? DateTime.now().toIso8601String()),
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'] ?? '',
      isPremium: json['isPremium'] ?? false,
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'duration': duration,
      'author': author,
      'authorAvatarUrl': authorAvatarUrl,
      'publishedAt': publishedAt.toIso8601String(),
      'views': views,
      'likes': likes,
      'tags': tags,
      'category': category,
      'isPremium': isPremium,
      'rating': rating,
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String get formattedViews {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    }
    return views.toString();
  }
}
