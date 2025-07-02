# OpenStreetMap Integration in Medico App

## Overview
This document describes the OpenStreetMap integration implemented in the Medico app's hospital detail screen, providing users with interactive maps and directions functionality.

## Features Implemented

### 1. Interactive Hospital Map
- **Location**: Hospital detail screen (Overview tab)
- **Widget**: `HospitalMapWidget` in `lib/views/home/widgets/hospital_map_widget.dart`
- **Functionality**: 
  - Displays hospital location on an interactive map
  - Uses OpenStreetMap tiles for map rendering
  - Shows hospital marker with custom styling
  - Displays hospital name and location info overlay

### 2. Get Directions Button
- **Location**: Floating action button on the map
- **Functionality**:
  - Opens directions in external browser
  - Primary: OpenStreetMap directions
  - Fallback: Google Maps directions
  - Handles errors gracefully with user feedback

### 3. Enhanced Hospital Cards
- **Location**: Home screen hospital cards
- **New Features**:
  - "Details" button to view hospital information
  - "Map" button to quickly access hospital detail screen with map

## Technical Implementation

### Dependencies Added
```yaml
dependencies:
  flutter_map: ^6.1.0      # OpenStreetMap integration
  url_launcher: ^6.2.1      # URL launching for directions
  latlong2: ^0.9.0         # Latitude/Longitude utilities
```

### Model Updates
- **Hospital Model**: Added `latitude` and `longitude` fields
- **Sample Data**: Updated with real coordinates for New York hospitals

### Permissions
- **Android**: Added internet and location permissions
- **iOS**: Added location usage descriptions

### Key Components

#### HospitalMapWidget
```dart
class HospitalMapWidget extends StatelessWidget {
  final Hospital hospital;
  final double height;
  
  // Features:
  // - Interactive map with OpenStreetMap tiles
  // - Custom hospital marker
  // - Location info overlay
  // - Get directions button
}
```

#### Map Features
- **Zoom Levels**: 10-18 (street level to building level)
- **Default Zoom**: 15 (neighborhood level)
- **Marker**: Custom hospital icon with name label
- **Tiles**: OpenStreetMap standard tiles

#### Directions Integration
- **Primary**: OpenStreetMap directions
- **Fallback**: Google Maps directions
- **Error Handling**: User-friendly error messages
- **External Launch**: Opens in default browser

## Usage

### For Users
1. Navigate to any hospital detail screen
2. Scroll to the "Location" section in the Overview tab
3. View the interactive map showing hospital location
4. Tap "Get Directions" to open directions in browser
5. Use "Details" and "Map" buttons on hospital cards for quick access

### For Developers
1. Ensure hospital data includes latitude and longitude coordinates
2. The map widget automatically handles missing coordinates with defaults
3. Customize map styling by modifying the `HospitalMapWidget`
4. Add more map features by extending the `FlutterMap` configuration

## Configuration

### Map Styling
- **Marker Color**: Uses app's primary color (`AppColors.primary`)
- **Map Height**: Configurable (default: 300px)
- **Border Radius**: 16px for modern rounded appearance
- **Shadow**: Subtle shadow for depth

### URL Configuration
- **OpenStreetMap**: `https://www.openstreetmap.org/directions?from=&to={lat},{lng}`
- **Google Maps**: `https://www.google.com/maps/dir/?api=1&destination={lat},{lng}`

## Future Enhancements
1. **User Location**: Add current user location to map
2. **Route Display**: Show route from user to hospital on map
3. **Multiple Hospitals**: Display multiple hospitals on single map
4. **Custom Markers**: Different markers for different hospital types
5. **Offline Maps**: Cache map tiles for offline usage
6. **Navigation**: In-app navigation integration

## Troubleshooting

### Common Issues
1. **Map not loading**: Check internet connection and permissions
2. **Directions not opening**: Verify URL launcher permissions
3. **Coordinates missing**: Ensure hospital data includes lat/lng

### Debug Tips
- Check console for map tile loading errors
- Verify coordinates are valid (between -90 to 90 for lat, -180 to 180 for lng)
- Test URL launching with different browsers

## Dependencies
- **flutter_map**: Provides the map widget and tile layer functionality
- **url_launcher**: Handles opening external URLs for directions
- **latlong2**: Provides latitude/longitude data structures

## Permissions Required
- **Internet**: For loading map tiles and opening directions
- **Location**: For potential future user location features 