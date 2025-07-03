import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/medicine.dart';
import '../models/medicine_reminder.dart';

class MedicineReminderViewModel extends BaseViewModel {
  List<Medicine> _medicines = [];
  List<MedicineReminder> _reminders = [];
  List<MedicineReminder> _todayReminders = [];
  List<MedicineReminder> _upcomingReminders = [];
  List<MedicineReminder> _overdueReminders = [];

  List<Medicine> get medicines => _medicines;
  List<MedicineReminder> get reminders => _reminders;
  List<MedicineReminder> get todayReminders => _todayReminders;
  List<MedicineReminder> get upcomingReminders => _upcomingReminders;
  List<MedicineReminder> get overdueReminders => _overdueReminders;

  // Filter properties
  String _searchQuery = '';
  ReminderStatus? _statusFilter;
  bool _showOnlyActive = true;

  String get searchQuery => _searchQuery;
  ReminderStatus? get statusFilter => _statusFilter;
  bool get showOnlyActive => _showOnlyActive;

  // Statistics
  int get totalActiveReminders => _reminders
      .where((r) => r.isActive && r.status == ReminderStatus.active)
      .length;
  int get completedTodayCount =>
      _todayReminders.where((r) => r.status == ReminderStatus.completed).length;
  int get pendingTodayCount =>
      _todayReminders.where((r) => r.status == ReminderStatus.active).length;
  int get overdueCount => _overdueReminders.length;
  int get medicinesNeedingRefill =>
      _medicines.where((m) => m.needsRefill).length;
  int get expiredMedicines => _medicines.where((m) => m.isExpired).length;

  // Initialize with sample data
  void initializeData() {
    _loadSampleMedicines();
    _loadSampleReminders();
    _updateReminderLists();
    notifyListeners();
  }

  void _loadSampleMedicines() {
    _medicines = [
      Medicine(
        id: '1',
        name: 'Paracetamol',
        dosage: '500mg',
        medicineType: 'Tablet',
        manufacturer: 'GSK',
        expiryDate: DateTime.now().add(const Duration(days: 365)),
        totalQuantity: 30,
        remainingQuantity: 25,
        notes: 'For fever and pain relief',
      ),
      Medicine(
        id: '2',
        name: 'Vitamin D3',
        dosage: '1000 IU',
        medicineType: 'Capsule',
        manufacturer: 'Nature Made',
        expiryDate: DateTime.now().add(const Duration(days: 800)),
        totalQuantity: 60,
        remainingQuantity: 15,
        notes: 'Daily vitamin supplement',
      ),
      Medicine(
        id: '3',
        name: 'Omega-3',
        dosage: '1000mg',
        medicineType: 'Softgel',
        manufacturer: 'Nordic Naturals',
        expiryDate: DateTime.now().add(const Duration(days: 500)),
        totalQuantity: 90,
        remainingQuantity: 8,
        notes: 'Fish oil supplement',
      ),
      Medicine(
        id: '4',
        name: 'Metformin',
        dosage: '500mg',
        medicineType: 'Tablet',
        manufacturer: 'Teva',
        expiryDate: DateTime.now().add(const Duration(days: 200)),
        totalQuantity: 100,
        remainingQuantity: 45,
        notes: 'For diabetes management',
      ),
    ];
  }

