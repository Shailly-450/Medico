class Blog {
  final String id;
  final String title;
  final String content;
  final String excerpt;
  final String author;
  final String authorAvatar;
  final DateTime publishedDate;
  final String imageUrl;
  final List<String> tags;
  final String category;
  final int readTime; // in minutes
  final int views;
  final int likes;
  final bool isBookmarked;
  final bool isFeatured;

  Blog({
    required this.id,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.author,
    required this.authorAvatar,
    required this.publishedDate,
    required this.imageUrl,
    required this.tags,
    required this.category,
    required this.readTime,
    required this.views,
    required this.likes,
    this.isBookmarked = false,
    this.isFeatured = false,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      excerpt: json['excerpt'] ?? '',
      author: json['author'] ?? '',
      authorAvatar: json['authorAvatar'] ?? '',
      publishedDate: DateTime.parse(json['publishedDate'] ?? DateTime.now().toIso8601String()),
      imageUrl: json['imageUrl'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'] ?? '',
      readTime: json['readTime'] ?? 5,
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      isBookmarked: json['isBookmarked'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'excerpt': excerpt,
      'author': author,
      'authorAvatar': authorAvatar,
      'publishedDate': publishedDate.toIso8601String(),
      'imageUrl': imageUrl,
      'tags': tags,
      'category': category,
      'readTime': readTime,
      'views': views,
      'likes': likes,
      'isBookmarked': isBookmarked,
      'isFeatured': isFeatured,
    };
  }

  Blog copyWith({
    String? id,
    String? title,
    String? content,
    String? excerpt,
    String? author,
    String? authorAvatar,
    DateTime? publishedDate,
    String? imageUrl,
    List<String>? tags,
    String? category,
    int? readTime,
    int? views,
    int? likes,
    bool? isBookmarked,
    bool? isFeatured,
  }) {
    return Blog(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      excerpt: excerpt ?? this.excerpt,
      author: author ?? this.author,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      publishedDate: publishedDate ?? this.publishedDate,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      readTime: readTime ?? this.readTime,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
} 