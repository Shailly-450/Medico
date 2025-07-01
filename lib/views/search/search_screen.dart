import 'package:flutter/material.dart';
import '../../core/views/base_view.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/search_view_model.dart';
import '../../models/doctor.dart';
import '../home/widgets/doctor_card.dart';
import '../doctors/doctor_detail_screen.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/filter_chip_widget.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<SearchViewModel>(
      viewModelBuilder: () => SearchViewModel(),
      onModelReady: (model) => model.init(),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: AppColors.paleBackground,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: SearchBarWidget(
              controller: model.searchController,
              hintText: 'Search doctors, specialties, hospitals, symptoms...',
              autofocus: true,
              onChanged: model.onSearchChanged,
              onSubmitted: model.onSearchSubmitted,
              onClear: () => model.onSearchChanged(''),
            ),
          ),
          body: model.busy
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Search suggestions when typing
                    if (model.isSearching &&
                        model.searchController.text.trim().isNotEmpty) ...[
                      _buildSearchSuggestions(model),
                      const SizedBox(height: 16),
                    ],

                    // Recent searches (only when not searching)
                    if (!model.isSearching &&
                        model.recentSearches.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Searches',
                            style: TextStyle(
                              color: AppColors.textBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: model.clearRecentSearches,
                            child: Text(
                              'Clear All',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: model.recentSearches
                            .map((search) => InkWell(
                                  onTap: () {
                                    model.searchController.text = search;
                                    model.onSearchSubmitted(search);
                                  },
                                  child: Chip(
                                    label: Text(search),
                                    backgroundColor: AppColors.secondary,
                                    labelStyle:
                                        TextStyle(color: AppColors.primary),
                                    deleteIcon:
                                        const Icon(Icons.close, size: 16),
                                    onDeleted: () =>
                                        model.removeFromRecentSearches(search),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Filters (always show)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filters',
                          style: TextStyle(
                            color: AppColors.textBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        // Debug button for testing
                        if (model.isSearching)
                          TextButton(
                            onPressed: () {
                              model.testSymptomSearch(
                                  model.searchController.text);
                            },
                            child: Text(
                              'Debug Search',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: SearchFilter.values.length,
                        itemBuilder: (context, index) {
                          final filter = SearchFilter.values[index];
                          final isSelected = model.selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChipWidget(
                              label: model.getFilterDisplayName(filter),
                              isSelected: isSelected,
                              onTap: () => model.setFilter(filter),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Results section
                    if (model.isSearching ||
                        model.filteredDoctors.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            model.isSearching
                                ? 'Search Results'
                                : 'All Doctors',
                            style: TextStyle(
                              color: AppColors.textBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${model.filteredDoctors.length} results',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (model.isSearching && model.filteredDoctors.isEmpty)
                        _buildNoResultsWidget(
                            model.searchController.text.trim())
                      else if (model.filteredDoctors.isNotEmpty)
                        ...model.filteredDoctors.map((doctor) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GestureDetector(
                                onTap: () {
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
                            )),
                    ] else ...[
                      // Popular searches when no search is active
                      Text(
                        'Popular Searches',
                        style: TextStyle(
                          color: AppColors.textBlack,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPopularSearches(model),
                    ],

                    // Bottom spacing
                    const SizedBox(height: 32),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSearchSuggestions(SearchViewModel model) {
    final suggestions = model.getSearchSuggestions(model.searchController.text);

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggestions',
          style: TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ...suggestions.map((suggestion) => ListTile(
              dense: true,
              leading: Icon(Icons.search, color: AppColors.primary, size: 20),
              title: Text(
                suggestion,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 14,
                ),
              ),
              onTap: () {
                model.searchController.text = suggestion;
                model.onSearchSubmitted(suggestion);
              },
            )),
      ],
    );
  }

  Widget _buildNoResultsWidget(String searchQuery) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No results found for "$searchQuery"',
            style: TextStyle(
              color: AppColors.textBlack,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term or browse all doctors',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
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
      spacing: 8,
      runSpacing: 8,
      children: popularSearches
          .map((search) => InkWell(
                onTap: () {
                  if (model != null) {
                    model.searchController.text = search;
                    model.onSearchSubmitted(search);
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Text(
                    search,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}
