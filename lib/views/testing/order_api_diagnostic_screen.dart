import 'package:flutter/material.dart';
import '../../core/services/order_api_diagnostic.dart';
import '../../core/theme/app_colors.dart';

class OrderApiDiagnosticScreen extends StatefulWidget {
  const OrderApiDiagnosticScreen({Key? key}) : super(key: key);

  @override
  State<OrderApiDiagnosticScreen> createState() => _OrderApiDiagnosticScreenState();
}

class _OrderApiDiagnosticScreenState extends State<OrderApiDiagnosticScreen> {
  Map<String, dynamic>? _diagnosticResults;
  bool _isRunning = false;

  Future<void> _runDiagnostic() async {
    setState(() {
      _isRunning = true;
    });

    try {
      final results = await OrderApiDiagnostic.runFullDiagnostic();
      setState(() {
        _diagnosticResults = results;
        _isRunning = false;
      });
    } catch (e) {
      setState(() {
        _diagnosticResults = {
          'error': e.toString(),
          'overall': {'success': false, 'successRate': '0%'},
        };
        _isRunning = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _runDiagnostic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order API Diagnostic'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRunning ? null : _runDiagnostic,
            tooltip: 'Run Diagnostic',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5E8),
              Color(0xFFF0F8F0),
              Color(0xFFE6F3E6),
              Color(0xFFF5F9F5),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: _isRunning
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text(
                      'Running API Diagnostic...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
            : _diagnosticResults == null
                ? const Center(
                    child: Text('No diagnostic results available'),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOverallStatus(),
                        const SizedBox(height: 24),
                        _buildTestResults(),
                        const SizedBox(height: 24),
                        _buildRecommendations(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildOverallStatus() {
    final overall = _diagnosticResults!['overall'] as Map<String, dynamic>;
    final isSuccess = overall['success'] as bool;
    final successRate = overall['successRate'] as String;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Status',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isSuccess ? 'All Tests Passed' : 'Some Tests Failed',
                        style: TextStyle(
                          color: isSuccess ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Success Rate',
                  successRate,
                  isSuccess ? Colors.green : Colors.orange,
                ),
                _buildStatCard(
                  'Tests Passed',
                  '${overall['successfulTests']}/${overall['totalTests']}',
                  isSuccess ? Colors.green : Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResults() {
    final tests = _diagnosticResults!['tests'] as Map<String, dynamic>;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Results',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...tests.entries.map((entry) => _buildTestItem(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildTestItem(String testName, Map<String, dynamic> result) {
    final isSuccess = result['success'] as bool;
    final message = result['message'] as String;
    final error = result['error'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSuccess ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSuccess ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _formatTestName(testName),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: isSuccess ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Error: $error',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    final recommendations = _diagnosticResults!['recommendations'] as List<String>?;
    
    if (recommendations == null || recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommendations',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...recommendations.map((recommendation) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: const TextStyle(fontSize: 14),
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

  String _formatTestName(String testName) {
    switch (testName) {
      case 'connectivity':
        return 'Basic Connectivity';
      case 'authentication':
        return 'Authentication';
      case 'ordersEndpoint':
        return 'Orders Endpoint';
      case 'createOrder':
        return 'Create Order Endpoint';
      default:
        return testName.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim();
    }
  }
} 