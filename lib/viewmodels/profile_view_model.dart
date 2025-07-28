import 'package:flutter/material.dart';
import '../core/services/api_service.dart';

class ProfileViewModel extends ChangeNotifier {
  Map<String, dynamic>? profileData;
  bool isLoading = false;
  String? error;

  Future<void> fetchProfile() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final response = await ApiService.getProfile();
      if (response['success'] == true) {
        profileData = response['data'];
      } else {
        error = response['message'] ?? 'Failed to load profile';
      }
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final response = await ApiService.updateProfile(data);
      if (response['success'] == true) {
        profileData = response['data'];
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        error = response['message'] ?? 'Failed to update profile';
      }
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
    return false;
  }

  Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    isLoading = true;
    error = null;
    notifyListeners();
    final result = await ApiService.changePassword(oldPassword, newPassword);
    if (result['success'] == true) {
      // Optionally, you can refresh profile data here
    } else {
      error = result['message'] ?? 'Failed to change password';
    }
    isLoading = false;
    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>> updateProfileAvatar(String filePath) async {
    isLoading = true;
    error = null;
    notifyListeners();
    final result = await ApiService.uploadProfileAvatar(filePath);
    if (result['success'] == true) {
      // Optionally, update profileData with new avatar URL if needed
      await fetchProfile();
    } else {
      error = result['message'] ?? 'Failed to update avatar';
    }
    isLoading = false;
    notifyListeners();
    return result;
  }
} 