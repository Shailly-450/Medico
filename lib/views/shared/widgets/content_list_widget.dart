import 'package:flutter/material.dart';
import '../../../models/video_content.dart';
import '../../../models/article_content.dart';
import '../../../core/theme/app_colors.dart';
import 'video_card.dart';
import 'article_card.dart';

enum ContentType { video, article, mixed }

class ContentListWidget extends StatefulWidget {
  final List<VideoContent> videos;
  final List<ArticleContent> articles;
  final ContentType contentType;
  final String? title;
  final bool showFilterChips;
  final Function(VideoContent)? onVideoTap;
  final Function(ArticleContent)? onArticleTap;
  final Function(VideoContent)? onVideoPlay;
  final Function(VideoContent)? onVideoLike;
  final Function(VideoContent)? onVideoShare;
  final Function(ArticleContent)? onArticleLike;
  final Function(ArticleContent)? onArticleShare;
  final Function(ArticleContent)? onArticleBookmark;

  const ContentListWidget({
    Key? key,
    this.videos = const [],
    this.articles = const [],
    this.contentType = ContentType.mixed,
    this.title,
    this.showFilterChips = true,
    this.onVideoTap,
    this.onArticleTap,
    this.onVideoPlay,
    this.onVideoLike,
    this.onVideoShare,
    this.onArticleLike,
    this.onArticleShare,
    this.onArticleBookmark,
  }) : super(key: key);

  @override
  State<ContentListWidget> createState() => _ContentListWidgetState();
}

class _ContentListWidgetState extends State<ContentListWidget> {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Videos', 'Articles'];

  List<dynamic> get _filteredContent {
    switch (_selectedFilter) {
      case 'Videos':
        return widget.videos;
      case 'Articles':
        return widget.articles;
      default:
        return [...widget.videos, ...widget.articles];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and filter chips
        if (widget.title != null || widget.showFilterChips) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (widget.title != null) ...[
                  Text(
                    widget.title!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const Spacer(),
                ],
                if (widget.showFilterChips &&
                    widget.contentType == ContentType.mixed)
                  ..._filterOptions.map((filter) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: FilterChip(
                          label: filter,
                          selected: _selectedFilter == filter,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                        ),
                      )),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        // Content list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredContent.length,
          itemBuilder: (context, index) {
            final content = _filteredContent[index];

            if (content is VideoContent) {
              return VideoCard(
                video: content,
                onTap: () => widget.onVideoTap?.call(content),
                onPlay: () => widget.onVideoPlay?.call(content),
                onLike: () => widget.onVideoLike?.call(content),
                onShare: () => widget.onVideoShare?.call(content),
              );
            } else if (content is ArticleContent) {
              return ArticleCard(
                article: content,
                onTap: () => widget.onArticleTap?.call(content),
                onLike: () => widget.onArticleLike?.call(content),
                onShare: () => widget.onArticleShare?.call(content),
                onBookmark: () => widget.onArticleBookmark?.call(content),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const FilterChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(!selected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withOpacity(0.2)
              : AppColors.paleBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.accent : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.accent : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
