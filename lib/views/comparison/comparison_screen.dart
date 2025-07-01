import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/comparison_view_model.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/provider_comparison_card.dart';
import 'widgets/service_category_selector.dart';
import 'widgets/provider_selection_dialog.dart';
import 'widgets/sort_options_dialog.dart';
import 'widgets/service_selector.dart';
import 'widgets/comparison_table.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({Key? key}) : super(key: key);

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  late String selectedService;

  final List<String> services = [
    'MRI Scan',
    'CT Scan',
    'X-Ray',
    'Ultrasound',
    'Root Canal Treatment',
    'Dental Implants',
    'Braces / Invisalign',
    'Wisdom Tooth Extraction',
    'LASIK Surgery',
    'Cataract Surgery',
    'Eye Checkup (Vision Test)',
    'Glaucoma Screening',
    'Physiotherapy Sessions',
    'Knee Replacement Surgery',
    'Fracture Treatment',
    'Spine Consultation',
    'Gynecology Consultation',
    'Hair Transplant',
    'Skin Laser Treatments',
    'Cosmetic Surgery',
    'Online Doctor Consultation',
    'Gallbladder Removal',
    'Appendix Surgery',
  ];

  final List<String> allFilters = [
    'Nearest',
    'Low Cost',
    'Top Rated',
    'Insurance',
    'Available Today',
    'Open Now',
    'Weekend',
  ];
  Set<String> selectedFilters = {};

  @override
  void initState() {
    super.initState();
    selectedService = services.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paleBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Service Comparison',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            children: [
              Expanded(
                child: ServiceSelector(
                  services: services,
                  selectedService: selectedService,
                  onServiceChanged: (val) {
                    setState(() {
                      selectedService = val;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: allFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final filter = allFilters[i];
                return FilterChip(
                  label: Text(filter),
                  selected: selectedFilters.contains(filter),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedFilters.add(filter);
                      } else {
                        selectedFilters.remove(filter);
                      }
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          ComparisonTable(
            sortByCost: selectedFilters.contains('Low Cost'),
            selectedService: selectedService,
            selectedFilters: selectedFilters,
          ),
        ],
      ),
    );
  }
}

class _ComparisonScreenBody extends StatefulWidget {
  const _ComparisonScreenBody({Key? key}) : super(key: key);

  @override
  State<_ComparisonScreenBody> createState() => _ComparisonScreenBodyState();
}

class _ComparisonScreenBodyState extends State<_ComparisonScreenBody> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paleBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Service Comparison',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer<ComparisonViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.selectedProviders.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: () => _showSortOptions(context, viewModel),
                  tooltip: 'Sort Options',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<ComparisonViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              // Service Category Selector
              ServiceCategorySelector(
                categories: viewModel.availableCategories,
                selectedCategory: viewModel.selectedServiceCategory,
                onCategoryChanged: viewModel.setServiceCategory,
              ),
              
              // Provider Selection Section
              _buildProviderSelectionSection(viewModel),
              
              // Comparison Content
              Expanded(
                child: _buildComparisonContent(viewModel),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProviderSelectionSection(ComparisonViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Providers (${viewModel.selectedProviders.length}/3)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              if (viewModel.selectedProviders.isNotEmpty)
                TextButton.icon(
                  onPressed: viewModel.clearSelection,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Selected Providers Display
          if (viewModel.selectedProviders.isEmpty)
            _buildEmptySelectionState()
          else
            _buildSelectedProvidersList(viewModel),
          
          const SizedBox(height: 12),
          
          // Add Provider Button
          if (viewModel.selectedProviders.length < 3)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showProviderSelectionDialog(context, viewModel),
                icon: const Icon(Icons.add),
                label: const Text('Add Provider'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptySelectionState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.compare_arrows,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'Select up to 3 providers to compare',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textBlack,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose hospitals or clinics to compare their services side by side',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedProvidersList(ComparisonViewModel viewModel) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: viewModel.selectedProviders.map((provider) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (provider.imageUrl != null)
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(provider.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Flexible(
                child: Text(
                  provider.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textBlack,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => viewModel.removeProvider(provider),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.textBlack,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildComparisonContent(ComparisonViewModel viewModel) {
    if (viewModel.selectedProviders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No providers selected',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add providers to start comparing services',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Provider Comparison Cards
          ...viewModel.selectedProviders.map((provider) {
            final services = viewModel.getServicesForProviderAndCategory(
              provider,
              viewModel.selectedServiceCategory,
            );
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ProviderComparisonCard(
                provider: provider,
                services: services,
                selectedCategory: viewModel.selectedServiceCategory,
              ),
            );
          }).toList(),
          
          // Summary Section
          if (viewModel.selectedProviders.length > 1)
            _buildComparisonSummary(viewModel),
        ],
      ),
    );
  }

  Widget _buildComparisonSummary(ComparisonViewModel viewModel) {
    final services = viewModel.getServicesForCategory(viewModel.selectedServiceCategory);
    final minPrice = services.isNotEmpty ? services.map((s) => s.price).reduce((a, b) => a < b ? a : b) : 0.0;
    final maxPrice = services.isNotEmpty ? services.map((s) => s.price).reduce((a, b) => a > b ? a : b) : 0.0;
    final avgPrice = services.isNotEmpty ? services.map((s) => s.price).reduce((a, b) => a + b) / services.length : 0.0;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Lowest',
                  '\$${minPrice.toStringAsFixed(0)}',
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Average',
                  '\$${avgPrice.toStringAsFixed(0)}',
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Highest',
                  '\$${maxPrice.toStringAsFixed(0)}',
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  void _showProviderSelectionDialog(BuildContext context, ComparisonViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => ProviderSelectionDialog(
        providers: viewModel.providers,
        selectedProviders: viewModel.selectedProviders,
        onProviderSelected: viewModel.selectProvider,
      ),
    );
  }

  void _showSortOptions(BuildContext context, ComparisonViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => SortOptionsDialog(
        onSortByPrice: (ascending) => viewModel.sortProvidersByPrice(ascending: ascending),
        onSortByRating: (ascending) => viewModel.sortProvidersByRating(ascending: ascending),
        onSortByDistance: (ascending) => viewModel.sortProvidersByDistance(ascending: ascending),
      ),
    );
  }
} 