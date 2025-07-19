# Frontend Backend Testing Guide

## 🎯 Overview

This guide explains how to test your Medico backend from the Flutter frontend using the comprehensive testing suite we've created.

## 📁 Files Created

### 1. **API Service** (`lib/core/services/api_service.dart`)
- **Real backend connection** instead of mock data
- **Token management** (access and refresh tokens)
- **Error handling** and retry logic
- **All API endpoints** covered

### 2. **Testing Screens**
- **`lib/views/testing/testing_home_screen.dart`** - Main testing dashboard
- **`lib/views/testing/backend_testing_screen.dart`** - Comprehensive API testing
- **`lib/views/testing/testing_navigation_helper.dart`** - Easy navigation integration

## 🚀 Quick Start

### Step 1: Ensure Backend is Running
```bash
# In your backend directory
cd medico-backend
npm start
```

### Step 2: Add Testing to Your App

#### Option A: Add to Main Navigation
```dart
// In your main.dart or navigation file
import 'views/testing/testing_navigation_helper.dart';

// Add to your drawer or menu
TestingNavigationHelper.buildTestingMenuItem(context)
```

#### Option B: Add as Floating Action Button
```dart
// In any screen
import 'views/testing/testing_navigation_helper.dart';

// Add to your Scaffold
floatingActionButton: TestingNavigationHelper.buildTestingButton(context)
```

#### Option C: Add to App Bar
```dart
// In your AppBar actions
actions: TestingNavigationHelper.buildTestingActions(context)
```

### Step 3: Run Tests
1. **Open the testing screen** from your app
2. **Check connection status** (should show "Connected")
3. **Run individual tests** or **"Run All Tests"**
4. **Review results** in the response viewer and logs

## 🧪 Testing Features

### **Connection Testing**
- ✅ **Health check** to verify backend connectivity
- ✅ **Real-time status** indicator
- ✅ **Automatic reconnection** handling

### **Authentication Testing**
- ✅ **User registration** with validation
- ✅ **Login/logout** functionality
- ✅ **Token management** (access and refresh)
- ✅ **Profile management** (get/update)

### **API Endpoint Testing**
- ✅ **Hospitals** - Search, filter, details
- ✅ **Doctors** - Search, filter, details
- ✅ **Appointments** - CRUD operations
- ✅ **Chat/Messaging** - Conversations and messages
- ✅ **Prescriptions** - CRUD operations

### **Response Validation**
- ✅ **Status code checking**
- ✅ **Response structure validation**
- ✅ **Error handling** and display
- ✅ **Real-time logging**

## 📱 How to Use the Testing Screen

### **Left Panel - Controls**
1. **Connection Status** - Shows if backend is reachable
2. **Test Credentials** - Enter custom login details
3. **Individual Tests** - Test specific endpoints
4. **Run All Tests** - Comprehensive test suite
5. **Test Results** - Visual pass/fail indicators

### **Right Panel - Results**
1. **API Response** - Full JSON response from backend
2. **Test Logs** - Timestamped test execution logs
3. **Current Test** - Shows which test is running

### **Test Workflow**
1. **Start with "Test Registration"** to create a test user
2. **Run "Test Login"** to authenticate
3. **Test other endpoints** in any order
4. **Use "Run All Tests"** for comprehensive testing

## 🔧 Configuration

### **Backend URL**
The API service is configured to connect to:
```dart
static const String baseUrl = 'http://localhost:3000/api';
```

### **For Different Environments**
Update the base URL in `api_service.dart`:
```dart
// Development
static const String baseUrl = 'http://localhost:3000/api';

// Production
static const String baseUrl = 'https://your-production-api.com/api';

// Staging
static const String baseUrl = 'https://your-staging-api.com/api';
```

### **Timeout Settings**
```dart
static const Duration timeout = Duration(seconds: 30);
```

## 📊 Test Results Interpretation

### **Success Indicators**
- ✅ **Green checkmarks** in test results
- ✅ **"Test passed"** messages in logs
- ✅ **Valid JSON responses** in response viewer
- ✅ **Success: true** in response data

### **Failure Indicators**
- ❌ **Red X marks** in test results
- ❌ **"Test failed"** messages in logs
- ❌ **Error messages** in response data
- ❌ **Connection refused** errors

### **Common Issues**

#### **Connection Failed**
```
❌ Backend connection failed
```
**Solution**: Ensure backend server is running on localhost:3000

#### **Authentication Failed**
```
❌ Login test failed: Invalid email or password
```
**Solution**: Check credentials or register a new user first

#### **Token Expired**
```
❌ Get Profile test failed: Unauthorized
```
**Solution**: Re-run login test to get fresh tokens

#### **Validation Errors**
```
❌ Registration test failed: Validation failed
```
**Solution**: Check required fields in registration data

## 🎯 Testing Scenarios

### **Scenario 1: New User Testing**
1. Run "Test Registration" to create account
2. Run "Test Login" to authenticate
3. Run "Test Get Profile" to verify user data
4. Test other endpoints as needed

