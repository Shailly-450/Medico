import 'package:flutter/material.dart';
import '../models/family_member.dart';

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
} 