import 'package:flutter/material.dart';
import '../../models/video_content.dart';
import '../../models/article_content.dart';
import '../../core/theme/app_colors.dart';
import '../shared/widgets/video_card.dart';
import '../shared/widgets/article_card.dart';
import '../shared/widgets/content_list_widget.dart';

class ContentDemoScreen extends StatefulWidget {
  const ContentDemoScreen({Key? key}) : super(key: key);

  @override
  State<ContentDemoScreen> createState() => _ContentDemoScreenState();
}

class _ContentDemoScreenState extends State<ContentDemoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  // Sample video data
  final List<VideoContent> _sampleVideos = [
    VideoContent(
      id: '1',
      title: 'Understanding Diabetes: A Comprehensive Guide',
      description:
          'Learn about the different types of diabetes, symptoms, and management strategies from leading endocrinologists.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=200&fit=crop',
      videoUrl: 'https://example.com/video1.mp4',
      duration: '12:34',
      author: 'Dr. Sarah Johnson',
      authorAvatarUrl:
          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=100&h=100&fit=crop&crop=face',
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      views: 15420,
      likes: 892,
      tags: ['Diabetes', 'Endocrinology', 'Health'],
      category: 'Endocrinology',
      isPremium: false,
      rating: 4.8,
    ),
    VideoContent(
      id: '2',
      title: 'Cardiovascular Health: Exercise and Nutrition Tips',
      description:
          'Expert advice on maintaining heart health through proper exercise routines and balanced nutrition.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=200&fit=crop',
      videoUrl: 'https://example.com/video2.mp4',
      duration: '18:45',
      author: 'Dr. Michael Chen',
      authorAvatarUrl:
          'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=100&h=100&fit=crop&crop=face',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      views: 8920,
      likes: 456,
      tags: ['Cardiology', 'Exercise', 'Nutrition'],
      category: 'Cardiology',
      isPremium: true,
      rating: 4.9,
    ),
    VideoContent(
      id: '3',
      title: 'Mental Health Awareness: Breaking the Stigma',
      description:
          'An important discussion about mental health, common disorders, and how to seek help.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=200&fit=crop',
      videoUrl: 'https://example.com/video3.mp4',
      duration: '25:12',
      author: 'Dr. Emily Rodriguez',
      authorAvatarUrl:
          'https://images.unsplash.com/photo-1594824475545-9d0c7c495052?w=100&h=100&fit=crop&crop=face',
      publishedAt: DateTime.now().subtract(const Duration(days: 3)),
      views: 23450,
      likes: 1234,
      tags: ['Mental Health', 'Psychology', 'Awareness'],
      category: 'Psychiatry',
      isPremium: false,
      rating: 4.7,
    ),
  ];

  // Sample article data
  final List<ArticleContent> _sampleArticles = [
    ArticleContent(
      id: '1',
      title:
          'The Future of Telemedicine: How Technology is Transforming Healthcare',
      summary:
          'Explore how telemedicine is revolutionizing patient care and making healthcare more accessible than ever before.',
      content: 'Full article content would go here...',
      imageUrl:
          'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=400&h=200&fit=crop',
      author: 'Dr. James Wilson',
      authorAvatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
      readTime: 8,
      views: 5670,
      likes: 234,
      tags: ['Telemedicine', 'Technology', 'Healthcare'],
      category: 'Technology',
      isPremium: false,
      rating: 4.6,
      isBookmarked: false,
    ),
    ArticleContent(
      id: '2',
      title: 'Nutrition Myths Debunked: What Science Really Says',
      summary:
          'Separate fact from fiction with evidence-based information about common nutrition misconceptions.',
      content: 'Full article content would go here...',
      imageUrl:
          'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400&h=200&fit=crop',
      author: 'Dr. Lisa Park',
      authorAvatarUrl:
          'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=100&h=100&fit=crop&crop=face',
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      readTime: 12,
      views: 12340,
      likes: 567,
      tags: ['Nutrition', 'Science', 'Health'],
      category: 'Nutrition',
      isPremium: true,
      rating: 4.8,
      isBookmarked: true,
    ),
    ArticleContent(
      id: '3',
      title: 'Sleep Hygiene: The Foundation of Good Health',
      summary:
          'Learn about the importance of quality sleep and practical tips for improving your sleep hygiene.',
      content: 'Full article content would go here...',
      imageUrl:
          'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?w=400&h=200&fit=crop',
      author: 'Dr. Robert Thompson',
      authorAvatarUrl:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
      publishedAt: DateTime.now().subtract(const Duration(days: 5)),
      readTime: 6,
      views: 8900,
      likes: 345,
      tags: ['Sleep', 'Wellness', 'Health'],
      category: 'Wellness',
      isPremium: false,
      rating: 4.5,
      isBookmarked: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Health Content',
          style: TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Videos'),
            Tab(text: 'Articles'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Content Tab
          _buildAllContentTab(),
          // Videos Tab
          _buildVideosTab(),
          // Articles Tab
          _buildArticlesTab(),
        ],
      ),
    );
  }

  Widget _buildAllContentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ContentListWidget(
        videos: _sampleVideos,
        articles: _sampleArticles,
        contentType: ContentType.mixed,
        title: 'Featured Content',
        onVideoTap: (video) => _showVideoDetail(video),
        onArticleTap: (article) => _showArticleDetail(article),
        onVideoPlay: (video) => _playVideo(video),
        onVideoLike: (video) => _likeVideo(video),
        onVideoShare: (video) => _shareVideo(video),
        onArticleLike: (article) => _likeArticle(article),
        onArticleShare: (article) => _shareArticle(article),
        onArticleBookmark: (article) => _bookmarkArticle(article),
      ),
    );
  }

  Widget _buildVideosTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sampleVideos.length,
      itemBuilder: (context, index) {
        return VideoCard(
          video: _sampleVideos[index],
          onTap: () => _showVideoDetail(_sampleVideos[index]),
          onPlay: () => _playVideo(_sampleVideos[index]),
          onLike: () => _likeVideo(_sampleVideos[index]),
          onShare: () => _shareVideo(_sampleVideos[index]),
        );
      },
    );
  }

  Widget _buildArticlesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sampleArticles.length,
      itemBuilder: (context, index) {
        return ArticleCard(
          article: _sampleArticles[index],
          onTap: () => _showArticleDetail(_sampleArticles[index]),
          onLike: () => _likeArticle(_sampleArticles[index]),
          onShare: () => _shareArticle(_sampleArticles[index]),
          onBookmark: () => _bookmarkArticle(_sampleArticles[index]),
        );
      },
    );
  }

  void _showVideoDetail(VideoContent video) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening video: ${video.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showArticleDetail(ArticleContent article) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening article: ${article.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _playVideo(VideoContent video) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing video: ${video.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _likeVideo(VideoContent video) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Liked video: ${video.title}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _shareVideo(VideoContent video) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing video: ${video.title}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _likeArticle(ArticleContent article) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Liked article: ${article.title}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _shareArticle(ArticleContent article) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing article: ${article.title}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _bookmarkArticle(ArticleContent article) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bookmarked article: ${article.title}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
