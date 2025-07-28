import 'package:flutter/material.dart';
import '../models/family_member.dart';
import '../core/services/api_service.dart';

class FamilyMembersViewModel extends ChangeNotifier {
  final List<FamilyMember> _members = [
    FamilyMember(
      id: '1',
      name: 'John Doe',
      role: 'Father',
      imageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
    ),
    FamilyMember(
      id: '2',
      name: 'Sara Doe',
      role: 'Mom',
      imageUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
    ),
    FamilyMember(
      id: '3',
      name: 'Jak Doe',
      role: 'First-child',
      imageUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
    ),
    FamilyMember(
      id: '4',
      name: 'Ben Doe',
      role: 'Second-child',
      imageUrl: 'https://randomuser.me/api/portraits/men/4.jpg',
    ),
  ];

  FamilyMember? _currentProfile;

  FamilyMembersViewModel() {
    if (_members.isNotEmpty) {
      _currentProfile = _members.first;
    }
  }

  List<FamilyMember> get members => List.unmodifiable(_members);
  FamilyMember? get currentProfile => _currentProfile;

  void addMember(FamilyMember member) {
    _members.add(member);
    notifyListeners();
  }

  void removeMember(String id) {
    _members.removeWhere((m) => m.id == id);
    // If the current profile was deleted, switch to first member if available
    if (_currentProfile != null && _currentProfile!.id == id) {
      _currentProfile = _members.isNotEmpty ? _members.first : null;
    }
    notifyListeners();
  }

  void updateMember(FamilyMember updated) {
    final idx = _members.indexWhere((m) => m.id == updated.id);
    if (idx != -1) {
      _members[idx] = updated;
      notifyListeners();
    }
  }

  void switchProfile(FamilyMember member) {
    _currentProfile = member;
    notifyListeners();
  }

  Future<Map<String, dynamic>> addFamilyMemberOnline(Map<String, dynamic> memberData) async {
    final result = await ApiService.addFamilyMember(memberData);
    if (result['success'] == true && result['data'] != null) {
      final data = result['data'];
      _members.add(FamilyMember(
        id: data['_id'] ?? '',
        name: data['name'] ?? '',
        role: data['role'] ?? '',
        imageUrl: '', // No image in response
      ));
      notifyListeners();
    }
    return result;
  }

  Future<Map<String, dynamic>> fetchFamilyMembersOnline() async {
    final result = await ApiService.getFamilyMembers();
    if (result['success'] == true && result['data'] is List) {
      _members.clear();
      for (final data in result['data']) {
        _members.add(FamilyMember(
          id: data['_id'] ?? '',
          name: data['name'] ?? '',
          role: data['role'] ?? '',
          imageUrl: '', // No image in response
        ));
      }
      notifyListeners();
    }
    return result;
  }

  Future<Map<String, dynamic>> updateFamilyMemberOnline(String familyMemberId, Map<String, dynamic> data) async {
    final result = await ApiService.updateFamilyMember(familyMemberId, data);
    if (result['success'] == true && result['data'] != null) {
      final updated = result['data'];
      final idx = _members.indexWhere((m) => m.id == (updated['_id'] ?? ''));
      if (idx != -1) {
        _members[idx] = FamilyMember(
          id: updated['_id'] ?? '',
          name: updated['name'] ?? '',
          role: updated['role'] ?? '',
          imageUrl: '', // No image in response
        );
        notifyListeners();
      }
    }
    return result;
  }

  Future<Map<String, dynamic>> deleteFamilyMemberOnline(String familyMemberId) async {
    final result = await ApiService.deleteFamilyMember(familyMemberId);
    if (result['success'] == true) {
      _members.removeWhere((m) => m.id == familyMemberId);
      notifyListeners();
    }
    return result;
  }
} 