import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/blog.dart';

class BlogViewModel extends BaseViewModel {
  List<Blog> _blogs = [];
  List<Blog> _filteredBlogs = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;

  List<Blog> get blogs => _blogs;
  List<Blog> get filteredBlogs => _filteredBlogs;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  List<String> get categories => [
    'All',
    'Health Tips',
    'Medical News',
    'Wellness',
    'Nutrition',
    'Fitness',
    'Mental Health',
    'Disease Prevention',
  ];

  @override
  void init() {
    super.init();
    _loadBlogs();
  }

  Future<void> _loadBlogs() async {
    setBusy(true);
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    _blogs = _getMockBlogs();
    _filteredBlogs = _blogs;
    
    setBusy(false);
    _isLoading = false;
    notifyListeners();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void searchBlogs(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredBlogs = _blogs.where((blog) {
      bool categoryMatch = _selectedCategory == 'All' || blog.category == _selectedCategory;
      bool searchMatch = _searchQuery.isEmpty || 
          blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          blog.excerpt.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          blog.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      
      return categoryMatch && searchMatch;
    }).toList();
    
    notifyListeners();
  }

  void toggleBookmark(String blogId) {
    final index = _blogs.indexWhere((blog) => blog.id == blogId);
    if (index != -1) {
      _blogs[index] = _blogs[index].copyWith(isBookmarked: !_blogs[index].isBookmarked);
      _applyFilters();
    }
  }

  void incrementLikes(String blogId) {
    final index = _blogs.indexWhere((blog) => blog.id == blogId);
    if (index != -1) {
      _blogs[index] = _blogs[index].copyWith(likes: _blogs[index].likes + 1);
      _applyFilters();
    }
  }

  List<Blog> get featuredBlogs => _blogs.where((blog) => blog.isFeatured).toList();

  List<Blog> _getMockBlogs() {
    return [
      Blog(
        id: '1',
        title: '10 Essential Health Tips for a Better Life',
        content: 'Living a healthy lifestyle is crucial for maintaining good physical and mental well-being. Here are 10 essential tips that can help you improve your overall health...',
        excerpt: 'Discover the most important health tips that can transform your daily routine and improve your overall well-being.',
        author: 'Dr. Sarah Johnson',
        authorAvatar: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=150&h=150&fit=crop&crop=face',
        publishedDate: DateTime.now().subtract(const Duration(days: 2)),
        imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=250&fit=crop',
        tags: ['Health Tips', 'Wellness', 'Lifestyle'],
        category: 'Health Tips',
        readTime: 8,
        views: 1247,
        likes: 89,
        isFeatured: true,
      ),
      Blog(
        id: '2',
        title: 'Understanding Mental Health: A Complete Guide',
        content: 'Mental health is just as important as physical health. This comprehensive guide covers everything you need to know about maintaining good mental health...',
        excerpt: 'Learn about the importance of mental health and practical ways to maintain emotional well-being in today\'s fast-paced world.',
        author: 'Dr. Michael Chen',
        authorAvatar: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=150&h=150&fit=crop&crop=face',
        publishedDate: DateTime.now().subtract(const Duration(days: 5)),
        imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=250&fit=crop',
        tags: ['Mental Health', 'Psychology', 'Wellness'],
        category: 'Mental Health',
        readTime: 12,
        views: 2156,
        likes: 156,
        isFeatured: true,
      ),
      Blog(
        id: '3',
        title: 'The Power of Nutrition: Foods That Boost Immunity',
        content: 'Your immune system is your body\'s defense mechanism. Learn about the foods that can strengthen your immunity and help you stay healthy...',
        excerpt: 'Discover the best foods to boost your immune system and protect yourself from common illnesses.',
        author: 'Dr. Emily Rodriguez',
        authorAvatar: 'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=150&h=150&fit=crop&crop=face',
        publishedDate: DateTime.now().subtract(const Duration(days: 1)),
        imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400&h=250&fit=crop',
        tags: ['Nutrition', 'Immunity', 'Health'],
        category: 'Nutrition',
        readTime: 6,
        views: 892,
        likes: 67,
      ),
      Blog(
        id: '4',
        title: 'Exercise and Fitness: Building a Sustainable Routine',
        content: 'Creating a sustainable fitness routine is key to long-term health. This guide will help you build an exercise plan that fits your lifestyle...',
        excerpt: 'Learn how to create a sustainable fitness routine that will help you achieve your health goals.',
        author: 'Dr. James Wilson',
        authorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
        publishedDate: DateTime.now().subtract(const Duration(days: 3)),
        imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=250&fit=crop',
        tags: ['Fitness', 'Exercise', 'Health'],
        category: 'Fitness',
        readTime: 10,
        views: 1567,
        likes: 123,
      ),
      Blog(
        id: '5',
        title: 'Preventing Chronic Diseases: Early Detection Strategies',
        content: 'Early detection is crucial for preventing and managing chronic diseases. Learn about the screening tests and lifestyle changes that can make a difference...',
        excerpt: 'Discover the importance of early detection and prevention strategies for chronic diseases.',
        author: 'Dr. Lisa Thompson',
        authorAvatar: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=150&h=150&fit=crop&crop=face',
        publishedDate: DateTime.now().subtract(const Duration(days: 7)),
        imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=250&fit=crop',
        tags: ['Disease Prevention', 'Health', 'Medical'],
        category: 'Disease Prevention',
        readTime: 15,
        views: 3421,
        likes: 234,
        isFeatured: true,
      ),
      Blog(
        id: '6',
        title: 'Sleep Hygiene: The Foundation of Good Health',
        content: 'Quality sleep is essential for physical and mental health. Learn about sleep hygiene practices that can improve your sleep quality...',
        excerpt: 'Understand the importance of good sleep hygiene and how it impacts your overall health.',
        author: 'Dr. Robert Kim',
        authorAvatar: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=150&h=150&fit=crop&crop=face',
        publishedDate: DateTime.now().subtract(const Duration(days: 4)),
        imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400&h=250&fit=crop',
        tags: ['Sleep', 'Health', 'Wellness'],
        category: 'Wellness',
        readTime: 7,
        views: 987,
        likes: 78,
      ),
    ];
  }
} 