  void _loadSampleReminders() {
    final now = DateTime.now();
    final morning = DateTime(now.year, now.month, now.day, 8, 0);
    final evening = DateTime(now.year, now.month, now.day, 20, 0);
    final noon = DateTime(now.year, now.month, now.day, 12, 0);

    _reminders = [
      MedicineReminder(
        id: '1',
        medicineId: '1',
        medicine: _medicines.firstWhere((m) => m.id == '1'),
        reminderName: 'Paracetamol - Pain Relief',
        frequency: ReminderFrequency.asNeeded,
        dosesPerDay: 1,
        reminderTimes: [morning],
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 2)),
        totalDoses: 7,
        dosesCompleted: 4,
        instructions: 'Take with food if stomach upset occurs',
        takeWithFood: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
      ),
      MedicineReminder(
        id: '2',
        medicineId: '2',
        medicine: _medicines.firstWhere((m) => m.id == '2'),
        reminderName: 'Daily Vitamin D3',
        frequency: ReminderFrequency.daily,
        dosesPerDay: 1,
        reminderTimes: [morning],
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        totalDoses: 60,
        dosesCompleted: 28,
        instructions: 'Take with breakfast for better absorption',
        takeWithFood: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      MedicineReminder(
        id: '3',
        medicineId: '3',
        medicine: _medicines.firstWhere((m) => m.id == '3'),
        reminderName: 'Omega-3 Supplement',
        frequency: ReminderFrequency.daily,
        dosesPerDay: 1,
        reminderTimes: [evening],
        startDate: DateTime.now().subtract(const Duration(days: 20)),
        totalDoses: 30,
        dosesCompleted: 18,
        instructions: 'Take with dinner',
        takeWithFood: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
      ),
      MedicineReminder(
        id: '4',
        medicineId: '4',
        medicine: _medicines.firstWhere((m) => m.id == '4'),
        reminderName: 'Metformin - Twice Daily',
        frequency: ReminderFrequency.daily,
        dosesPerDay: 2,
        reminderTimes: [morning, evening],
        startDate: DateTime.now().subtract(const Duration(days: 60)),
        totalDoses: 120,
        dosesCompleted: 95,
        instructions: 'Take with meals to reduce stomach upset',
        takeWithFood: true,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  void _updateReminderLists() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    // Today's reminders
    _todayReminders = _reminders.where((reminder) {
      if (!reminder.isActive) return false;
      return reminder.reminderTimes.any((time) {
        final reminderToday = DateTime(
            today.year, today.month, today.day, time.hour, time.minute);
        return reminderToday.day == today.day &&
            reminderToday.month == today.month &&
            reminderToday.year == today.year;
      });
    }).toList();

    // Upcoming reminders (next 7 days)
    _upcomingReminders = _reminders.where((reminder) {
      if (!reminder.isActive) return false;
      final nextReminder = reminder.nextReminderTime;
      if (nextReminder == null) return false;
      return nextReminder.isAfter(tomorrow) &&
          nextReminder.isBefore(today.add(const Duration(days: 8)));
    }).toList();

    // Overdue reminders
    _overdueReminders = _reminders.where((reminder) {
      if (!reminder.isActive || reminder.status != ReminderStatus.active)
        return false;
      return reminder.reminderTimes.any((time) {
        final reminderToday = DateTime(
            today.year, today.month, today.day, time.hour, time.minute);
        return reminderToday.isBefore(now) &&
            now.difference(reminderToday).inHours > 1;
      });
    }).toList();
  }

  // Filter methods
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(ReminderStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void toggleShowOnlyActive() {
    _showOnlyActive = !_showOnlyActive;
    notifyListeners();
  }

  List<MedicineReminder> getFilteredReminders() {
    var filtered = List<MedicineReminder>.from(_reminders);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((reminder) {
        return reminder.reminderName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            reminder.medicine?.name
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ==
                true;
      }).toList();
    }

    // Apply status filter
    if (_statusFilter != null) {
      filtered = filtered
          .where((reminder) => reminder.status == _statusFilter)
          .toList();
    }

    // Apply active filter
    if (_showOnlyActive) {
      filtered = filtered.where((reminder) => reminder.isActive).toList();
    }

    return filtered;
  }

  // CRUD operations
  void addReminder(MedicineReminder reminder) {
    _reminders.add(reminder);
    _updateReminderLists();
    notifyListeners();
  }

  void updateReminder(MedicineReminder updatedReminder) {
    final index = _reminders.indexWhere((r) => r.id == updatedReminder.id);
    if (index != -1) {
      _reminders[index] = updatedReminder;
      _updateReminderLists();
      notifyListeners();
    }
  }

  void deleteReminder(String reminderId) {
    _reminders.removeWhere((r) => r.id == reminderId);
    _updateReminderLists();
    notifyListeners();
  }

  void markDoseTaken(String reminderId) {
    final index = _reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      final reminder = _reminders[index];
      _reminders[index] = reminder.copyWith(
        dosesCompleted: reminder.dosesCompleted + 1,
        status: reminder.isCompleted
            ? ReminderStatus.completed
            : ReminderStatus.active,
      );

      // Update medicine quantity
      final medicineIndex =
          _medicines.indexWhere((m) => m.id == reminder.medicineId);
      if (medicineIndex != -1) {
        final medicine = _medicines[medicineIndex];
        _medicines[medicineIndex] = medicine.copyWith(
          remainingQuantity: medicine.remainingQuantity - 1,
        );
      }

      _updateReminderLists();
      notifyListeners();
    }
  }

