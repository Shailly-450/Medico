import 'package:flutter/material.dart';
import '../../../models/article_content.dart';
import '../../../core/theme/app_colors.dart';

class CompactArticleCard extends StatelessWidget {
  final ArticleContent article;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;
  final double? width;

  const CompactArticleCard({
    Key? key,
    required this.article,
    this.onTap,
    this.onBookmark,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Article image with category badge
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(article.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Category badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        article.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  // Premium badge
                  if (article.isPremium)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Bookmark button
                  if (onBookmark != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onBookmark,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            article.isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            size: 16,
                            color: article.isBookmarked
                                ? AppColors.accent
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Author and metadata
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage:
                              NetworkImage(article.authorAvatarUrl),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.author,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textBlack,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${article.timeAgo} • ${article.readTimeText}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Rating
                        if (article.rating > 0)
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 12,
                                color: Colors.amber[700],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                article.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
