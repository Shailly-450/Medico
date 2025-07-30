import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../core/services/medicine_reminder_service.dart';
import '../core/services/auth_service.dart';
import '../models/medicine.dart';
import '../models/medicine_reminder.dart';
import '../core/services/notification_sender_service.dart';
import '../models/notification_item.dart';

class MedicineReminderViewModel extends BaseViewModel {
  final MedicineReminderService _reminderService = MedicineReminderService();

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

  // Initialize with API data
  Future<void> initializeData() async {
    setBusy(true);
    setError(null);

    try {
      await _loadReminders();
      _loadSampleMedicines(); // Keep medicines as sample data for now
      _updateReminderLists();
      notifyListeners();
    } catch (e) {
      setError('Failed to load reminders: ${e.toString()}');
    } finally {
      setBusy(false);
    }
  }

  // Load reminders from API
  Future<void> _loadReminders() async {
    try {
      _reminders = await _reminderService.getReminders();
    } catch (e) {
      // If API fails, fall back to sample data
      _loadSampleReminders();
      throw e;
    }
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
        name: 'Ibuprofen',
        dosage: '400mg',
        medicineType: 'Tablet',
        manufacturer: 'Pfizer',
        expiryDate: DateTime.now().add(const Duration(days: 400)),
        totalQuantity: 20,
        remainingQuantity: 10,
        notes: 'For pain and inflammation',
      ),
      Medicine(
        id: '3',
        name: 'Amoxicillin',
        dosage: '250mg',
        medicineType: 'Capsule',
        manufacturer: 'Abbott',
        expiryDate: DateTime.now().add(const Duration(days: 200)),
        totalQuantity: 15,
        remainingQuantity: 8,
        notes: 'Antibiotic for infections',
      ),
      Medicine(
        id: '4',
        name: 'Cetirizine',
        dosage: '10mg',
        medicineType: 'Tablet',
        manufacturer: 'Dr. Reddy',
        expiryDate: DateTime.now().add(const Duration(days: 500)),
        totalQuantity: 25,
        remainingQuantity: 20,
        notes: 'For allergy relief',
      ),
      Medicine(
        id: '5',
        name: 'Metformin',
        dosage: '500mg',
        medicineType: 'Tablet',
        manufacturer: 'Teva',
        expiryDate: DateTime.now().add(const Duration(days: 200)),
        totalQuantity: 100,
        remainingQuantity: 45,
        notes: 'For diabetes management',
      ),
      Medicine(
        id: '6',
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
        id: '7',
        name: 'Omega-3',
        dosage: '1000mg',
        medicineType: 'Softgel',
        manufacturer: 'Nordic Naturals',
        expiryDate: DateTime.now().add(const Duration(days: 500)),
        totalQuantity: 90,
        remainingQuantity: 8,
        notes: 'Fish oil supplement',
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
        notificationSettings: NotificationSettings(
          email: NotificationChannelSettings(enabled: true, timeBeforeDose: 10),
          push: NotificationChannelSettings(enabled: true, timeBeforeDose: 10),
          sms: NotificationChannelSettings(enabled: false, timeBeforeDose: 10),
        ),
        reminderVibration: true,
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
        notificationSettings: NotificationSettings(
          email: NotificationChannelSettings(enabled: true, timeBeforeDose: 10),
          push: NotificationChannelSettings(enabled: true, timeBeforeDose: 10),
          sms: NotificationChannelSettings(enabled: false, timeBeforeDose: 10),
        ),
        reminderVibration: true,
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
        notificationSettings: NotificationSettings(
          email: NotificationChannelSettings(enabled: true, timeBeforeDose: 10),
          push: NotificationChannelSettings(enabled: true, timeBeforeDose: 10),
          sms: NotificationChannelSettings(enabled: false, timeBeforeDose: 10),
        ),
        reminderVibration: true,
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
        notificationSettings: NotificationSettings(
          email: NotificationChannelSettings(enabled: true, timeBeforeDose: 10),
          push: NotificationChannelSettings(enabled: true, timeBeforeDose: 10),
          sms: NotificationChannelSettings(enabled: false, timeBeforeDose: 10),
        ),
        reminderVibration: true,
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
          today.year,
          today.month,
          today.day,
          time.hour,
          time.minute,
        );
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
          today.year,
          today.month,
          today.day,
          time.hour,
          time.minute,
        );
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
        return reminder.reminderName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            reminder.medicine?.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ==
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
  Future<bool> addReminder(MedicineReminder reminder) async {
    setBusy(true);
    setError(null);

    try {
      final newReminder = await _reminderService.createReminder(
        medicineId: reminder.medicineId,
        reminderName: reminder.reminderName,
        frequency: reminder.frequency,
        dosesPerDay: reminder.dosesPerDay,
        reminderTimes: reminder.reminderTimes,
        startDate: reminder.startDate,
        endDate: reminder.endDate,
        totalDoses: reminder.totalDoses,
        instructions: reminder.instructions,
        takeWithFood: reminder.takeWithFood,
        takeWithWater: reminder.takeWithWater,
        customFrequencyDescription: reminder.customFrequencyDescription,
        customIntervalDays: reminder.customIntervalDays,
        skipDays: reminder.skipDays,
        hasNotifications: reminder.hasNotifications,
        notificationSettings: reminder.notificationSettings,
        reminderVibration: reminder.reminderVibration,
      );

      _reminders.add(newReminder);
      _updateReminderLists();
      notifyListeners();
      // Send push notification if enabled
      if (newReminder.hasNotifications) {
        await NotificationSenderService.sendToUser(
          userId: AuthService.currentUserId ?? 'YOUR_USER_ID_HERE',
          title: 'Medicine Reminder',
          message: 'It\'s time to take your medicine: ${newReminder.reminderName} at ${newReminder.reminderTimes.isNotEmpty ? newReminder.reminderTimes.first.hour.toString().padLeft(2, '0') + ':' + newReminder.reminderTimes.first.minute.toString().padLeft(2, '0') : ''}',
          type: NotificationType.health_reminder,
          data: {
            'reminderId': newReminder.id,
            'medicineId': newReminder.medicineId,
          },
        );
      }
      return true;
    } catch (e) {
      setError('Failed to add reminder: ${e.toString()}');
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<bool> updateReminder(MedicineReminder updatedReminder) async {
    setBusy(true);
    setError(null);

    try {
      final updated = await _reminderService.updateReminder(
        updatedReminder.id,
        reminderName: updatedReminder.reminderName,
        frequency: updatedReminder.frequency,
        dosesPerDay: updatedReminder.dosesPerDay,
        reminderTimes: updatedReminder.reminderTimes,
        startDate: updatedReminder.startDate,
        endDate: updatedReminder.endDate,
        totalDoses: updatedReminder.totalDoses,
        dosesCompleted: updatedReminder.dosesCompleted,
        isActive: updatedReminder.isActive,
        status: updatedReminder.status,
        instructions: updatedReminder.instructions,
        takeWithFood: updatedReminder.takeWithFood,
        takeWithWater: updatedReminder.takeWithWater,
        customFrequencyDescription: updatedReminder.customFrequencyDescription,
        customIntervalDays: updatedReminder.customIntervalDays,
        skipDays: updatedReminder.skipDays,
        hasNotifications: updatedReminder.hasNotifications,
      );

      final index = _reminders.indexWhere((r) => r.id == updatedReminder.id);
      if (index != -1) {
        _reminders[index] = updated;
        _updateReminderLists();
        notifyListeners();
      }
      return true;
    } catch (e) {
      setError('Failed to update reminder: ${e.toString()}');
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<bool> deleteReminder(String reminderId) async {
    setBusy(true);
    setError(null);

    try {
      final success = await _reminderService.deleteReminder(reminderId);
      if (success) {
        _reminders.removeWhere((r) => r.id == reminderId);
        _updateReminderLists();
        notifyListeners();
      }
      return success;
    } catch (e) {
      setError('Failed to delete reminder: ${e.toString()}');
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<bool> markDoseTaken(String reminderId) async {
    setBusy(true);
    setError(null);

    try {
      final updatedReminder = await _reminderService.markDoseTaken(reminderId);

      final index = _reminders.indexWhere((r) => r.id == reminderId);
      if (index != -1) {
        _reminders[index] = updatedReminder;

        // Update medicine quantity
        final medicineIndex = _medicines.indexWhere(
          (m) => m.id == updatedReminder.medicineId,
        );
        if (medicineIndex != -1) {
          final medicine = _medicines[medicineIndex];
          _medicines[medicineIndex] = medicine.copyWith(
            remainingQuantity: medicine.remainingQuantity - 1,
          );
        }

        _updateReminderLists();
        notifyListeners();
      }
      return true;
    } catch (e) {
      setError('Failed to mark dose as taken: ${e.toString()}');
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<bool> markDoseSkipped(String reminderId) async {
    setBusy(true);
    setError(null);

    try {
      final updatedReminder = await _reminderService.markDoseSkipped(
        reminderId,
      );

      final index = _reminders.indexWhere((r) => r.id == reminderId);
      if (index != -1) {
        _reminders[index] = updatedReminder;
        _updateReminderLists();
        notifyListeners();
      }
      return true;
    } catch (e) {
      setError('Failed to mark dose as skipped: ${e.toString()}');
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<bool> pauseReminder(String reminderId) async {
    setBusy(true);
    setError(null);

    try {
      final updatedReminder = await _reminderService.pauseReminder(reminderId);

      final index = _reminders.indexWhere((r) => r.id == reminderId);
      if (index != -1) {
        _reminders[index] = updatedReminder;
        _updateReminderLists();
        notifyListeners();
      }
      return true;
    } catch (e) {
      setError('Failed to pause reminder: ${e.toString()}');
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<bool> resumeReminder(String reminderId) async {
    setBusy(true);
    setError(null);

    try {
      final updatedReminder = await _reminderService.resumeReminder(reminderId);

      final index = _reminders.indexWhere((r) => r.id == reminderId);
      if (index != -1) {
        _reminders[index] = updatedReminder;
        _updateReminderLists();
        notifyListeners();
      }
      return true;
    } catch (e) {
      setError('Failed to resume reminder: ${e.toString()}');
      return false;
    } finally {
      setBusy(false);
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
    final activeReminders = _reminders.where(
      (r) => r.isActive && r.status == ReminderStatus.active,
    );
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

    final completedDoses = _reminders.fold(
      0,
      (sum, reminder) => sum + reminder.dosesCompleted,
    );
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
  Future<void> initialize() async {
    await initializeData();
  }
}
