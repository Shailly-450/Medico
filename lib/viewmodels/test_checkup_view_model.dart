import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/test_checkup.dart';
import '../core/services/test_checkup_service.dart';

class TestCheckupViewModel extends BaseViewModel {
  final TestCheckupService _service = TestCheckupService();
  List<TestCheckup> _checkups = [];
  List<TestCheckup> _todayCheckups = [];
  List<TestCheckup> _upcomingCheckups = [];
  List<TestCheckup> _overdueCheckups = [];
  List<TestCheckup> _completedCheckups = [];
  Map<String, int> _counts = {};
  TestCheckupType? _selectedFilter;
  TestCheckupStatus? _statusFilter;
  String? _error;
  bool _isLoading = false;

  // Getters
  List<TestCheckup> get checkups => _checkups;
  List<TestCheckup> get todayCheckups => _todayCheckups;
  List<TestCheckup> get upcomingCheckups => _upcomingCheckups;
  List<TestCheckup> get overdueCheckups => _overdueCheckups;
  List<TestCheckup> get completedCheckups => _completedCheckups;
  TestCheckupType? get selectedFilter => _selectedFilter;
  TestCheckupStatus? get statusFilter => _statusFilter;
  String? get error => _error;
  bool get isLoading => _isLoading;
  Map<String, int> get counts => _counts;

  @override
  void init() {
    _loadCheckups();
  }

  Future<void> _loadCheckups() async {
    setBusy(true);
    try {
      final response = await _service.getCheckups();

      // Map upcoming checkups
      _upcomingCheckups = response.upcoming
          .map<TestCheckup>((json) => TestCheckup.fromJson(json))
          .toList();

      // Map overdue checkups
      _overdueCheckups = response.overdue
          .map<TestCheckup>((json) => TestCheckup.fromJson(json))
          .toList();

      // Map all checkups
      _checkups = response.checkups
          .map<TestCheckup>((json) => TestCheckup.fromJson(json))
          .toList();

      // Store counts
      _counts = response.counts;

      // Update today's checkups
      _todayCheckups = [
        ..._upcomingCheckups.where((c) => c.isToday),
        ..._overdueCheckups.where((c) => c.isToday),
      ];

      // Update completed checkups
      _completedCheckups = _checkups
          .where((c) => c.status == TestCheckupStatus.completed)
          .toList();

      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setBusy(false);
    }
  }

  void _updateCheckupLists() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Today's checkups
    _todayCheckups = _checkups.where((checkup) {
      return checkup.isToday && checkup.status != TestCheckupStatus.completed;
    }).toList();

    // Upcoming checkups (next 7 days)
    _upcomingCheckups = _checkups.where((checkup) {
      return checkup.isUpcoming &&
          checkup.status != TestCheckupStatus.completed;
    }).toList();

    // Overdue checkups
    _overdueCheckups = _checkups.where((checkup) {
      return checkup.isOverdue && checkup.status != TestCheckupStatus.completed;
    }).toList();

