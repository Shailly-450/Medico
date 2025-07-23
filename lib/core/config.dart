class AppConfig {
  // Use 10.0.2.2 for Android emulator to access host machine
  static const String apiHost = '10.0.2.2';
  static const int apiPort = 3000; // Backend is running on port 3000
  static const String apiBaseUrl = 'http://$apiHost:$apiPort/api';
}
