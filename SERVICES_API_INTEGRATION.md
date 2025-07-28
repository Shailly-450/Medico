# Services API Integration for Comparison Feature

## Overview

This document outlines the integration of the services API endpoints into the Medico Flutter app's comparison feature. The integration allows the comparison screen to display real service data from the backend instead of hardcoded dummy data.

## API Endpoints

### 1. Services API
- **Endpoint**: `GET {{baseUrl}}/services`
- **Purpose**: Fetch all available medical services
- **Response**: Array of service objects with full details

### 2. Categories API
- **Endpoint**: `GET {{baseUrl}}/services/categories`
- **Purpose**: Fetch available service categories
- **Response**: Array of category strings

## Files Modified/Created

### 1. New Files Created

#### `lib/core/services/services_api_service.dart`
- **Purpose**: Handles all API calls to the services endpoints
- **Key Methods**:
  - `fetchServices()`: Gets all services from API
  - `fetchCategories()`: Gets available service categories from dedicated API
  - `fetchServicesByCategory()`: Filters services by category
  - `fetchServicesWithFilters()`: Advanced filtering with multiple criteria
  - `searchServices()`: Searches services by name/description
  - `fetchServiceById()`: Gets a specific service by ID

#### `lib/views/testing/services_api_test_screen.dart`
- **Purpose**: Test screen to verify API integration
- **Features**:
  - Tests both services and categories APIs
  - Displays loaded services and categories
  - Shows API response status and timing
  - Allows manual refresh
  - Error handling and retry functionality

### 2. Modified Files

#### `lib/models/medical_service.dart`
- **Updates**: Extended to handle new API response structure
- **New Fields**:
  - `subcategory`, `isActive`, `requiresPrescription`, `requiresAppointment`
  - `preparationInstructions`, `postServiceInstructions`
  - `risks`, `contraindications`, `tags`
  - `provider`, `location`, `insuranceCoverage`, `insuranceCodes`
  - `createdAt`, `updatedAt`
- **Helper Methods**: Added display methods for UI consistency

#### `lib/viewmodels/comparison_view_model.dart`
- **Updates**: Integrated with services API
- **Key Changes**:
  - `initialize()` now calls `_loadServicesFromApi()`
  - `_createSampleProviders()` creates providers from real service data
  - Fallback to sample data if API fails
  - Dynamic provider creation based on service providers

#### `lib/views/comparison/comparison_screen.dart`
- **Updates**: Enhanced UI to work with API data
- **New Features**:
  - Loading states and error handling
  - Dynamic service selection based on categories from API
  - Provider selection with real data
  - Comparison table with API-driven data

#### `lib/views/comparison/widgets/comparison_table.dart`
- **Updates**: Modified to work with real service data
- **Changes**:
  - Accepts `List<ServiceProvider>` instead of hardcoded data
  - Filters providers that offer selected service
  - Displays real service information
  - Enhanced contact dialog with provider details

#### `lib/main.dart`
- **Updates**: Added ComparisonViewModel provider
- **Changes**:
  - Added `ComparisonViewModel` to providers list
  - Added route for services API test screen

#### `lib/views/testing/testing_home_screen.dart`
- **Updates**: Added services API test option
- **Changes**:
  - New card for "Services API Testing"
  - Navigation to test screen
  - Updated instructions

## API Response Structures

### Services API Response
```json
{
  "success": true,
  "data": [
    {
      "_id": "6879d2c72cbb6a72b5fcb99b",
      "name": "Blood Pressure Monitoring",
      "description": "Regular blood pressure monitoring...",
      "category": "screening",
      "subcategory": "cardiovascular",
      "price": 35,
      "currency": "USD",
      "duration": 30,
      "isActive": true,
      "isAvailable": true,
      "requiresPrescription": false,
      "requiresAppointment": false,
      "preparationInstructions": "Avoid caffeine...",
      "postServiceInstructions": "Continue monitoring...",
      "risks": [],
      "contraindications": [],
      "tags": ["blood pressure", "monitoring"],
      "provider": "Medico Screening Center",
      "location": "Preventive Care Clinic",
      "insuranceCoverage": true,
      "insuranceCodes": [...],
      "rating": {"average": 0, "count": 0},
      "createdAt": "2025-07-18T04:51:19.536Z",
      "updatedAt": "2025-07-18T04:51:19.536Z"
    }
  ]
}
```

