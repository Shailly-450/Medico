import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/blog.dart';
import '../core/services/api_service.dart'; // Ensure this import exists

class BlogViewModel extends BaseViewModel {
  List<Blog> _blogs = [];
  List<Blog> _filteredBlogs = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  List<Blog> _bookmarkedBlogs = [];

  List<Blog> get blogs => _blogs;
  List<Blog> get filteredBlogs => _filteredBlogs;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  List<Blog> get bookmarkedBlogs => _bookmarkedBlogs;

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
    // Removed _loadBlogs();
  }

  Future<void> fetchAllBlogs() async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await ApiService.getAllBlogs();
      print('API blogs response: $result');
      if (result['success'] == true && result['data'] != null) {
        final blogsJson = result['data']['blogs'] as List;
        _blogs = blogsJson.map((json) => Blog.fromJson(json)).toList();
        _filteredBlogs = _blogs;
        print('Fetched blogs: ${_blogs.map((b) => b.id).toList()}');
      } else {
        _blogs = [];
        _filteredBlogs = [];
      }
    } catch (e) {
      _blogs = [];
      _filteredBlogs = [];
    }
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

  Future<void> toggleBookmark(String blogId) async {
    final index = _blogs.indexWhere((blog) => blog.id == blogId);
    if (index == -1) return;
    try {
      print('Toggling bookmark for blog: $blogId');
      final result = await ApiService.toggleBlogBookmark(blogId);
      print('API toggleBookmark response: $result');
      if (result['success'] == true && result['data'] != null) {
        final isBookmarked = result['data']['isBookmarked'] == true;
        final oldBlog = _blogs[index];
        _blogs[index] = oldBlog.copyWith(
          isBookmarked: isBookmarked,
        );
        _applyFilters();
      }
    } catch (e) {
      print('Error in toggleBookmark: $e');
    }
    notifyListeners();
  }

  void incrementLikes(String blogId) {
    final index = _blogs.indexWhere((blog) => blog.id == blogId);
    if (index != -1) {
      _blogs[index] = _blogs[index].copyWith(likes: _blogs[index].likes + 1);
      _applyFilters();
    }
  }

  Future<void> toggleLike(String blogId) async {
    final index = _blogs.indexWhere((blog) => blog.id == blogId);
    if (index == -1) return;
    try {
      print('Toggling like for blog: $blogId');
      final result = await ApiService.toggleBlogLike(blogId);
      print('API toggleLike response: $result');
      if (result['success'] == true && result['data'] != null) {
        final isLiked = result['data']['isLiked'] == true;
        final oldBlog = _blogs[index];
        final newLikes = result['data']['likes'] ?? (isLiked ? oldBlog.likes + 1 : (oldBlog.likes > 0 ? oldBlog.likes - 1 : 0));
        _blogs[index] = oldBlog.copyWith(
          likes: newLikes,
          isLiked: isLiked,
        );
        _applyFilters();
      }
    } catch (e) {
      print('Error in toggleLike: $e');
    }
    notifyListeners();
  }

  List<Blog> get featuredBlogs => _blogs.where((blog) => blog.isFeatured).toList();

  Future<void> fetchBookmarkedBlogs() async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await ApiService.getBookmarkedBlogs();
      print('API bookmarked blogs response: $result');
      if (result['success'] == true && result['data'] != null) {
        final blogsJson = result['data']['blogs'] as List;
        _bookmarkedBlogs = blogsJson.map((json) => Blog.fromJson(json)).toList();
      } else {
        _bookmarkedBlogs = [];
      }
    } catch (e) {
      _bookmarkedBlogs = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  // Removed _getMockBlogs and _loadBlogs. Only use fetchAllBlogs for data.
} 