  void markDoseSkipped(String reminderId) {
    final index = _reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(
        status: ReminderStatus.skipped,
      );
      _updateReminderLists();
      notifyListeners();
    }
  }

  void pauseReminder(String reminderId) {
    final index = _reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(
        status: ReminderStatus.paused,
      );
      _updateReminderLists();
      notifyListeners();
    }
  }

  void resumeReminder(String reminderId) {
    final index = _reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(
        status: ReminderStatus.active,
      );
      _updateReminderLists();
      notifyListeners();
    }
  }

  // Medicine management
  void addMedicine(Medicine medicine) {
    _medicines.add(medicine);
    notifyListeners();
  }

  void updateMedicine(Medicine updatedMedicine) {
    final index = _medicines.indexWhere((m) => m.id == updatedMedicine.id);
    if (index != -1) {
      _medicines[index] = updatedMedicine;
      notifyListeners();
    }
  }

  void refillMedicine(String medicineId, int quantity) {
    final index = _medicines.indexWhere((m) => m.id == medicineId);
    if (index != -1) {
      final medicine = _medicines[index];
      _medicines[index] = medicine.copyWith(
        remainingQuantity: medicine.remainingQuantity + quantity,
        totalQuantity: medicine.totalQuantity + quantity,
      );
      notifyListeners();
    }
  }

  // Utility methods
  String getTimeUntilNextReminder() {
    final activeReminders = _reminders
        .where((r) => r.isActive && r.status == ReminderStatus.active);
    if (activeReminders.isEmpty) return 'No active reminders';

    DateTime? nextReminder;
    for (final reminder in activeReminders) {
      final next = reminder.nextReminderTime;
      if (next != null &&
          (nextReminder == null || next.isBefore(nextReminder))) {
        nextReminder = next;
      }
    }

    if (nextReminder == null) return 'No upcoming reminders';

    final difference = nextReminder.difference(DateTime.now());
    if (difference.inDays > 0) {
      return 'In ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inHours > 0) {
      return 'In ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
    } else if (difference.inMinutes > 0) {
      return 'In ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'Now';
    }
  }

  double getOverallComplianceRate() {
    if (_reminders.isEmpty) return 0.0;

    final completedDoses =
        _reminders.fold(0, (sum, reminder) => sum + reminder.dosesCompleted);
    final totalExpectedDoses = _reminders.fold(0, (sum, reminder) {
      if (reminder.totalDoses != null) {
        return sum + reminder.totalDoses!;
      }
      // For ongoing reminders, calculate based on days since start
      final daysSinceStart =
          DateTime.now().difference(reminder.startDate).inDays + 1;
      return sum + (daysSinceStart * reminder.dosesPerDay);
    });

    if (totalExpectedDoses == 0) return 0.0;
    return (completedDoses / totalExpectedDoses) * 100;
  }

  Map<String, int> getMedicineTypeDistribution() {
    final distribution = <String, int>{};
    for (final medicine in _medicines) {
      distribution[medicine.medicineType] =
          (distribution[medicine.medicineType] ?? 0) + 1;
    }
    return distribution;
  }

  List<MedicineReminder> getRemindersForMedicine(String medicineId) {
    return _reminders.where((r) => r.medicineId == medicineId).toList();
  }

  // Initialize method called when view model is created
  void initialize() {
    initializeData();
  }
}
