# Order API Troubleshooting Guide

## Quick Diagnostic

1. **Open the Order API Diagnostic Screen**
   - Navigate to the app drawer (hamburger menu)
   - Tap "Order API Diagnostic"
   - This will run comprehensive tests and show you exactly what's wrong

## Common Issues and Solutions

### 1. 🔴 Authentication Issues

**Symptoms:**
- "User is not authenticated" error
- 401 Unauthorized responses
- JWT token missing or invalid

**Solutions:**
```dart
// Check if user is logged in
final token = AuthService.accessToken;
if (token == null) {
  // Redirect to login screen
  Navigator.pushNamed(context, '/login');
}
```

**Fix Steps:**
1. Log out and log back in
2. Check if the JWT token is being saved properly
3. Verify the token hasn't expired

### 2. 🔴 Network Connectivity Issues

**Symptoms:**
- "Backend server not available" error
- Connection timeout
- No response from API

**Solutions:**
```dart
// Test basic connectivity
final response = await http.get(
  Uri.parse('${AppConfig.apiBaseUrl}/health'),
  headers: {'Content-Type': 'application/json'},
).timeout(const Duration(seconds: 5));
```

**Fix Steps:**
1. Check your internet connection
2. Verify the API base URL: `https://medu.orbsdio.com/api`
3. Try accessing the API endpoint in a browser
4. Check if the server is running

### 3. 🔴 API Endpoint Issues

**Symptoms:**
- 404 Not Found errors
- "Orders endpoint is not accessible"
- Endpoint doesn't exist

**Solutions:**
```dart
// Verify the correct endpoint
const String ordersEndpoint = '/orders';
final response = await dio.get(ordersEndpoint, options: _authHeader);
```

**Fix Steps:**
1. Check if the `/orders` endpoint exists on your backend
2. Verify the API version (v1, v2, etc.)
3. Check API documentation for correct endpoints

### 4. 🔴 Request Format Issues

**Symptoms:**
- 400 Bad Request errors
- "Invalid request format"
- Missing required fields

**Solutions:**
```dart
// Ensure all required fields are present
final orderData = {
  'serviceProviderId': 'required',
  'serviceProviderName': 'required',
  'items': [
    {
      'serviceId': 'required',
      'serviceName': 'required',
      'quantity': 1,
      'price': 100.0,
    }
  ],
  'subtotal': 100.0,
  'total': 100.0,
  'currency': 'INR',
};
```

**Fix Steps:**
1. Check the required fields in your order model
2. Ensure all required data is being sent
3. Validate the data format before sending

### 5. 🔴 Response Parsing Issues

**Symptoms:**
- JSON parsing errors
- "Invalid response format"
- Missing expected fields

**Solutions:**
```dart
// Add proper error handling
try {
  if (response.data['success']) {
    return (response.data['data'] as List)
        .map((json) => Order.fromJson(json))
        .toList();
  } else {
    throw Exception(response.data['message']);
  }
} catch (e) {
  print('Error parsing response: $e');
  rethrow;
}
```

## Debug Steps

### Step 1: Check Console Logs
Look for these debug messages in your console:
```
🔍 Fetching orders with status: null, page: 1, limit: 10
🔑 Using JWT token: Present
📥 Orders API response status: 200
📦 Orders API response data: {...}
```

### Step 2: Test Individual Components
1. **Test Authentication:**
   ```dart
   final token = AuthService.accessToken;
   print('Token: ${token?.substring(0, 20)}...');
   ```

2. **Test Network:**
   ```dart
   final response = await http.get(Uri.parse('${AppConfig.apiBaseUrl}/health'));
   print('Health check: ${response.statusCode}');
   ```

3. **Test Orders Endpoint:**
   ```dart
   final response = await dio.get('/orders', options: _authHeader);
   print('Orders endpoint: ${response.statusCode}');
   ```

### Step 3: Use the Diagnostic Tool
The Order API Diagnostic screen will:
- Test basic connectivity
- Verify authentication
- Check orders endpoint availability
- Test create order functionality
- Provide specific recommendations

## API Configuration

### Current Configuration
```dart
// lib/core/config.dart
class AppConfig {
  static const String apiBaseUrl = 'https://medu.orbsdio.com/api';
}
```

### Order Service Configuration
```dart
// lib/core/services/order_service.dart
class OrderService {
  final Dio dio;
  final String jwtToken;
  
  Options get _authHeader =>
      Options(headers: {'Authorization': 'Bearer $jwtToken'});
}
```

## Testing the Fix

After implementing fixes:

1. **Run the diagnostic tool again**
2. **Check console logs for success messages**
3. **Test creating a new order**
4. **Verify orders are loading properly**

## Common Error Messages and Solutions

| Error Message | Likely Cause | Solution |
|---------------|---------------|----------|
| "User is not authenticated" | Missing JWT token | Log in again |
| "Backend server not available" | Network/Server issue | Check connectivity |
| "Orders endpoint is not accessible" | API endpoint missing | Verify backend implementation |
| "Invalid request format" | Missing required fields | Check order data structure |
| "JSON parsing error" | Invalid response format | Check backend response format |

## Getting Help

If the diagnostic tool shows issues that you can't resolve:

1. **Check the console logs** for detailed error information
2. **Use the diagnostic screen** to identify the specific problem
3. **Verify your backend API** is running and accessible
4. **Check API documentation** for correct endpoints and formats

## Quick Fix Checklist

- [ ] User is logged in with valid JWT token
- [ ] Internet connection is working
- [ ] API server is running and accessible
- [ ] `/orders` endpoint exists on backend
- [ ] Request format matches backend expectations
- [ ] Response format matches frontend expectations
- [ ] All required fields are included in requests
- [ ] Error handling is properly implemented

Run the Order API Diagnostic tool to automatically check all these items! 