### **Scenario 2: Existing User Testing**
1. Enter credentials in test form
2. Run "Test Login" to authenticate
3. Run all other tests to verify functionality

### **Scenario 3: Comprehensive Testing**
1. Click "Run All Tests" for full test suite
2. Review all results and logs
3. Check for any failed tests
4. Investigate failures in response viewer

## 🔍 Debugging

### **Enable Debug Mode**
Add debug prints to see detailed information:
```dart
// In api_service.dart
print('Request URL: $url');
print('Request Headers: $headers');
print('Request Body: $body');
print('Response Status: ${response.statusCode}');
print('Response Body: ${response.body}');
```

### **Check Network Tab**
Use Flutter Inspector or browser dev tools to see:
- **Request URLs**
- **Request headers**
- **Request bodies**
- **Response status codes**
- **Response bodies**

### **Common Debug Steps**
1. **Check backend logs** for server-side errors
2. **Verify API endpoints** match backend routes
3. **Check authentication** tokens are valid
4. **Validate request format** matches API schema
5. **Test with Postman** to isolate frontend issues

## 🚀 Advanced Testing

### **Custom Test Data**
Modify test data in the testing screen:
```dart
// In backend_testing_screen.dart
final result = await ApiService.register({
  'firstName': 'Custom',
  'lastName': 'User',
  'email': 'custom@example.com',
  'password': 'CustomPassword123!',
  // ... other fields
});
```

### **Add New Tests**
Create new test methods:
```dart
Future<void> _testCustomEndpoint() async {
  setState(() {
    _isLoading = true;
    _currentTest = 'Custom Test';
  });

  try {
    final result = await ApiService.customMethod();
    final success = result['success'] == true;
    _updateTestResult('Custom Test', success);
    _updateResponse(JsonEncoder.withIndent('  ').convert(result));
    
    if (success) {
      _addLog('✅ Custom test passed');
    } else {
      _addLog('❌ Custom test failed: ${result['message']}');
    }
  } catch (e) {
    _updateTestResult('Custom Test', false);
    _addLog('❌ Custom test error: $e');
  } finally {
    setState(() => _isLoading = false);
  }
}
```

### **Performance Testing**
Add timing to tests:
```dart
final stopwatch = Stopwatch()..start();
final result = await ApiService.getHospitals();
stopwatch.stop();

_addLog('⏱️ Request took: ${stopwatch.elapsedMilliseconds}ms');
```

## 📈 Best Practices

### **Testing Order**
1. **Start with authentication** (register/login)
2. **Test read operations** (get hospitals, doctors)
3. **Test write operations** (create appointments, messages)
4. **Test update operations** (update profile, appointments)
5. **Test delete operations** (cancel appointments)

### **Data Management**
- **Use unique test data** to avoid conflicts
- **Clean up test data** after testing
- **Don't test with production data**
- **Use test-specific credentials**

### **Error Handling**
- **Always check for errors** in responses
- **Handle network timeouts** gracefully
- **Validate response structure** before using data
- **Log errors** for debugging

## 🔄 Integration with CI/CD

### **Automated Testing**
You can integrate the testing screen into your CI/CD pipeline:

1. **Create test scripts** that run the Flutter app
2. **Automate test execution** using Flutter Driver
3. **Parse test results** for pass/fail reporting
4. **Generate test reports** for stakeholders

### **Example CI Script**
```yaml
# .github/workflows/flutter_test.yml
name: Flutter Backend Testing
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test integration_test/backend_test.dart
```

## 🎉 Benefits

### **For Development**
- **Rapid API testing** during development
- **Real-time feedback** on backend changes
- **Easy debugging** of API issues
- **Visual confirmation** of functionality

### **For Quality Assurance**
- **Comprehensive test coverage**
- **Consistent testing approach**
- **Easy to maintain** and update
- **Clear pass/fail indicators**

### **For Deployment**
- **Pre-deployment validation**
- **Environment testing**
- **Regression testing**
- **Performance monitoring**

## 🆘 Troubleshooting

### **Backend Not Responding**
1. Check if backend server is running
2. Verify port 3000 is not blocked
3. Check firewall settings
4. Try accessing API directly in browser

### **Authentication Issues**
1. Clear stored tokens
2. Re-register test user
3. Check backend authentication logic
4. Verify JWT token format

### **CORS Issues**
1. Check backend CORS configuration
2. Verify request headers
3. Test with Postman first
4. Check browser console for errors

### **Data Issues**
1. Check database connection
2. Verify API response format
3. Check validation rules
4. Test with known good data

## 📞 Support

If you encounter issues:

1. **Check this guide** for common solutions
2. **Review backend logs** for server errors
3. **Test with Postman** to isolate issues
4. **Check Flutter console** for client errors
5. **Verify network connectivity** and firewall settings

---

**Happy Testing! 🚀**

Your Flutter app now has comprehensive backend testing capabilities that will help ensure your Medico application is robust and reliable. 