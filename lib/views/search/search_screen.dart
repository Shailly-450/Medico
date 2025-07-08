import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/views/base_view.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/search_view_model.dart';
import '../../models/doctor.dart';
import '../home/widgets/doctor_card.dart';
import '../doctors/doctor_detail_screen.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/filter_chip_widget.dart';
import 'dart:ui'; // Added for ImageFilter

const Color kOrangeAccent = Color(0xFFFF9800);

// Add icon/color maps at the top:
const Map<String, IconData> recentSearchIcons = {
  'Cardiologist': Icons.favorite,
  'Dental': Icons.medical_services,
  'MRI': Icons.scanner,
  'Pediatrician': Icons.child_care,
  'Dermatologist': Icons.spa,
};
const Map<String, Color> recentSearchColors = {
  'Cardiologist': Colors.red,
  'Dental': Colors.blue,
  'MRI': Colors.deepPurple,
  'Pediatrician': Colors.teal,
  'Dermatologist': Colors.purple,
};
const Map<SearchFilter, IconData> filterIcons = {
  SearchFilter.all: Icons.list_alt,
  SearchFilter.nearby: Icons.location_on,
  SearchFilter.topRated: Icons.star,
  SearchFilter.lowestPrice: Icons.local_offer,
};
const Map<SearchFilter, Color> filterIconColors = {
  SearchFilter.all: Color(0xFF2E7D32),
  SearchFilter.nearby: Colors.blue,
  SearchFilter.topRated: kOrangeAccent,
  SearchFilter.lowestPrice: Colors.teal,
};

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startListeningAnimations() {
    _pulseController.repeat(reverse: true);
    _waveController.repeat();
    _fadeController.forward();
  }

  void _stopListeningAnimations() {
    _pulseController.stop();
    _waveController.stop();
    _fadeController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<SearchViewModel>(
      viewModelBuilder: () => SearchViewModel(),
      onModelReady: (model) {
        model.init();
        model.initVoice();
      },
      builder: (context, model, child) {
        // Start/stop animations based on listening state
        if (model.isListening) {
          _startListeningAnimations();
        } else {
          _stopListeningAnimations();
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(90),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.65),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E8).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Color(0xFF2E7D32)),
                              onPressed: () => Navigator.of(context).pop(),
                              tooltip: 'Back',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: SearchBarWidget(
                                controller: model.searchController,
                                hintText: 'Search doctors, specialties, hospitals, symptoms...',
                                autofocus: true,
                                onChanged: model.onSearchChanged,
                                onSubmitted: model.onSearchSubmitted,
                                onClear: () => model.onSearchChanged(''),
                                isListening: model.isListening,
                                onVoiceTap: () async {
                                  HapticFeedback.lightImpact();
                                  if (model.isListening) {
                                    await model.stopListening();
                                  } else {
                                    await model.startListening();
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
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
            child: Stack(
              children: [
                // Main content
                model.busy
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          const SizedBox(height: 90), // Add spacing below app bar
                          // Search suggestions when typing
                          if (model.isSearching &&
                              model.searchController.text.trim().isNotEmpty) ...[
                            _buildSearchSuggestions(model),
                            const SizedBox(height: 16),
                          ],

                          // Recent searches (only when not searching)
                          if (!model.isSearching &&
                              model.recentSearches.isNotEmpty) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                                    blurRadius: 40,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.history, color: Colors.blueAccent, size: 20),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Recent Searches',
                                            style: TextStyle(
                                              color: AppColors.textBlack,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(20),
                                          onTap: () {
                                            HapticFeedback.lightImpact();
                                            model.clearRecentSearches();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE8F5E8).withOpacity(0.8),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(0xFF4CAF50).withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              'Clear All',
                                              style: TextStyle(
                                                color: const Color(0xFF2E7D32),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: model.recentSearches
                                        .map((search) => Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius: BorderRadius.circular(16),
                                                onTap: () {
                                                  HapticFeedback.lightImpact();
                                                  model.searchController.text = search;
                                                  model.onSearchSubmitted(search);
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 10,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFE8F5E8).withOpacity(0.6),
                                                    borderRadius: BorderRadius.circular(16),
                                                    border: Border.all(
                                                      color: const Color(0xFF4CAF50).withOpacity(0.3),
                                                      width: 1,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.04),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        search,
                                                        style: TextStyle(
                                                          color: const Color(0xFF2E7D32),
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      GestureDetector(
                                                        onTap: () {
                                                          HapticFeedback.lightImpact();
                                                          if (model != null) {
                                                            model.removeFromRecentSearches(search);
                                                          }
                                                        },
                                                        child: Icon(
                                                          Icons.close,
                                                          size: 16,
                                                          color: const Color(0xFF2E7D32),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Filters (always show)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                                BoxShadow(
                                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                                  blurRadius: 40,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.filter_list, color: Colors.teal, size: 20),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Filters',
                                          style: TextStyle(
                                            color: AppColors.textBlack,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Debug button for testing
                                    if (model.isSearching)
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(20),
                                          onTap: () {
                                            HapticFeedback.lightImpact();
                                            model.testSymptomSearch(
                                                model.searchController.text);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE8F5E8).withOpacity(0.8),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(0xFF4CAF50).withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              'Debug Search',
                                              style: TextStyle(
                                                color: const Color(0xFF2E7D32),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                          SizedBox(
                            height: 40,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: SearchFilter.values.length,
                              itemBuilder: (context, index) {
                                final filter = SearchFilter.values[index];
                                final isSelected = model.selectedFilter == filter;
                                return Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        model.setFilter(filter);
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected 
                                              ? kOrangeAccent
                                              : const Color(0xFFE8F5E8).withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: isSelected 
                                                ? kOrangeAccent
                                                : const Color(0xFF4CAF50).withOpacity(0.3),
                                            width: 1.5,
                                          ),
                                          boxShadow: isSelected ? [
                                            BoxShadow(
                                              color: const Color(0xFF4CAF50).withOpacity(0.4),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ] : [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.04),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          model.getFilterDisplayName(filter),
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : const Color(0xFF2E7D32),
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                          // Results section
                          if (model.isSearching ||
                              model.filteredDoctors.isNotEmpty) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                                    blurRadius: 40,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.medical_services, color: Colors.green, size: 20),
                                          const SizedBox(width: 12),
                                          Text(
                                            model.isSearching
                                                ? 'Search Results'
                                                : 'All Doctors',
                                            style: TextStyle(
                                              color: AppColors.textBlack,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: kOrangeAccent,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          '${model.filteredDoctors.length} results',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                            if (model.isSearching && model.filteredDoctors.isEmpty)
                              _buildNoResultsWidget(
                                  model.searchController.text.trim())
                            else if (model.filteredDoctors.isNotEmpty)
                              ...model.filteredDoctors.map((doctor) => Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DoctorDetailScreen(doctor: doctor),
                                            ),
                                          );
                                        },
                                        child: DoctorCard(doctor: doctor),
                                      ),
                                    ),
                                  )),
                        ],
                      ),
                    ),
                                            ] else ...[
                            // Popular searches when no search is active
                            Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                                    blurRadius: 40,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.trending_up, color: kOrangeAccent, size: 20),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Popular Searches',
                                        style: TextStyle(
                                          color: AppColors.textBlack,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildPopularSearches(model),
                                ],
                              ),
                            ),
                          ],

                          // Bottom spacing
                          const SizedBox(height: 32),
                        ],
                      ),

                // Voice listening overlay
                if (model.isListening) _buildVoiceListeningOverlay(model),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVoiceListeningOverlay(SearchViewModel model) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated microphone icon
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),

              // Animated waves
              SizedBox(
                width: 200,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: List.generate(3, (index) {
                    return AnimatedBuilder(
                      animation: _waveAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_waveAnimation.value * 0.3) * (index + 1),
                          child: Container(
                            width: 60 + (index * 20),
                            height: 60 + (index * 20),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.primary.withOpacity(
                                  0.3 - (index * 0.1),
                                ),
                                width: 2,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
              const SizedBox(height: 40),

              // Listening text
              Text(
                'Listening...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Speak clearly to search',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 40),

              // Stop button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () async {
                    HapticFeedback.heavyImpact();
                    await model.stopListening();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.stop,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Stop Listening',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions(SearchViewModel model) {
    final suggestions = model.getSearchSuggestions(model.searchController.text);

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Suggestions',
                  style: TextStyle(
                    color: AppColors.textBlack,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          ...suggestions.map((suggestion) => Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    model.searchController.text = suggestion;
                    model.onSearchSubmitted(suggestion);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E8).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.search,
                            color: const Color(0xFF2E7D32),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: TextStyle(
                              color: AppColors.textBlack,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNoResultsWidget(String searchQuery) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
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
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.search_off,
              size: 48,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No results found for "$searchQuery"',
            style: TextStyle(
              color: AppColors.textBlack,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term or browse all doctors',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSearches(SearchViewModel? model) {
    final popularSearches = [
      'Cardiologist',
      'Dentist',
      'Pediatrician',
      'Dermatologist',
      'Neurologist',
      'Psychiatrist',
      'headache',
      'chest pain',
      'rash',
      'anxiety',
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: popularSearches
          .map((search) => Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (model != null) {
                      model.searchController.text = search;
                      model.onSearchSubmitted(search);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E8).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          recentSearchIcons[search] ?? Icons.search,
                          color: recentSearchColors[search] ?? Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          search,
                          style: TextStyle(
                            color: const Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            if (model != null) {
                              model.removeFromRecentSearches(search);
                            }
                          },
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}
