import 'package:flutter/material.dart';
import '../../core/services/services_api_service.dart';
import '../../models/medical_service.dart';
import '../../models/service_provider.dart';
import '../../core/theme/app_colors.dart';

class ServicesApiTestScreen extends StatefulWidget {
  const ServicesApiTestScreen({Key? key}) : super(key: key);

  @override
  State<ServicesApiTestScreen> createState() => _ServicesApiTestScreenState();
}

class _ServicesApiTestScreenState extends State<ServicesApiTestScreen> {
  List<MedicalService> _services = [];
  List<String> _categories = [];
  List<ServiceProvider> _providers = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic> _apiStatus = {};
  String _selectedCategory = 'consultation';
  List<MedicalService> _categoryServices = [];
  Map<String, dynamic>? _comparisonData;
  String _selectedServiceId = '';
  
  // Provider testing
  String _selectedProviderType = '';
  List<String> _providerTypes = [];
  String _selectedCity = 'Bangalore';
  String _selectedState = 'Karnataka';
  List<ServiceProvider> _filteredProviders = [];
  // Provider by ID testing
  String _providerIdInput = '';
  ServiceProvider? _providerById;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _apiStatus.clear();
    });

    try {
      // Test services API
      final servicesStart = DateTime.now();
      final services = await ServicesApiService.fetchServices();
      final servicesEnd = DateTime.now();
      final servicesDuration = servicesEnd.difference(servicesStart).inMilliseconds;
      
      // Test categories API
      final categoriesStart = DateTime.now();
      final categories = await ServicesApiService.fetchCategories();
      final categoriesEnd = DateTime.now();
      final categoriesDuration = categoriesEnd.difference(categoriesStart).inMilliseconds;
      
      // Test category-specific API
      final categoryStart = DateTime.now();
      final categoryServices = await ServicesApiService.fetchServicesByCategory(_selectedCategory);
      final categoryEnd = DateTime.now();
      final categoryDuration = categoryEnd.difference(categoryStart).inMilliseconds;
      
      // Test providers API
      final providersStart = DateTime.now();
      final providers = await ServicesApiService.fetchProviders(
        page: 1,
        limit: 20,
      );
      final providersEnd = DateTime.now();
      final providersDuration = providersEnd.difference(providersStart).inMilliseconds;

      // Fetch provider types
      final providerTypes = await ServicesApiService.fetchProviderTypes();
      String defaultProviderType = providerTypes.isNotEmpty ? providerTypes.first : '';
      
      setState(() {
        _services = services;
        _categories = categories;
        _categoryServices = categoryServices;
        _providers = providers;
        _filteredProviders = providers;
        _providerTypes = providerTypes;
        _selectedProviderType = defaultProviderType;
        _isLoading = false;
        _apiStatus = {
          'services': {
            'count': services.length,
            'duration': servicesDuration,
            'status': 'success',
          },
          'categories': {
            'count': categories.length,
            'duration': categoriesDuration,
            'status': 'success',
          },
          'category_specific': {
            'count': categoryServices.length,
            'duration': categoryDuration,
            'status': 'success',
            'category': _selectedCategory,
          },
          'providers': {
            'count': providers.length,
            'duration': providersDuration,
            'status': 'success',
          },
        };
      });
      
      print('✅ Loaded ${services.length} services from API (${servicesDuration}ms)');
      print('✅ Loaded ${categories.length} categories from API (${categoriesDuration}ms)');
      print('✅ Loaded ${categoryServices.length} services for category "$_selectedCategory" (${categoryDuration}ms)');
      print('✅ Loaded ${providers.length} providers from API (${providersDuration}ms)');
      print('✅ Available categories: $categories');
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
        _isLoading = false;
      });
      print('❌ Error loading data: $e');
    }
  }

  Future<void> _testCategoryApi(String category) async {
    setState(() {
      _selectedCategory = category;
      _isLoading = true;
    });

    try {
      final start = DateTime.now();
      final services = await ServicesApiService.fetchServicesByCategory(category);
      final end = DateTime.now();
      final duration = end.difference(start).inMilliseconds;

      setState(() {
        _categoryServices = services;
        _isLoading = false;
        _apiStatus['category_specific'] = {
          'count': services.length,
          'duration': duration,
          'status': 'success',
          'category': category,
        };
      });

      print('✅ Loaded ${services.length} services for category "$category" (${duration}ms)');
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load services for category $category: $e';
        _isLoading = false;
      });
      print('❌ Error loading services for category $category: $e');
    }
  }

  Future<void> _testServiceComparison(String serviceId) async {
    if (serviceId.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final start = DateTime.now();
      final comparisonData = await ServicesApiService.fetchServiceComparison(
        serviceId: serviceId,
        nearest: true,
        lowCost: false,
        topRated: false,
        insurance: false,
        availableToday: false,
      );
      final end = DateTime.now();
      final duration = end.difference(start).inMilliseconds;

      setState(() {
        _comparisonData = comparisonData;
        _isLoading = false;
        _apiStatus['service_comparison'] = {
          'duration': duration,
          'status': 'success',
          'serviceId': serviceId,
        };
      });

      print('✅ Loaded service comparison for service ID "$serviceId" (${duration}ms)');
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load service comparison: $e';
        _isLoading = false;
      });
      print('❌ Error loading service comparison: $e');
    }
  }

  Future<void> _testProvidersApi({
    String? type,
    String? city,
    String? state,
  }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final start = DateTime.now();
      final providers = await ServicesApiService.fetchProviders(
        type: type,
        city: city,
        state: state,
        page: 1,
        limit: 20,
      );
      final end = DateTime.now();
      final duration = end.difference(start).inMilliseconds;

      setState(() {
        _filteredProviders = providers;
        _isLoading = false;
        _apiStatus['providers_filtered'] = {
          'count': providers.length,
          'duration': duration,
          'status': 'success',
          'filters': {
            'type': type,
            'city': city,
            'state': state,
          },
        };
      });

      print('✅ Loaded ${providers.length} filtered providers (${duration}ms)');
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load filtered providers: $e';
        _isLoading = false;
      });
      print('❌ Error loading filtered providers: $e');
    }
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
          'Services API Test',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _buildSuccessState(),
    );
  }

  Widget _buildErrorState() {
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
            'API Test Failed',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAllData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'API Test Successful',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Loaded ${_services.length} services, ${_categories.length} categories, and ${_providers.length} providers',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // API Status Cards
        _buildApiStatusCards(),
        
        const SizedBox(height: 16),
        
        // Providers API Testing Section
        _buildProvidersTestingSection(),
        
        const SizedBox(height: 16),
        
        // Provider by ID Testing Section
        _buildProviderByIdSection(),
        const SizedBox(height: 16),

        // Service Comparison Testing Section
        _buildServiceComparisonTestingSection(),
        
        const SizedBox(height: 16),
        
        // Category Testing Section
        _buildCategoryTestingSection(),
        
        const SizedBox(height: 16),
        
        // Categories Section
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.category,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Categories (${_categories.length})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((category) {
                    return Chip(
                      label: Text(category),
                      backgroundColor: AppColors.accent,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Services Section
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.medical_services,
                      color: Colors.teal,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Services (${_services.length})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._services.take(10).map((service) => _buildServiceItem(service)),
                if (_services.length > 10)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '... and ${_services.length - 10} more services',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Providers Section
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.business,
                      color: Colors.purple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Providers (${_providers.length})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._providers.take(5).map((provider) => _buildProviderItem(provider)),
                if (_providers.length > 5)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '... and ${_providers.length - 5} more providers',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProvidersTestingSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.business,
                  color: Colors.purple,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Providers API Test',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Test the providers API with filters:',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            
            // Provider Type Filter
            DropdownButtonFormField<String>(
              value: _selectedProviderType.isNotEmpty ? _selectedProviderType : null,
              decoration: InputDecoration(
                labelText: 'Provider Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: _providerTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedProviderType = value;
                  });
                }
              },
            ),
            
            const SizedBox(height: 12),
            
            // City Filter
            TextField(
              decoration: InputDecoration(
                labelText: 'City',
                hintText: 'Enter city name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                _selectedCity = value;
              },
            ),
            
            const SizedBox(height: 12),
            
            // State Filter
            TextField(
              decoration: InputDecoration(
                labelText: 'State',
                hintText: 'Enter state name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                _selectedState = value;
              },
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _testProvidersApi(
                        type: _selectedProviderType,
                        city: _selectedCity.isNotEmpty ? _selectedCity : null,
                        state: _selectedState.isNotEmpty ? _selectedState : null,
                      );
                    },
                    child: const Text('Test Providers API'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    _testProvidersApi();
                  },
                  child: const Text('All Providers'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (_filteredProviders.isNotEmpty) ...[
              Text(
                'Filtered Providers (${_filteredProviders.length}):',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 8),
              ..._filteredProviders.take(3).map((provider) => _buildProviderItem(provider)),
              if (_filteredProviders.length > 3)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '... and ${_filteredProviders.length - 3} more filtered providers',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProviderByIdSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.search,
                  color: Colors.deepOrange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Get Provider by ID',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Provider ID',
                hintText: 'Enter provider ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                _providerIdInput = value;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (_providerIdInput.isNotEmpty) {
                      setState(() => _isLoading = true);
                      final provider = await ServicesApiService.fetchProviderById(_providerIdInput);
                      setState(() {
                        _providerById = provider;
                        _isLoading = false;
                      });
                    }
                  },
                  child: const Text('Fetch Provider'),
                ),
                const SizedBox(width: 12),
                if (_providerById != null)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _providerById = null;
                        _providerIdInput = '';
                      });
                    },
                    child: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_providerById != null)
              _buildProviderItem(_providerById!),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceComparisonTestingSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.compare_arrows,
                  color: Colors.indigo,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Service Comparison API Test',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Test the service comparison API endpoint:',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Service ID',
                      hintText: 'Enter service ID to test',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      _selectedServiceId = value;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedServiceId.isNotEmpty) {
                      _testServiceComparison(_selectedServiceId);
                    }
                  },
                  child: const Text('Test'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_comparisonData != null) ...[
              Text(
                'Comparison Data:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_comparisonData!['service'] != null) ...[
                      Text(
                        'Service: ${_comparisonData!['service']['name'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Price: ${_comparisonData!['service']['currency'] ?? 'USD'} ${_comparisonData!['service']['price'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${_comparisonData!['service']['category'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Providers: ${(_comparisonData!['providers'] as List?)?.length ?? 0}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Filters Applied: ${_comparisonData!['filters'] != null ? 'Yes' : 'No'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTestingSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.api,
                  color: Colors.purple,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Category-Specific API Test',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Test the category-specific API endpoint:',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Select Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _testCategoryApi(value);
                }
              },
            ),
            const SizedBox(height: 16),
            if (_categoryServices.isNotEmpty) ...[
              Text(
                'Services for "$_selectedCategory" (${_categoryServices.length}):',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 8),
              ..._categoryServices.map((service) => _buildServiceItem(service)),
            ] else if (_apiStatus['category_specific'] != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No services found for category "$_selectedCategory"',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildApiStatusCards() {
    return Column(
      children: [
        // Services API Status
        Card(
          elevation: 1,
          color: Colors.green[50],
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.medical_services,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Services API',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                      Text(
                        '${_apiStatus['services']?['count'] ?? 0} services • ${_apiStatus['services']?['duration'] ?? 0}ms',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Categories API Status
        Card(
          elevation: 1,
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.category,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categories API',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                      Text(
                        '${_apiStatus['categories']?['count'] ?? 0} categories • ${_apiStatus['categories']?['duration'] ?? 0}ms',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.check_circle,
                  color: Colors.blue,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Providers API Status
        Card(
          elevation: 1,
          color: Colors.purple[50],
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.business,
                  color: Colors.purple,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Providers API',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                      Text(
                        '${_apiStatus['providers']?['count'] ?? 0} providers • ${_apiStatus['providers']?['duration'] ?? 0}ms',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.check_circle,
                  color: Colors.purple,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Category-Specific API Status
        Card(
          elevation: 1,
          color: Colors.orange[50],
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.api,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category API',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                      Text(
                        '${_apiStatus['category_specific']?['count'] ?? 0} services for "${_apiStatus['category_specific']?['category'] ?? 'N/A'}" • ${_apiStatus['category_specific']?['duration'] ?? 0}ms',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.check_circle,
                  color: Colors.orange,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Service Comparison API Status
        if (_apiStatus['service_comparison'] != null)
          Card(
            elevation: 1,
            color: Colors.indigo[50],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.compare_arrows,
                    color: Colors.indigo,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comparison API',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBlack,
                          ),
                        ),
                        Text(
                          'Service ID: ${_apiStatus['service_comparison']?['serviceId'] ?? 'N/A'} • ${_apiStatus['service_comparison']?['duration'] ?? 0}ms',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.check_circle,
                    color: Colors.indigo,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

        // Filtered Providers API Status
        if (_apiStatus['providers_filtered'] != null)
          Card(
            elevation: 1,
            color: Colors.teal[50],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: Colors.teal,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filtered Providers',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBlack,
                          ),
                        ),
                        Text(
                          '${_apiStatus['providers_filtered']?['count'] ?? 0} providers • ${_apiStatus['providers_filtered']?['duration'] ?? 0}ms',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.check_circle,
                    color: Colors.teal,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildServiceItem(MedicalService service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  service.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlack,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '\$${service.price}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            service.description,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  service.category,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue[700],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${service.duration} min',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green[700],
                  ),
                ),
              ),
              if (service.insuranceCoverage) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Insurance',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProviderItem(ServiceProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  provider.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlack,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  provider.type,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            provider.description,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '⭐ ${provider.rating}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue[700],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '₹${provider.averagePrice}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green[700],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  provider.location.shortAddress,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
          if (provider.specialties.isNotEmpty) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 2,
              children: provider.specialties.take(3).map((specialty) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  specialty,
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.teal[700],
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
} 