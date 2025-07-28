import 'package:flutter/material.dart';
import 'backend_testing_screen.dart';
import 'services_api_test_screen.dart';

class TestingHomeScreen extends StatelessWidget {
  const TestingHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Testing Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.science,
                      size: 48,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Medico Testing Suite',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Comprehensive testing tools for backend integration',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Testing options
            const Text(
              'Testing Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Backend API Testing
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.api,
                  color: Colors.green,
                  size: 32,
                ),
                title: const Text(
                  'Backend API Testing',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Test all backend endpoints and API functionality',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BackendTestingScreen(),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Services API Testing
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.medical_services,
                  color: Colors.teal,
                  size: 32,
                ),
                title: const Text(
                  'Services API Testing',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Test services API integration for comparison feature',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ServicesApiTestScreen(),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 12),
            
            // UI Testing (placeholder for future)
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.phone_android,
                  color: Colors.orange,
                  size: 32,
                ),
                title: const Text(
                  'UI Testing',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Test user interface and user experience',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('UI Testing coming soon!'),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Performance Testing (placeholder for future)
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.speed,
                  color: Colors.purple,
                  size: 32,
                ),
                title: const Text(
                  'Performance Testing',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Test app performance and response times',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Performance Testing coming soon!'),
                    ),
                  );
                },
              ),
            ),
            
            const Spacer(),
            
            // Instructions
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📋 Instructions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Ensure your backend server is running on localhost:3000\n'
                      '2. Start with Backend API Testing\n'
                      '3. Test Services API for comparison feature\n'
                      '4. Run individual tests or use "Run All Tests"\n'
                      '5. Check the response and logs for detailed results',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 