### Categories API Response
```json
{
  "success": true,
  "data": [
    "consultation",
    "emergency",
    "imaging",
    "laboratory_tests",
    "procedure",
    "screening",
    "therapy",
    "vaccination"
  ]
}
```

## How It Works

### 1. Data Flow
1. **App Startup**: `ComparisonViewModel` is initialized in `main.dart`
2. **Categories API Call**: `initialize()` calls `ServicesApiService.fetchCategories()`
3. **Services API Call**: Then calls `ServicesApiService.fetchServices()`
4. **Data Processing**: Services are grouped by provider
5. **Provider Creation**: Sample providers are created with real service data
6. **UI Update**: Comparison screen displays real data

### 2. Provider Creation Logic
- Services are grouped by their `provider` field
- Each provider gets:
  - Name from service provider field
  - Type determined by provider name analysis
  - Location from service location field
  - Services list from grouped services
  - Average price calculated from services
  - Facilities based on service categories

### 3. Error Handling
- **API Failure**: Falls back to sample data
- **Network Issues**: Shows error message with retry option
- **Empty Data**: Displays appropriate empty states

## Testing

### 1. Manual Testing
1. Navigate to Testing Dashboard
2. Select "Services API Testing"
3. Verify both services and categories load correctly
4. Check API response times and status
5. Test refresh functionality

### 2. Integration Testing
1. Navigate to Comparison Screen
2. Verify services load from API
3. Test category selection (should use categories from API)
4. Test service selection
5. Test provider comparison
6. Verify comparison table displays real data

## Configuration

### API Base URL
The API base URL is configured in `lib/core/config.dart`:
```dart
static const String apiBaseUrl = 'http://192.168.1.3:3000/api';
```

### Endpoints Used
- `GET /services` - Fetch all services
- `GET /services/categories` - Fetch service categories
- Both APIs are called via `ServicesApiService`

## Benefits

### 1. Real Data Integration
- Comparison screen now shows actual services from backend
- Categories are dynamically loaded from API
- No more hardcoded dummy data
- Dynamic service categories and providers

### 2. Scalability
- Easy to add new services via backend
- Easy to add new categories via backend
- Automatic provider creation from service data
- Flexible category and subcategory support

### 3. User Experience
- Real-time service information
- Accurate pricing and availability
- Proper insurance coverage information
- Detailed service descriptions
- Dynamic category filtering

### 4. Maintainability
- Centralized API service
- Proper error handling
- Test screen for debugging
- Clear separation of concerns
- Performance monitoring (response times)

## Advanced Features

### 1. Filtering Capabilities
The `fetchServicesWithFilters()` method supports:
- Category filtering
- Subcategory filtering
- Price range filtering
- Availability filtering
- Insurance coverage filtering

### 2. Performance Monitoring
- API response time tracking
- Success/failure status tracking
- Data count monitoring
- Real-time performance feedback

## Future Enhancements

### 1. Additional API Endpoints
- Provider-specific endpoints
- Service search and filtering
- Real-time availability updates
- Service recommendations

### 2. Caching
- Local caching of service data
- Local caching of category data
- Offline support
- Periodic data refresh

### 3. Advanced Features
- Service recommendations
- Price comparison analytics
- User reviews integration
- Booking integration
- Real-time availability

## Troubleshooting

### Common Issues

1. **API Connection Failed**
   - Check if backend server is running
   - Verify API base URL in config
   - Check network connectivity

2. **No Services Displayed**
   - Check API response format
   - Verify service data structure
   - Check console logs for errors

3. **No Categories Displayed**
   - Check categories API endpoint
   - Verify categories response format
   - Check console logs for errors

4. **Providers Not Created**
   - Verify service provider field is populated
   - Check provider grouping logic
   - Review sample data fallback

### Debug Steps

1. Use the Services API Test Screen
2. Check console logs for API responses
3. Verify network requests in browser dev tools
4. Test API endpoints directly with curl/Postman
5. Monitor API response times

## Conclusion

The services and categories API integration successfully transforms the comparison feature from using hardcoded data to displaying real service information from the backend. The implementation includes proper error handling, testing capabilities, performance monitoring, and maintains backward compatibility with sample data as a fallback.

The integration is production-ready and provides a solid foundation for future enhancements to the comparison feature, with support for both services and categories APIs. 