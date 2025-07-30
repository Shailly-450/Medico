import 'package:flutter/material.dart';
import '../../core/services/insurance_service.dart';
import '../../core/services/insurance_filters_service.dart';
import '../../models/insurance.dart';
import '../../core/theme/app_colors.dart';
import 'dart:io';

class InsuranceApiTestScreen extends StatefulWidget {
  const InsuranceApiTestScreen({Key? key}) : super(key: key);

  @override
  State<InsuranceApiTestScreen> createState() => _InsuranceApiTestScreenState();
}

class _InsuranceApiTestScreenState extends State<InsuranceApiTestScreen> {
  final InsuranceService _insuranceService = InsuranceService();
  
  List<Insurance> _insurances = [];
  Map<String, dynamic> _filters = {};
  List<String> _insuranceProviders = [];
  List<Map<String, dynamic>> _priceRanges = [];
  List<String> _categories = [];
  List<String> _accreditations = [];
  List<String> _providerTypes = [];
  
  bool _isLoading = false;
  String? _error;
  String _lastTestResult = '';

  @override
  void initState() {
    super.initState();
    _runAllTests();
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _lastTestResult = '';
    });

    try {
      await _testGetInsurances();
      await _testGetInsuranceFilters();
      await _testGetInsuranceProviders();
      await _testGetPriceRanges();
      await _testGetCategories();
      await _testGetAccreditations();
      await _testGetProviderTypes();
      
      setState(() {
        _lastTestResult = '✅ All tests completed successfully!';
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _lastTestResult = '❌ Test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testGetInsurances() async {
    try {
      final insurances = await _insuranceService.getInsurances();
      setState(() {
        _insurances = insurances;
      });
      print('✅ Get Insurances API: Success - ${insurances.length} insurances loaded');
    } catch (e) {
      print('❌ Get Insurances API: Failed - $e');
      rethrow;
    }
  }

  Future<void> _testGetInsuranceFilters() async {
    try {
      final filters = await InsuranceFiltersService.getInsuranceFilters();
      setState(() {
        _filters = filters;
      });
      print('✅ Get Insurance Filters API: Success');
    } catch (e) {
      print('❌ Get Insurance Filters API: Failed - $e');
      rethrow;
    }
  }

  Future<void> _testGetInsuranceProviders() async {
    try {
      final providers = await InsuranceFiltersService.getInsuranceProviders();
      setState(() {
        _insuranceProviders = providers;
      });
      print('✅ Get Insurance Providers API: Success - ${providers.length} providers');
    } catch (e) {
      print('❌ Get Insurance Providers API: Failed - $e');
      rethrow;
    }
  }

  Future<void> _testGetPriceRanges() async {
    try {
      final priceRanges = await InsuranceFiltersService.getPriceRanges();
      setState(() {
        _priceRanges = priceRanges;
      });
      print('✅ Get Price Ranges API: Success - ${priceRanges.length} ranges');
    } catch (e) {
      print('❌ Get Price Ranges API: Failed - $e');
      rethrow;
    }
  }

  Future<void> _testGetCategories() async {
    try {
      final categories = await InsuranceFiltersService.getCategories();
      setState(() {
        _categories = categories;
      });
      print('✅ Get Categories API: Success - ${categories.length} categories');
    } catch (e) {
      print('❌ Get Categories API: Failed - $e');
      rethrow;
    }
  }

  Future<void> _testGetAccreditations() async {
    try {
      final accreditations = await InsuranceFiltersService.getAccreditations();
      setState(() {
        _accreditations = accreditations;
      });
      print('✅ Get Accreditations API: Success - ${accreditations.length} accreditations');
    } catch (e) {
      print('❌ Get Accreditations API: Failed - $e');
      rethrow;
    }
  }

  Future<void> _testGetProviderTypes() async {
    try {
      final providerTypes = await InsuranceFiltersService.getProviderTypes();
      setState(() {
        _providerTypes = providerTypes;
      });
      print('✅ Get Provider Types API: Success - ${providerTypes.length} types');
    } catch (e) {
      print('❌ Get Provider Types API: Failed - $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insurance API Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _runAllTests,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTestResultCard(),
                  const SizedBox(height: 16),
                  _buildInsurancesCard(),
                  const SizedBox(height: 16),
                  _buildFiltersCard(),
                  const SizedBox(height: 16),
                  _buildInsuranceProvidersCard(),
                  const SizedBox(height: 16),
                  _buildPriceRangesCard(),
                  const SizedBox(height: 16),
                  _buildCategoriesCard(),
                  const SizedBox(height: 16),
                  _buildAccreditationsCard(),
                  const SizedBox(height: 16),
                  _buildProviderTypesCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildTestResultCard() {
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
                  _error == null ? Icons.check_circle : Icons.error,
                  color: _error == null ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Test Results',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _error == null ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _lastTestResult,
              style: TextStyle(
                color: _error == null ? Colors.green : Colors.red,
                fontSize: 14,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                'Error: $_error',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInsurancesCard() {
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
                Icon(Icons.health_and_safety, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Insurances',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_insurances.length} items',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_insurances.isEmpty)
              const Text(
                'No insurances found',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              )
            else
              ..._insurances.take(3).map((insurance) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insurance.insuranceProvider,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Policy #${insurance.policyNumber}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: insurance.isValid ? Colors.green[100] : Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        insurance.isValid ? 'Valid' : 'Expired',
                        style: TextStyle(
                          color: insurance.isValid ? Colors.green[800] : Colors.red[800],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            if (_insurances.length > 3)
              Text(
                '... and ${_insurances.length - 3} more',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersCard() {
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
                Icon(Icons.filter_list, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Available Filters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._filters.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    '${entry.key}:',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.value is List ? '${(entry.value as List).length} items' : '${entry.value}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceProvidersCard() {
    return _buildListCard(
      'Insurance Providers',
      Icons.business,
      _insuranceProviders,
    );
  }

  Widget _buildPriceRangesCard() {
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
                Icon(Icons.attach_money, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Price Ranges',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_priceRanges.length} ranges',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._priceRanges.map((range) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                range['label'] ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesCard() {
    return _buildListCard(
      'Categories',
      Icons.category,
      _categories,
    );
  }

  Widget _buildAccreditationsCard() {
    return _buildListCard(
      'Accreditations',
      Icons.verified,
      _accreditations,
    );
  }

  Widget _buildProviderTypesCard() {
    return _buildListCard(
      'Provider Types',
      Icons.business,
      _providerTypes,
    );
  }

  Widget _buildListCard(String title, IconData icon, List<String> items) {
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
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
                const Spacer(),
                Text(
                  '${items.length} items',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Text(
                'No items found',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.take(10).map((item) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                )).toList(),
              ),
            if (items.length > 10)
              Text(
                '... and ${items.length - 10} more',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
} 