    // Completed checkups
    _completedCheckups = _checkups.where((checkup) {
      return checkup.status == TestCheckupStatus.completed;
    }).toList();
  }

  // Filter checkups by type
  void filterByType(TestCheckupType? type) {
    _selectedFilter = type;
    notifyListeners();
  }

  // Filter checkups by status
  void filterByStatus(TestCheckupStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  // Get filtered checkups
  List<TestCheckup> getFilteredCheckups() {
    List<TestCheckup> filtered = _checkups;

    if (_selectedFilter != null) {
      filtered = filtered
          .where((checkup) => checkup.type == _selectedFilter)
          .toList();
    }

    if (_statusFilter != null) {
      filtered = filtered
          .where((checkup) => checkup.status == _statusFilter)
          .toList();
    }

    return filtered;
  }

  // Add new checkup
  Future<void> addCheckup(TestCheckup checkup) async {
    setBusy(true);
    _checkups.add(checkup);
    _updateCheckupLists();
    setBusy(false);
    notifyListeners();
  }

  // Update checkup
  Future<void> updateCheckup(TestCheckup checkup) async {
    setBusy(true);
    final index = _checkups.indexWhere((c) => c.id == checkup.id);
    if (index != -1) {
      _checkups[index] = checkup;
      _updateCheckupLists();
    }
    setBusy(false);
    notifyListeners();
  }

  // Delete checkup
  Future<void> deleteCheckup(String id) async {
    setBusy(true);
    _checkups.removeWhere((checkup) => checkup.id == id);
    _updateCheckupLists();
    setBusy(false);
    notifyListeners();
  }

  // Mark checkup as completed
  Future<void> markAsCompleted(String id, {String? results}) async {
    setBusy(true);
    final index = _checkups.indexWhere((c) => c.id == id);
    if (index != -1) {
      final checkup = _checkups[index];
      _checkups[index] = checkup.copyWith(
        status: TestCheckupStatus.completed,
        completedDate: DateTime.now(),
        results: results,
        updatedAt: DateTime.now(),
      );
      _updateCheckupLists();
    }
    setBusy(false);
    notifyListeners();
  }

  // Cancel checkup
  Future<void> cancelCheckup(String id) async {
    setBusy(true);
    final index = _checkups.indexWhere((c) => c.id == id);
    if (index != -1) {
      final checkup = _checkups[index];
      _checkups[index] = checkup.copyWith(
        status: TestCheckupStatus.cancelled,
        updatedAt: DateTime.now(),
      );
      _updateCheckupLists();
    }
    setBusy(false);
    notifyListeners();
  }

  // Reschedule checkup
  Future<void> rescheduleCheckup(
    String id,
    DateTime newDate,
    TimeOfDay newTime,
  ) async {
    setBusy(true);
    final index = _checkups.indexWhere((c) => c.id == id);
    if (index != -1) {
      final checkup = _checkups[index];
      _checkups[index] = checkup.copyWith(
        status: TestCheckupStatus.rescheduled,
        scheduledDate: newDate,
        scheduledTime: newTime,
        updatedAt: DateTime.now(),
      );
      _updateCheckupLists();
    }
    setBusy(false);
    notifyListeners();
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final total = _checkups.length;
    final completed = _completedCheckups.length;
    final pending = _checkups
        .where((c) => c.status == TestCheckupStatus.scheduled)
        .length;
    final overdue = _overdueCheckups.length;
    final today = _todayCheckups.length;
    final upcoming = _upcomingCheckups.length;

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'overdue': overdue,
      'today': today,
      'upcoming': upcoming,
      'completionRate': total > 0 ? (completed / total * 100).round() : 0,
    };
  }

  // Get checkups by type
  Map<TestCheckupType, int> getCheckupsByType() {
    final Map<TestCheckupType, int> typeCount = {};
    for (final checkup in _checkups) {
      typeCount[checkup.type] = (typeCount[checkup.type] ?? 0) + 1;
    }
    return typeCount;
  }

  // Get checkups by priority
  Map<TestCheckupPriority, int> getCheckupsByPriority() {
    final Map<TestCheckupPriority, int> priorityCount = {};
    for (final checkup in _checkups) {
      priorityCount[checkup.priority] =
          (priorityCount[checkup.priority] ?? 0) + 1;
    }
    return priorityCount;
  }

  // Get total estimated cost
  double getTotalEstimatedCost() {
    return _checkups.fold(
      0.0,
      (sum, checkup) => sum + (checkup.estimatedCost ?? 0),
    );
  }

  // Get checkups requiring preparation
  List<TestCheckup> getCheckupsRequiringPreparation() {
    return _checkups
        .where(
          (checkup) =>
              checkup.requiresPreparation &&
              checkup.status == TestCheckupStatus.scheduled &&
              checkup.scheduledDate.isAfter(DateTime.now()),
        )
        .toList();
  }

  // Get checkups requiring fasting
  List<TestCheckup> getCheckupsRequiringFasting() {
    return _checkups
        .where(
          (checkup) =>
              checkup.requiresFasting &&
              checkup.status == TestCheckupStatus.scheduled &&
              checkup.scheduledDate.isAfter(DateTime.now()),
        )
        .toList();
  }

  // Clear filters
  void clearFilters() {
    _selectedFilter = null;
    _statusFilter = null;
    notifyListeners();
  }
}
