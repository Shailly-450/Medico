import 'package:flutter/material.dart';
import '../../../models/article_content.dart';
import '../../../core/theme/app_colors.dart';

class ArticleCard extends StatelessWidget {
  final ArticleContent article;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;
  final bool showActions;
  final bool isCompact;

  const ArticleCard({
    Key? key,
    required this.article,
    this.onTap,
    this.onLike,
    this.onShare,
    this.onBookmark,
    this.showActions = true,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: isCompact ? _buildCompactLayout() : _buildFullLayout(),
      ),
    );
  }

  Widget _buildCompactLayout() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Article image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(article.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category and read time
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.paleBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        article.category,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      article.readTimeText,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
                const SizedBox(height: 4),
                // Author and time
                Text(
                  '${article.author} • ${article.timeAgo}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Bookmark button
          if (showActions)
            IconButton(
              onPressed: onBookmark,
              icon: Icon(
                article.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                size: 20,
                color: article.isBookmarked
                    ? AppColors.accent
                    : AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFullLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Article image
        Stack(
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                image: DecorationImage(
                  image: NetworkImage(article.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Premium badge
            if (article.isPremium)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PREMIUM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            // Category badge
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
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
          ],
        ),
        // Content section
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                article.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Summary
              Text(
                article.summary,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Author and metadata
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(article.authorAvatarUrl),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.author,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textBlack,
                          ),
                        ),
                        Text(
                          '${article.timeAgo} • ${article.readTimeText} • ${article.formattedViews} views',
                          style: TextStyle(
                            fontSize: 12,
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
                          size: 16,
                          color: Colors.amber[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          article.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              // Tags
              if (article.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: article.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.paleBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              // Action buttons
              if (showActions) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: onLike,
                            icon: Icon(
                              Icons.favorite_border,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            article.likes.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onShare,
                      icon: Icon(
                        Icons.share,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    IconButton(
                      onPressed: onBookmark,
                      icon: Icon(
                        article.isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        size: 20,
                        color: article.isBookmarked
                            ? AppColors.accent
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
