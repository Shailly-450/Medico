import 'dart:convert';

import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/services/hospital_service.dart';

class BackendTestingScreen extends StatefulWidget {
  const BackendTestingScreen({Key? key}) : super(key: key);

  @override
  State<BackendTestingScreen> createState() => _BackendTestingScreenState();
}

class _BackendTestingScreenState extends State<BackendTestingScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _responseController = TextEditingController();
  
  bool _isLoading = false;
  String _currentTest = '';
  bool _isConnected = false;
  
  // Test results
  final Map<String, bool> _testResults = {};
  final List<String> _testLogs = [];

  @override
  void initState() {
    super.initState();
    _initializeApiService();
    _checkConnection();
  }

  Future<void> _initializeApiService() async {
    await ApiService.initialize();
  }

  Future<void> _checkConnection() async {
    setState(() => _isLoading = true);
    final isConnected = await ApiService.healthCheck();
    setState(() {
      _isConnected = isConnected;
      _isLoading = false;
    });
    
    if (isConnected) {
      _addLog('✅ Backend connection successful');
    } else {
      _addLog('❌ Backend connection failed');
    }
  }

  void _addLog(String message) {
    setState(() {
      _testLogs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
  }

  void _updateResponse(String response) {
    setState(() {
      _responseController.text = response;
    });
  }

  void _updateTestResult(String test, bool success) {
    setState(() {
      _testResults[test] = success;
    });
  }

  // Test methods
  Future<void> _testRegistration() async {
    setState(() {
      _isLoading = true;
      _currentTest = 'User Registration';
    });

    try {
      final result = await ApiService.register({
        'firstName': 'Test',
        'lastName': 'User',
        'email': 'testuser@example.com',
        'password': 'TestPassword123!',
        'phone': '+1234567890',
        'dateOfBirth': '1990-01-01',
        'gender': 'male',
        'role': 'patient',
      });

      final success = result['success'] == true;
      _updateTestResult('Registration', success);
      _updateResponse(JsonEncoder.withIndent('  ').convert(result));
      
      if (success) {
        _addLog('✅ Registration test passed');
      } else {
        _addLog('❌ Registration test failed: ${result['message']}');
      }
    } catch (e) {
      _updateTestResult('Registration', false);
      _addLog('❌ Registration test error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _currentTest = 'User Login';
    });

    try {
      final result = await ApiService.login(
        _emailController.text.isEmpty ? 'testuser@example.com' : _emailController.text,
        _passwordController.text.isEmpty ? 'TestPassword123!' : _passwordController.text,
      );

      final success = result['success'] == true;
      _updateTestResult('Login', success);
      _updateResponse(JsonEncoder.withIndent('  ').convert(result));
      
      if (success) {
        _addLog('✅ Login test passed');
      } else {
        _addLog('❌ Login test failed: ${result['message']}');
      }
    } catch (e) {
      _updateTestResult('Login', false);
      _addLog('❌ Login test error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testGetProfile() async {
    setState(() {
      _isLoading = true;
      _currentTest = 'Get Profile';
    });

    try {
      final result = await ApiService.getProfile();
      final success = result['success'] == true;
      _updateTestResult('Get Profile', success);
      _updateResponse(JsonEncoder.withIndent('  ').convert(result));
      
      if (success) {
        _addLog('✅ Get Profile test passed');
      } else {
        _addLog('❌ Get Profile test failed: ${result['message']}');
      }
    } catch (e) {
      _updateTestResult('Get Profile', false);
      _addLog('❌ Get Profile test error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testGetHospitals() async {
    setState(() {
      _isLoading = true;
      _currentTest = 'Get Hospitals';
    });

    try {
      final result = await ApiService.getHospitals(
        page: 1,
        limit: 5,
        search: 'general',
      );
      
      final success = result['success'] == true;
      _updateTestResult('Get Hospitals', success);
      _updateResponse(JsonEncoder.withIndent('  ').convert(result));
      
      if (success) {
        _addLog('✅ Get Hospitals test passed');
        
        // Test hospital data conversion
        if (result['data'] != null) {
          final hospitalsData = result['data'] as List<dynamic>;
          if (hospitalsData.isNotEmpty) {
            try {
              final hospital = HospitalService.convertToHospitalModel(hospitalsData.first);
              _addLog('✅ Hospital conversion successful: ${hospital.name} (${hospital.type})');
            } catch (e) {
              _addLog('❌ Hospital conversion failed: $e');
            }
          }
        }
      } else {
        _addLog('❌ Get Hospitals test failed: ${result['message']}');
      }
    } catch (e) {
      _updateTestResult('Get Hospitals', false);
      _addLog('❌ Get Hospitals test error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testGetDoctors() async {
    setState(() {
      _isLoading = true;
      _currentTest = 'Get Doctors';
    });

    try {
      final result = await ApiService.getDoctors(
        page: 1,
        limit: 5,
        specialty: 'Cardiology',
      );
      
      final success = result['success'] == true;
      _updateTestResult('Get Doctors', success);
      _updateResponse(JsonEncoder.withIndent('  ').convert(result));
      
      if (success) {
        _addLog('✅ Get Doctors test passed');
      } else {
        _addLog('❌ Get Doctors test failed: ${result['message']}');
      }
    } catch (e) {
      _updateTestResult('Get Doctors', false);
      _addLog('❌ Get Doctors test error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testGetAppointments() async {
    setState(() {
      _isLoading = true;
      _currentTest = 'Get Appointments';
    });

    try {
      final result = await ApiService.getAppointments(
        page: 1,
        limit: 5,
      );
      
      final success = result['success'] == true;
      _updateTestResult('Get Appointments', success);
      _updateResponse(JsonEncoder.withIndent('  ').convert(result));
      
      if (success) {
        _addLog('✅ Get Appointments test passed');
      } else {
        _addLog('❌ Get Appointments test failed: ${result['message']}');
      }
    } catch (e) {
      _updateTestResult('Get Appointments', false);
      _addLog('❌ Get Appointments test error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testGetConversations() async {
    setState(() {
      _isLoading = true;
      _currentTest = 'Get Conversations';
    });

    try {
      final result = await ApiService.getConversations(
        page: 1,
        limit: 5,
      );
      
      final success = result['success'] == true;
      _updateTestResult('Get Conversations', success);
      _updateResponse(JsonEncoder.withIndent('  ').convert(result));
      
      if (success) {
        _addLog('✅ Get Conversations test passed');
      } else {
        _addLog('❌ Get Conversations test failed: ${result['message']}');
      }
    } catch (e) {
      _updateTestResult('Get Conversations', false);
      _addLog('❌ Get Conversations test error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testGetPrescriptions() async {
    setState(() {
      _isLoading = true;
      _currentTest = 'Get Prescriptions';
    });

    try {
      final result = await ApiService.getPrescriptions(
        page: 1,
        limit: 5,
      );
      
      final success = result['success'] == true;
      _updateTestResult('Get Prescriptions', success);
      _updateResponse(JsonEncoder.withIndent('  ').convert(result));
      
      if (success) {
        _addLog('✅ Get Prescriptions test passed');
      } else {
        _addLog('❌ Get Prescriptions test failed: ${result['message']}');
      }
    } catch (e) {
      _updateTestResult('Get Prescriptions', false);
      _addLog('❌ Get Prescriptions test error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _runAllTests() async {
    setState(() {
      _testResults.clear();
      _testLogs.clear();
      _isLoading = true;
    });

    _addLog('🚀 Starting comprehensive backend tests...');

    // Test sequence
    await _testRegistration();
    await Future.delayed(const Duration(seconds: 1));
    
    await _testLogin();
    await Future.delayed(const Duration(seconds: 1));
    
    await _testGetProfile();
    await Future.delayed(const Duration(seconds: 1));
    
    await _testGetHospitals();
    await Future.delayed(const Duration(seconds: 1));
    
    await _testGetDoctors();
    await Future.delayed(const Duration(seconds: 1));
    
    await _testGetAppointments();
    await Future.delayed(const Duration(seconds: 1));
    
    await _testGetConversations();
    await Future.delayed(const Duration(seconds: 1));
    
    await _testGetPrescriptions();
    await Future.delayed(const Duration(seconds: 1));

    // Summary
    final passedTests = _testResults.values.where((result) => result).length;
    final totalTests = _testResults.length;
    
    _addLog('📊 Test Summary: $passedTests/$totalTests tests passed');
    
    if (passedTests == totalTests) {
      _addLog('🎉 All tests passed! Backend is working correctly.');
    } else {
      _addLog('⚠️ Some tests failed. Check the response details above.');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend API Testing'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.wifi : Icons.wifi_off),
            onPressed: _checkConnection,
            tooltip: _isConnected ? 'Connected' : 'Disconnected',
          ),
        ],
      ),
      body: Row(
        children: [
          // Left panel - Test controls
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Connection status
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isConnected ? Icons.check_circle : Icons.error,
                                color: _isConnected ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isConnected ? 'Connected' : 'Disconnected',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _isConnected ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Backend: ${ApiService.baseUrl}'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Login form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Test Credentials',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Test buttons
                  const Text(
                    'Individual Tests',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  
                  ElevatedButton(
                    onPressed: _isLoading ? null : _testRegistration,
                    child: const Text('Test Registration'),
                  ),
                  const SizedBox(height: 4),
                  
                  ElevatedButton(
                    onPressed: _isLoading ? null : _testLogin,
                    child: const Text('Test Login'),
                  ),
                  const SizedBox(height: 4),
                  
                  ElevatedButton(
                    onPressed: _isLoading ? null : _testGetProfile,
                    child: const Text('Test Get Profile'),
                  ),
                  const SizedBox(height: 4),
                  
                  ElevatedButton(
                    onPressed: _isLoading ? null : _testGetHospitals,
                    child: const Text('Test Get Hospitals'),
                  ),
                  const SizedBox(height: 4),
                  
                  ElevatedButton(
                    onPressed: _isLoading ? null : _testGetDoctors,
                    child: const Text('Test Get Doctors'),
                  ),
                  const SizedBox(height: 4),
                  
                  ElevatedButton(
                    onPressed: _isLoading ? null : _testGetAppointments,
                    child: const Text('Test Get Appointments'),
                  ),
                  const SizedBox(height: 4),
                  
                  ElevatedButton(
                    onPressed: _isLoading ? null : _testGetConversations,
                    child: const Text('Test Get Conversations'),
                  ),
                  const SizedBox(height: 4),
                  
                  ElevatedButton(
                    onPressed: _isLoading ? null : _testGetPrescriptions,
                    child: const Text('Test Get Prescriptions'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Run all tests
                  ElevatedButton(
                    onPressed: _isLoading ? null : _runAllTests,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Run All Tests'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Test results summary
                  if (_testResults.isNotEmpty) ...[
                    const Text(
                      'Test Results',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ...(_testResults.entries.map((entry) => Row(
                      children: [
                        Icon(
                          entry.value ? Icons.check_circle : Icons.error,
                          color: entry.value ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              color: entry.value ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ))),
                  ],
                ],
              ),
            ),
          ),
          
          // Right panel - Response and logs
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Current test indicator
                  if (_isLoading) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 16),
                            Text('Testing: $_currentTest'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Response viewer
                  const Text(
                    'API Response',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SingleChildScrollView(
                        child: TextField(
                          controller: _responseController,
                          maxLines: null,
                          readOnly: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'API response will appear here...',
                          ),
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Test logs
                  const Text(
                    'Test Logs',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey.shade50,
                      ),
                      child: ListView.builder(
                        itemCount: _testLogs.length,
                        itemBuilder: (context, index) {
                          final log = _testLogs[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              log,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _responseController.dispose();
    super.dispose();
  }
} 