import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import 'package:flutter/services.dart';

class ProfileViewModel extends ChangeNotifier {
  Map<String, dynamic>? profileData;
  bool isLoading = false;
  String? error;
  int _avatarUpdateTimestamp = 0;
  
  int get avatarUpdateTimestamp => _avatarUpdateTimestamp;
  
  void refreshAvatar() {
    _avatarUpdateTimestamp = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
  }

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
    try {
      final result = await ApiService.uploadProfileAvatar(filePath);
      if (result['success'] == true) {
        // Update timestamp to force UI refresh
        _avatarUpdateTimestamp = DateTime.now().millisecondsSinceEpoch;
        // Clear image cache to force refresh
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();
        // Refresh profile data to get the updated avatar URL
        await fetchProfile();
        return result;
      } else {
        error = result['message'] ?? 'Failed to update avatar';
        isLoading = false;
        notifyListeners();
        return result;
      }
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Failed to update avatar: ${e.toString()}',
      };
    }
  }
} 