import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medical_service.dart';
import '../../viewmodels/comparison_view_model.dart';
import '../../models/service_provider.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/service_selector.dart';
import 'widgets/comparison_table.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({Key? key}) : super(key: key);

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ComparisonViewModel>().initialize();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<ComparisonViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading services...'),
                ],
              ),
            );
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
            children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error Loading Data',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.initialize();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return _buildMainContent(viewModel);
        },
      ),
    );
  }

  Widget _buildMainContent(ComparisonViewModel viewModel) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Category Selection
        _buildCategorySelection(viewModel),
        
        const SizedBox(height: 16),
        
        // Filter Options
        _buildFilterOptions(viewModel),
        
        const SizedBox(height: 16),
        
        // Service Selection
        _buildServiceSelection(viewModel),
        
        const SizedBox(height: 16),
        
        // Service Details
        if (viewModel.selectedServiceDetails != null)
          _buildServiceDetails(viewModel),
        
        const SizedBox(height: 16),
        
        // Provider Selection
        _buildProviderSelection(viewModel),
        
        const SizedBox(height: 16),
        
        // Comparison Content
        _buildComparisonContent(viewModel),
      ],
    );
  }

  Widget _buildCategorySelection(ComparisonViewModel viewModel) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.category,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Select Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  'All',
                  ...viewModel.allCategories,
                ].map((category) {
                  final isSelected = viewModel.selectedServiceCategory == category;
                  return FilterChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        viewModel.setSelectedServiceCategory(category);
                        // Load services for the selected category
                        viewModel.loadServicesForCategory(category);
                      }
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textBlack,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : Colors.grey[300]!,
                      width: isSelected ? 1.5 : 1,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOptions(ComparisonViewModel viewModel) {
    final filters = viewModel.availableFilters;
    final accreditations = (filters['accreditations'] as List?)?.cast<String>() ?? [];
    final providerTypes = (filters['providerTypes'] as List?)?.cast<String>() ?? [];
    final insuranceList = (filters['insurance'] as List?)?.cast<String>() ?? [];
    final priceRanges = (filters['priceRanges'] as List?) ?? [];
    String? selectedPriceRangeLabel;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.filter_list,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Filter Options',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildFilterChip(
                    'Nearest',
                    Icons.location_on,
                    viewModel.nearest,
                    (value) => viewModel.updateFilters(nearest: value),
                  ),
                  _buildFilterChip(
                    'Low Cost',
                    Icons.attach_money,
                    viewModel.lowCost,
                    (value) => viewModel.updateFilters(lowCost: value),
                  ),
                  _buildFilterChip(
                    'Top Rated',
                    Icons.star,
                    viewModel.topRated,
                    (value) => viewModel.updateFilters(topRated: value),
                  ),
                  _buildFilterChip(
                    'Insurance',
                    Icons.security,
                    viewModel.insurance,
                    (value) => viewModel.updateFilters(insurance: value),
                  ),
                  // API-driven accreditations
                  ...accreditations.map((acc) => _buildFilterChip(
                    acc,
                    Icons.verified,
                    false,
                    (value) {},
                  )),
                  // API-driven provider types
                  ...providerTypes.map((type) => _buildFilterChip(
                    type,
                    Icons.business,
                    false,
                    (value) {},
                  )),
                  // API-driven insurance options
                  ...insuranceList.map((insurance) => _buildFilterChip(
                    insurance,
                    Icons.health_and_safety,
                    false,
                    (value) {},
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, bool isSelected, Function(bool) onChanged) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: onChanged,
      backgroundColor: Colors.grey[100],
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textBlack,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : Colors.grey[300]!,
        width: isSelected ? 1.5 : 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: isSelected ? 2 : 0,
    );
  }

  Widget _buildServiceSelection(ComparisonViewModel viewModel) {
    final services = viewModel.getServicesForCategory(viewModel.selectedServiceCategory);
    final selectedServiceObj = viewModel.allServices.firstWhere(
      (s) => s.name == viewModel.selectedService,
      orElse: () => MedicalService(
        id: '',
        name: '',
        description: '',
        category: '',
        price: 0.0,
        duration: 0,
      ),
    );
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.medical_services,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Select Service',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (services.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No services available for this category',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                ServiceSelector(
                  services: services,
                  selectedService: viewModel.selectedService,
                  onServiceChanged: (service) {
                    viewModel.setSelectedService(service);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceDetails(ComparisonViewModel viewModel) {
    final service = viewModel.selectedServiceDetails!;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.info,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Service Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      service.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildDetailChip('${service.currency} ${service.price}', Colors.green),
                        _buildDetailChip('${service.duration} min', Colors.blue),
                        _buildDetailChip(service.category, Colors.orange),
                        if (service.subcategory != null)
                          _buildDetailChip(service.subcategory!, Colors.purple),
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

  Widget _buildDetailChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildProviderSelection(ComparisonViewModel viewModel) {
    final availableProviders = viewModel.getProvidersForSelectedService();
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.business,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Select Providers to Compare',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Select up to 3 providers to compare (${viewModel.selectedProviders.length}/3)',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (availableProviders.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No providers available for this service',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                // Selected Providers Display
                if (viewModel.selectedProviders.isNotEmpty) ...[
                  Text(
                    'Selected Providers:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: viewModel.selectedProviders.map((provider) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                provider.name.isNotEmpty ? provider.name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              provider.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => viewModel.removeProvider(provider),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Provider Dropdown
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ServiceProvider>(
                      isExpanded: true,
                      hint: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Select a provider to add...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      value: null, // Always null to show hint
                      items: availableProviders
                          .where((provider) => !viewModel.selectedProviders.contains(provider))
                          .map((provider) {
                        return DropdownMenuItem<ServiceProvider>(
                          value: provider,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // reduced from 8
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.grey[300],
                                  child: Text(
                                    provider.name.isNotEmpty ? provider.name[0].toUpperCase() : '?',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        provider.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '${provider.type} • ${provider.location?.city ?? 'Unknown'}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (provider.rating != null)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.star, size: 14, color: Colors.amber),
                                      Text(
                                        ' ${provider.rating!.toStringAsFixed(1)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (ServiceProvider? provider) {
                        if (provider != null && viewModel.selectedProviders.length < 3) {
                          viewModel.addProvider(provider);
                        }
                      },
                      isDense: true,
                    ),
                  ),
                ),
                
                // Quick Action Buttons
                if (viewModel.selectedProviders.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: viewModel.selectedProviders.length >= 2
                              ? () {
                                  // TODO: Show comparison table
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Comparison table will be shown here'),
                                    ),
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.compare_arrows, size: 16),
                          label: const Text('Compare Selected'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          viewModel.clearAllProviders();
                        },
                        icon: const Icon(Icons.clear_all, size: 16),
                        label: const Text('Clear All'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedProviderCard(ServiceProvider provider, ComparisonViewModel viewModel) {
    return Card(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            provider.name[0],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          provider.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(provider.type),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle, color: Colors.red),
          onPressed: () {
            viewModel.toggleProviderSelection(provider);
          },
        ),
      ),
    );
  }

  Widget _buildAvailableProviderCard(ServiceProvider provider, ComparisonViewModel viewModel) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: Text(
            provider.name[0],
            style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(provider.name),
        subtitle: Text(' 0{provider.type} 0{provider.location}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () {
                viewModel.toggleProviderSelection(provider);
              },
            ),
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.blue),
              tooltip: 'Show Provider Services',
              onPressed: () async {
                await viewModel.fetchProviderServicesByProvider(provider.id);
                final services = viewModel.providerServicesByProvider;
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Services for ${provider.name}'),
                    content: services.isEmpty
                        ? const Text('No services found for this provider.')
                        : SizedBox(
                            width: 300,
                            height: 300,
                            child: ListView.builder(
                              itemCount: services.length,
                              itemBuilder: (context, index) {
                                final item = services[index];
                                final doctor = item.doctor;
                                final availability = item.availability;
                                final service = item.serviceId ?? {};
                                return ListTile(
                                  title: Text(doctor['name'] ?? 'No Name'),
                                  subtitle: Text('Specialization: ${doctor['specialization'] ?? '-'}\nNext Slot: ${availability['nextSlot'] ?? '-'}'),
                                );
                              },
                            ),
                          ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.rate_review, color: Colors.orange),
              tooltip: 'Show Reviews',
              onPressed: () async {
                await viewModel.fetchProviderReviews(provider.id);
                final reviews = viewModel.providerReviews;
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Reviews for ${provider.name}'),
                    content: reviews.isEmpty
                        ? const Text('No reviews found for this provider.')
                        : SizedBox(
                            width: 350,
                            height: 300,
                            child: ListView.builder(
                              itemCount: reviews.length,
                              itemBuilder: (context, index) {
                                final review = reviews[index];
                                return ListTile(
                                  leading: Icon(Icons.star, color: Colors.amber),
                                  title: Text(review['review'] ?? ''),
                                  subtitle: Text('Rating: \\${review['rating'] ?? '-'}\nDate: \\${review['date']?.toString().substring(0, 10) ?? '-'}'),
                                );
                              },
                            ),
                          ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        onTap: () {
          viewModel.toggleProviderSelection(provider);
        },
      ),
    );
  }

  Widget _buildComparisonContent(ComparisonViewModel viewModel) {
    if (viewModel.selectedProviders.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.compare_arrows,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Select providers to compare',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose up to 3 providers to see a detailed comparison',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If service details and providers are set by the comparison API, use them directly
    final useDirect = viewModel.selectedServiceDetails != null && viewModel.providers.isNotEmpty;
    return ComparisonTable(
      providers: viewModel.selectedProviders,
      selectedService: viewModel.selectedService,
      selectedFilters: {}, // You may want to pass actual filters if used
      allServices: viewModel.allServices,
      directProviders: useDirect ? viewModel.providers : null,
      directService: useDirect ? viewModel.selectedServiceDetails : null,
    );
  }
} 