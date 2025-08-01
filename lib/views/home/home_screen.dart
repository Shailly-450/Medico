import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/views/base_view.dart';
import '../../viewmodels/home_view_model.dart';
import '../../core/theme/app_colors.dart';
import '../blogs/widgets/blog_card.dart';
import 'widgets/appointment_card.dart';
import 'widgets/doctor_card.dart';
import 'widgets/offer_card.dart';
import 'widgets/hospital_card.dart';
import '../notifications/notification_screen.dart';
import 'offers_screen.dart';
import 'hospitals_screen.dart';
import 'hospital_detail_screen.dart';
import 'hospital_map_screen.dart';
import '../doctors/doctors_screen.dart';
import '../doctors/doctor_detail_screen.dart';
import 'find_hospitals_screen.dart';
import '../appointments/all_appointments_screen.dart';
import '../blogs/blogs_screen.dart';
import '../../models/video_content.dart';
import '../../models/article_content.dart';
import '../video/video_player_screen.dart';
import '../../core/config.dart';
import '../../models/doctor.dart';
import '../../viewmodels/doctors_view_model.dart';
import '../../viewmodels/profile_view_model.dart';
import '../../viewmodels/blog_view_model.dart';
import '../blogs/blog_detail_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Sample video data
  final List<VideoContent> _sampleVideos = [
    VideoContent(
      id: '1',
      title: 'Understanding Diabetes: A Comprehensive Guide',
      description:
          'Learn about the different types of diabetes, symptoms, and management strategies from leading endocrinologists.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=200&fit=crop',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
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
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
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
  ];

  // Sample article data
  // final List<ArticleContent> _sampleArticles = [ ... ]; // Commented out, now using API blogs

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('HomeScreen build called');
    return BaseView<HomeViewModel>(
      viewModelBuilder: () => HomeViewModel(),
      onModelReady: (model) {
        print('HomeViewModel onModelReady called');
        model.init();
      },
      builder: (context, homeModel, child) {
        print('HomeScreen offers length: ${homeModel.offers.length}');
        if (homeModel.offers.isNotEmpty) {
          for (var offer in homeModel.offers) {
            print('Offer: title=${offer.title}, id=${offer.id}, isActive=${offer.isActive}, validUntil=${offer.validUntil}');
          }
        }
        print('API Base URL: ${AppConfig.apiBaseUrl}');
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE8F5E8), // Light mint green
                  Color(0xFFF0F8F0), // Very light sage
                  Color(0xFFE6F3E6), // Soft green tint
                  Color(0xFFF5F9F5), // Almost white with green tint
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // App Bar with Profile
                      SliverToBoxAdapter(
                        child: _buildAppBar(context, homeModel),
                      ),

                      // Search Section
                      SliverToBoxAdapter(
                        child: _buildSearchSection(context),
                      ),

                      // Quick Actions
                      SliverToBoxAdapter(
                        child: _buildQuickActions(context, homeModel),
                      ),

                      // Categories Grid
                      SliverToBoxAdapter(
                        child: _buildCategoriesSection(context, homeModel),
                      ),

                      // Upcoming Appointments
                      if (homeModel.upcomingAppointments.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _buildAppointmentsSection(context, homeModel),
                        ),

                      // Offers Section (always visible, even if empty)
                      SliverToBoxAdapter(
                        child: _buildOffersSection(context, homeModel),
                      ),

                      // Doctors Section
                      SliverToBoxAdapter(
                        child: _buildDoctorsSection(context, homeModel),
                      ),

                      // Hospitals Section
                      SliverToBoxAdapter(
                        child: _buildHospitalsSection(context, homeModel),
                      ),

                      // Health Content Section
                      SliverToBoxAdapter(
                        child: _buildHealthContentSection(context),
                      ),

                      // Blog Section
                      // SliverToBoxAdapter(
                      //   child: Consumer<BlogViewModel>(
                      //     builder: (context, blogModel, _) {
                      //       if (!blogModel.isLoading && blogModel.blogs.isEmpty) {
                      //         blogModel.fetchAllBlogs();
                      //       }
                      //       if (blogModel.isLoading) {
                      //         return const Center(child: CircularProgressIndicator());
                      //       }
                      //       if (blogModel.blogs.isEmpty) {
                      //         return const Center(child: Text('No blogs found.'));
                      //       }
                      //       return Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Padding(
                      //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      //             child: Text(
                      //               'Latest Blogs',
                      //               style: TextStyle(
                      //                 fontSize: 20,
                      //                 fontWeight: FontWeight.bold,
                      //                 color: Colors.black87,
                      //               ),
                      //             ),
                      //           ),
                      //           ListView.builder(
                      //             shrinkWrap: true,
                      //             physics: const NeverScrollableScrollPhysics(),
                      //             itemCount: blogModel.blogs.length,
                      //             itemBuilder: (context, idx) {
                      //               final blog = blogModel.blogs[idx];
                      //               return Card(
                      //                 margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      //                 child: ListTile(
                      //                   leading: blog.imageUrl != null
                      //                       ? Image.network(blog.imageUrl!, width: 60, height: 60, fit: BoxFit.cover)
                      //                       : Container(width: 60, height: 60, color: Colors.grey[200]),
                      //                   title: Text(blog.title),
                      //                   subtitle: Text(blog.excerpt ?? ''),
                      //                   onTap: () {
                      //                     // Navigate to blog detail if needed
                      //                   },
                      //                 ),
                      //               );
                      //             },
                      //           ),
                      //         ],
                      //       );
                      //     },
                      //   ),
                      // ),
                      // // Bottom padding
                      // const SliverToBoxAdapter(
                      //   child: SizedBox(height: 32),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
            // floatingActionButton: _buildFloatingActionButton(context),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2E7D32), // Dark green
                  const Color(0xFF4CAF50), // Material green
                  const Color(0xFF66BB6A), // Light green
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () {
                  Navigator.pushNamed(context, '/schedule');
                },
                child: Container(
                  width: 56,
                  height: 56,
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, HomeViewModel model) {
    final profileVM = Provider.of<ProfileViewModel>(context);
    final address = profileVM.profileData?['profile']?['address'] ?? model.userLocation;
    final userName = profileVM.profileData?['profile']?['name'] ?? model.userName;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Avatar
          Hero(
            tag: 'profile_avatar',
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2E7D32),
                    const Color(0xFF4CAF50),
                    const Color(0xFF66BB6A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    HapticFeedback.lightImpact();
                  },
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          // Welcome, Name, and Address
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Welcome back, ',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      TextSpan(
                        text: userName,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: const Color(0xFF2E7D32),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2E7D32),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Notification
          Row(
            children: [
              // Notification icon, etc.
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const NotificationScreen(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                  opacity: animation, child: child);
                            },
                            transitionDuration:
                                const Duration(milliseconds: 300),
                          ),
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E8).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            width: 1.2,
                          ),
                        ),
                        child: Icon(
                          Icons.notifications_none,
                          color: const Color(0xFF2E7D32),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  if (Provider.of<HomeViewModel>(context).unreadCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53935),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFE53935)
                                        .withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                '${Provider.of<HomeViewModel>(context).unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pushNamed(context, '/search');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Search doctors, hospitals, or symptoms...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E8).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.tune,
                    color: const Color(0xFF2E7D32),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, HomeViewModel model) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  imagePath: 'assets/images/hospital.png',
                  title: 'Find Hospitals',
                  subtitle: 'On Map',
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2E7D32), // Dark green
                      Color(0xFF4CAF50), // Material green
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const FindHospitalsScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  imagePath: 'assets/images/appointment.png',
                  title: 'Book',
                  subtitle: 'Appointment',
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF66BB6A), // Light green
                      Color(0xFF81C784), // Lighter green
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, '/schedule');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String imagePath,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Background Gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: gradient,
                    ),
                  ),
                ),

                // Background Image with overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // Content
                Positioned(
                  bottom: 8,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, HomeViewModel model) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Services',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: model.categories.length,
              itemBuilder: (context, index) {
                final category = model.categories[index];
                final isActive = model.selectedCategory == category['name'];

                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 600 + (index * 100)),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(20 * (1 - value), 0),
                      child: Opacity(
                        opacity: value,
                        child: Container(
                          width: 100,
                          margin: EdgeInsets.only(
                            right: index == model.categories.length - 1 ? 0 : 16,
                          ),
                          child: _buildCategoryCard(
                            context,
                            icon: category['icon'],
                            label: category['name'],
                            isActive: isActive,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              model.setCategory(category['name']);

                              // Handle blogs category specifically
                              if (category['name'] == 'Blogs') {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                        ChangeNotifierProvider(
                                          create: (_) => BlogViewModel(),
                                          child: const BlogsScreen(),
                                        ),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(1.0, 0.0),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      );
                                    },
                                    transitionDuration: const Duration(milliseconds: 400),
                                  ),
                                );
                              } else {
                                Navigator.pushNamed(
                                  context,
                                  '/category',
                                  arguments: category['name'],
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF4CAF50).withOpacity(0.2),
              width: isActive ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? const Color(0xFF4CAF50).withOpacity(0.3)
                    : Colors.black.withOpacity(0.04),
                blurRadius: isActive ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circular Avatar with Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? const LinearGradient(
                            colors: [
                              Color(0xFF2E7D32), // Dark green
                              Color(0xFF4CAF50), // Material green
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isActive
                        ? null
                        : const Color(0xFFE8F5E8).withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: const Color(0xFF4CAF50).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: isActive ? Colors.white : const Color(0xFF2E7D32),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                // Category Name
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? const Color(0xFF2E7D32)
                        : AppColors.textBlack,
                    fontSize: 11,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsSection(BuildContext context, HomeViewModel model) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Appointments',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                  letterSpacing: 0.2,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            AllAppointmentsScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E8).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: const Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: model.upcomingAppointments.length,
              itemBuilder: (context, index) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 600 + (index * 100)),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: Container(
                          width: 320,
                          margin: EdgeInsets.only(
                            right:
                                index == model.upcomingAppointments.length - 1
                                    ? 0
                                    : 20,
                          ),
                          child: AppointmentCard(
                            appointment: model.upcomingAppointments[index],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersSection(BuildContext context, HomeViewModel model) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Special Offers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                  letterSpacing: 0.2,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const OffersScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E8).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: const Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 240,
            child: model.offers.isEmpty
                ? Center(
                    child: Text(
                      'No offers available at the moment.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: model.offers.length,
                    itemBuilder: (context, index) {
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 600 + (index * 100)),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: Container(
                                width: 300,
                                margin: EdgeInsets.only(
                                  right: index == model.offers.length - 1 ? 0 : 20,
                                ),
                                child: OfferCard(
                                  offer: model.offers[index],
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Booking ${model.offers[index].title}...'),
                                        duration: const Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: const Color(0xFF4CAF50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsSection(BuildContext context, HomeViewModel homeModel) {
    return Consumer<DoctorsViewModel>(
      builder: (context, docModel, child) {
        if (docModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final topDoctors = List<Doctor>.from(docModel.filteredDoctors)
          ..sort((a, b) => b.rating.compareTo(a.rating));
        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Doctors',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                      letterSpacing: 0.2,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                const DoctorsScreen(),
                            transitionsBuilder:
                                (context, animation, secondaryAnimation, child) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1.0, 0.0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 400),
                          ),
                        );
                      },
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.blueAccent.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'See All',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Specialties Filter
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: homeModel.specialties.length,
                  itemBuilder: (context, index) {
                    final specialty = homeModel.specialties[index];
                    final isSelected = homeModel.selectedSpecialty == specialty;

                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            if (isSelected) {
                              homeModel.setSpecialty('');
                            } else {
                              homeModel.setSpecialty(specialty);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF4CAF50)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF4CAF50)
                                    : Colors.blueAccent.withOpacity(0.3),
                                width: 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF4CAF50)
                                            .withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              specialty,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.blueAccent,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Doctor Cards
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topDoctors.length,
                itemBuilder: (context, index) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 600 + (index * 100)),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          DoctorDetailScreen(
                                        doctor: topDoctors[index],
                                      ),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        return SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(1.0, 0.0),
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child: child,
                                        );
                                      },
                                      transitionDuration:
                                          const Duration(milliseconds: 400),
                                    ),
                                  );
                                },
                                child: DoctorCard(
                                  doctor: topDoctors[index],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHospitalsSection(BuildContext context, HomeViewModel model) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hospitals & Clinics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                  letterSpacing: 0.2,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const HospitalsScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E8).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: const Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Dropdown-like Filters
          Row(
            children: [
              // Hospital Type Dropdown
              Expanded(
                child: _buildFilterDropdown(
                  context,
                  title: 'Type',
                  selectedValue: model.selectedHospitalType,
                  items: model.hospitalTypes,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    if (value != null) {
                      model.setHospitalType(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Cost Category Dropdown
              Expanded(
                child: _buildFilterDropdown(
                  context,
                  title: 'Cost',
                  selectedValue: model.selectedCostCategory,
                  items: model.costCategories,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    if (value != null) {
                      model.setCostCategory(value);
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Hospital Cards
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: model.filteredHospitals.length,
            itemBuilder: (context, index) {
              final hospital = model.filteredHospitals[index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 600 + (index * 100)),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      HospitalDetailScreen(hospital: hospital),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1.0, 0.0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    );
                                  },
                                  transitionDuration:
                                      const Duration(milliseconds: 400),
                                ),
                              );
                            },
                            child: HospitalCard(
                              hospital: hospital,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        HospitalDetailScreen(
                                            hospital: hospital),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(1.0, 0.0),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      );
                                    },
                                    transitionDuration:
                                        const Duration(milliseconds: 400),
                                  ),
                                );
                              },
                              onMapTap: (selectedHospital) {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        HospitalMapScreen(
                                      selectedHospital: selectedHospital,
                                      hospitals: model.filteredHospitals,
                                    ),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(1.0, 0.0),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      );
                                    },
                                    transitionDuration:
                                        const Duration(milliseconds: 400),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    BuildContext context, {
    required String title,
    required String selectedValue,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
          labelText: title,
          labelStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        style: TextStyle(
          color: AppColors.textBlack,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: const Color(0xFF2E7D32),
          size: 20,
        ),
        dropdownColor: Colors.white,
        isExpanded: true,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyle(
                color: item == selectedValue
                    ? const Color(0xFF2E7D32)
                    : AppColors.textBlack,
                fontWeight:
                    item == selectedValue ? FontWeight.w600 : FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildHealthContentSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withOpacity(0.08),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E8).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.play_circle_outline,
                          color: const Color(0xFF2E7D32),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Health Content',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textBlack,
                              ),
                            ),
                            Text(
                              'Videos and articles from medical experts',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'New',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BlogsScreen()),
                          );
                        },
                        child: const Text('View All'),
                        style: TextButton.styleFrom(
                          foregroundColor: Color(0xFF2E7D32),
                          textStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Blog Content List from API
          Consumer<BlogViewModel>(
            builder: (context, blogModel, _) {
              if (blogModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (blogModel.blogs.isEmpty) {
                return const Center(child: Text('No health content found.'));
              }
              // Show up to two blog cards
              final blogsToShow = blogModel.blogs.take(2).toList();
              return Column(
                children: blogsToShow.map((blog) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: BlogCard(
                    blog: blog,
                    onTap: () {
                      final blogVM = Provider.of<BlogViewModel>(context, listen: false);
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              ChangeNotifierProvider.value(
                                value: blogVM,
                                child: BlogDetailScreen(blog: blog),
                              ),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1.0, 0.0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut,
                              )),
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                    onBookmark: () async => await blogModel.toggleBookmark(blog.id),
                    onLike: () => blogModel.toggleLike(blog.id),
                  ),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showVideoDetail(VideoContent video) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening video: ${video.title}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  void _showArticleDetail(ArticleContent article) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening article: ${article.title}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  void _playVideo(VideoContent video) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            VideoPlayerScreen(video: video),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _likeVideo(VideoContent video) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Liked video: ${video.title}'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  void _shareVideo(VideoContent video) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing video: ${video.title}'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  void _likeArticle(ArticleContent article) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Liked article: ${article.title}'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  void _shareArticle(ArticleContent article) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing article: ${article.title}'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  void _bookmarkArticle(ArticleContent article) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bookmarked article: ${article.title}'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }
}
