class ArticleContent {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String imageUrl;
  final String author;
  final String authorAvatarUrl;
  final DateTime publishedAt;
  final int readTime; // in minutes
  final int views;
  final int likes;
  final List<String> tags;
  final String category;
  final bool isPremium;
  final double rating;
  final bool isBookmarked;

  ArticleContent({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.imageUrl,
    required this.author,
    required this.authorAvatarUrl,
    required this.publishedAt,
    required this.readTime,
    required this.views,
    required this.likes,
    required this.tags,
    required this.category,
    this.isPremium = false,
    this.rating = 0.0,
    this.isBookmarked = false,
  });

  factory ArticleContent.fromJson(Map<String, dynamic> json) {
    return ArticleContent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      author: json['author'] ?? '',
      authorAvatarUrl: json['authorAvatarUrl'] ?? '',
      publishedAt: DateTime.parse(
          json['publishedAt'] ?? DateTime.now().toIso8601String()),
      readTime: json['readTime'] ?? 0,
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'] ?? '',
      isPremium: json['isPremium'] ?? false,
      rating: (json['rating'] ?? 0.0).toDouble(),
      isBookmarked: json['isBookmarked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'imageUrl': imageUrl,
      'author': author,
      'authorAvatarUrl': authorAvatarUrl,
      'publishedAt': publishedAt.toIso8601String(),
      'readTime': readTime,
      'views': views,
      'likes': likes,
      'tags': tags,
      'category': category,
      'isPremium': isPremium,
      'rating': rating,
      'isBookmarked': isBookmarked,
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

  String get readTimeText {
    return '$readTime min read';
  }
}
