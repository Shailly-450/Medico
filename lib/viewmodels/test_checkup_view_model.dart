import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/test_checkup.dart';

class TestCheckupViewModel extends BaseViewModel {
  List<TestCheckup> _checkups = [];
  List<TestCheckup> _todayCheckups = [];
  List<TestCheckup> _upcomingCheckups = [];
  List<TestCheckup> _overdueCheckups = [];
  List<TestCheckup> _completedCheckups = [];
  TestCheckupType? _selectedFilter;
  TestCheckupStatus? _statusFilter;

  // Getters
  List<TestCheckup> get checkups => _checkups;
  List<TestCheckup> get todayCheckups => _todayCheckups;
  List<TestCheckup> get upcomingCheckups => _upcomingCheckups;
  List<TestCheckup> get overdueCheckups => _overdueCheckups;
  List<TestCheckup> get completedCheckups => _completedCheckups;
  TestCheckupType? get selectedFilter => _selectedFilter;
  TestCheckupStatus? get statusFilter => _statusFilter;

  @override
  void init() {
    print('TestCheckupViewModel: Initializing...');
    _loadDummyData();
    _updateCheckupLists();
    print('TestCheckupViewModel: Loaded ${_checkups.length} checkups');
    notifyListeners();
  }

  void _loadDummyData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));
    final lastWeek = today.subtract(const Duration(days: 7));

    _checkups = [
      // Same data as in dashboard - Today's checkups
      TestCheckup(
        id: '1',
        title: 'Complete Blood Count (CBC)',
        description: 'Blood test to check overall health',
        type: TestCheckupType.bloodTest,
        scheduledDate: today.add(Duration(days: 2)),
        scheduledTime: TimeOfDay(hour: 9, minute: 30),
        doctorName: 'Dr. Smith',
        location: 'Central Lab',
        estimatedCost: 450.0,
        status: TestCheckupStatus.scheduled,
        priority: TestCheckupPriority.medium,
        instructions: 'Fasting required for 12 hours before test',
        requiresPreparation: true,
        preparationInstructions:
            'No food or drinks except water after 9 PM the night before',
        createdAt: now.subtract(Duration(days: 5)),
        updatedAt: now.subtract(Duration(days: 1)),
      ),
      TestCheckup(
        id: '2',
        title: 'Chest X-Ray',
        description: 'X-ray imaging of chest area',
        type: TestCheckupType.xRay,
        scheduledDate: tomorrow,
        scheduledTime: TimeOfDay(hour: 14, minute: 0),
        doctorName: 'Dr. Johnson',
        location: 'Medical Imaging Center',
        estimatedCost: 800.0,
        status: TestCheckupStatus.scheduled,
        priority: TestCheckupPriority.high,
        instructions: 'Remove all jewelry and metal objects',
        requiresPreparation: false,
        createdAt: now.subtract(Duration(days: 3)),
        updatedAt: now.subtract(Duration(days: 1)),
      ),
      TestCheckup(
        id: '3',
        title: 'Annual Physical Checkup',
        description: 'Comprehensive health examination',
        type: TestCheckupType.physicalExam,
        scheduledDate: nextWeek,
        scheduledTime: TimeOfDay(hour: 10, minute: 0),
        doctorName: 'Dr. Wilson',
        location: 'Family Health Clinic',
        estimatedCost: 1200.0,
        status: TestCheckupStatus.scheduled,
        priority: TestCheckupPriority.medium,
        instructions: 'Bring previous medical records',
        requiresPreparation: true,
        preparationInstructions:
            'Fast for 8 hours, bring insurance card and ID',
        createdAt: now.subtract(Duration(days: 10)),
        updatedAt: now.subtract(Duration(days: 2)),
      ),
      TestCheckup(
        id: '4',
        title: 'Diabetes Screening',
        description: 'Blood glucose level test',
        type: TestCheckupType.bloodTest,
        scheduledDate: now.subtract(Duration(days: 3)),
        scheduledTime: TimeOfDay(hour: 8, minute: 0),
        doctorName: 'Dr. Brown',
        location: 'Diabetes Care Center',
        estimatedCost: 300.0,
        status: TestCheckupStatus.completed,
        priority: TestCheckupPriority.medium,
        results: 'Blood glucose levels normal',
        createdAt: now.subtract(Duration(days: 15)),
        updatedAt: now.subtract(Duration(days: 3)),
      ),
      TestCheckup(
        id: '5',
        title: 'MRI Brain Scan',
        description: 'Magnetic resonance imaging of brain',
        type: TestCheckupType.mri,
        scheduledDate: now.add(Duration(days: 14)),
        scheduledTime: TimeOfDay(hour: 11, minute: 30),
        doctorName: 'Dr. Davis',
        location: 'Advanced Imaging',
        estimatedCost: 5500.0,
        status: TestCheckupStatus.scheduled,
        priority: TestCheckupPriority.high,
        instructions: 'Inform about any metal implants',
        requiresPreparation: true,
        preparationInstructions:
            'No metal objects, comfortable clothing, arrive 30 minutes early',
        createdAt: now.subtract(Duration(days: 7)),
        updatedAt: now.subtract(Duration(days: 1)),
      ),

      // Additional today's tests
      TestCheckup(
        id: '6',
        title: 'Urine Analysis',
        description: 'Complete urinalysis including protein and glucose',
        type: TestCheckupType.urineTest,
        status: TestCheckupStatus.scheduled,
        priority: TestCheckupPriority.low,
        scheduledDate: today,
        scheduledTime: const TimeOfDay(hour: 16, minute: 0),
        location: 'Quick Lab Services',
        doctorName: 'Dr. James Miller',
        doctorSpecialty: 'Laboratory Medicine',
        estimatedCost: 45.0,
        instructions: 'Mid-stream urine sample required',
        requiredDocuments: ['Lab Request Form'],
        hasReminder: true,
        reminderTime: today.subtract(const Duration(hours: 1)),
        createdAt: lastWeek,
        updatedAt: now,
      ),

      TestCheckup(
        id: '7',
        title: 'Dental Cleaning',
        description: 'Regular dental checkup and cleaning',
        type: TestCheckupType.dentalCheckup,
        status: TestCheckupStatus.scheduled,
        priority: TestCheckupPriority.low,
        scheduledDate: today,
        scheduledTime: const TimeOfDay(hour: 14, minute: 30),
        location: 'Bright Smile Dental Clinic',
        doctorName: 'Dr. Michael Chen',
        doctorSpecialty: 'Dentist',
        estimatedCost: 80.0,
        instructions: 'Brush and floss before appointment',
        requiredDocuments: ['Dental Insurance'],
        hasReminder: true,
        reminderTime: today.subtract(const Duration(hours: 1)),
        createdAt: lastWeek,
        updatedAt: now,
      ),

      // More upcoming tests
      TestCheckup(
        id: '8',
        title: 'Eye Examination',
        description: 'Comprehensive eye exam and vision test',
        type: TestCheckupType.eyeExam,
        status: TestCheckupStatus.scheduled,
        priority: TestCheckupPriority.medium,
        scheduledDate: nextWeek.add(const Duration(days: 2)),
        scheduledTime: const TimeOfDay(hour: 11, minute: 0),
        location: 'Vision Care Center',
        doctorName: 'Dr. David Wilson',
        doctorSpecialty: 'Ophthalmologist',
        estimatedCost: 95.0,
        instructions: 'Bring current glasses or contact lenses',
        requiredDocuments: ['Vision Insurance'],
        hasReminder: true,
        reminderTime: nextWeek
            .add(const Duration(days: 2))
            .subtract(const Duration(hours: 2)),
        createdAt: lastWeek,
        updatedAt: now,
      ),

      TestCheckup(
        id: '9',
        title: 'Ultrasound - Abdomen',
        description: 'Abdominal ultrasound for digestive system check',
        type: TestCheckupType.ultrasound,
        status: TestCheckupStatus.scheduled,
        priority: TestCheckupPriority.medium,
        scheduledDate: tomorrow.add(const Duration(days: 1)),
        scheduledTime: const TimeOfDay(hour: 9, minute: 30),
        location: 'Women\'s Health Center',
        doctorName: 'Dr. Jennifer Lee',
        doctorSpecialty: 'Radiologist',
        estimatedCost: 160.0,
        instructions: 'Drink 32oz of water 1 hour before, don\'t empty bladder',
        requiresPreparation: true,
        preparationInstructions: 'Fast for 8 hours, drink water as instructed',
        requiredDocuments: ['Referral Letter', 'Insurance Card'],
        hasReminder: true,
        reminderTime: tomorrow
            .add(const Duration(days: 1))
            .subtract(const Duration(hours: 2)),
        createdAt: lastWeek,
        updatedAt: now,
      ),

      TestCheckup(
        id: '10',
        title: 'Colonoscopy',
        description: 'Screening colonoscopy for preventive care',
        type: TestCheckupType.colonoscopy,
        status: TestCheckupStatus.scheduled,
        priority: TestCheckupPriority.high,
        scheduledDate: nextWeek.add(const Duration(days: 3)),
        scheduledTime: const TimeOfDay(hour: 8, minute: 0),
        location: 'Gastroenterology Center',
        doctorName: 'Dr. Thomas Clark',
        doctorSpecialty: 'Gastroenterologist',
        estimatedCost: 800.0,
        instructions: 'Follow prep instructions exactly',
        requiresPreparation: true,
        preparationInstructions:
            'Clear liquid diet 24hrs before, take prep solution as directed',
        requiredDocuments: ['Prep Instructions', 'Insurance Card', 'ID'],
        hasReminder: true,
        reminderTime: nextWeek
            .add(const Duration(days: 3))
            .subtract(const Duration(hours: 24)),
        createdAt: lastWeek.subtract(const Duration(days: 14)),
        updatedAt: now,
      ),

      TestCheckup(
        id: '11',
        title: 'Mammogram',
        description: 'Annual mammography screening',
        type: TestCheckupType.mammogram,
        status: TestCheckupStatus.scheduled,
        priority: TestCheckupPriority.medium,
        scheduledDate: nextWeek.add(const Duration(days: 5)),
        scheduledTime: const TimeOfDay(hour: 10, minute: 30),
        location: 'Women\'s Imaging Center',
        doctorName: 'Dr. Susan White',
        doctorSpecialty: 'Radiologist',
        estimatedCost: 220.0,
        instructions: 'No deodorant, lotion, or powder on day of exam',
        requiredDocuments: [
          'Insurance Card',
          'Previous Mammogram (if available)'
        ],
        hasReminder: true,
        reminderTime: nextWeek
            .add(const Duration(days: 5))
            .subtract(const Duration(hours: 2)),
        createdAt: lastWeek.subtract(const Duration(days: 7)),
        updatedAt: now,
      ),

      // More completed tests
      TestCheckup(
        id: '12',
        title: 'ECG Test',
        description: 'Electrocardiogram for heart rhythm assessment',
        type: TestCheckupType.ecg,
        status: TestCheckupStatus.completed,
        priority: TestCheckupPriority.medium,
        scheduledDate: lastWeek,
        scheduledTime: const TimeOfDay(hour: 13, minute: 0),
        location: 'Cardiology Department',
        doctorName: 'Dr. Robert Johnson',
        doctorSpecialty: 'Cardiologist',
        estimatedCost: 180.0,
        instructions: 'Avoid caffeine 4 hours before test',
        completedDate: lastWeek,
        results: 'Normal sinus rhythm, no abnormalities detected',
        hasReminder: true,
        reminderTime: lastWeek.subtract(const Duration(hours: 2)),
        createdAt: lastWeek.subtract(const Duration(days: 14)),
        updatedAt: lastWeek,
      ),

      TestCheckup(
        id: '13',
        title: 'Stress Test',
        description: 'Cardiac stress test with ECG monitoring',
        type: TestCheckupType.stressTest,
        status: TestCheckupStatus.completed,
        priority: TestCheckupPriority.high,
        scheduledDate: lastWeek.subtract(const Duration(days: 3)),
        scheduledTime: const TimeOfDay(hour: 11, minute: 0),
        location: 'Cardiac Testing Center',
        doctorName: 'Dr. Mark Thompson',
        doctorSpecialty: 'Cardiologist',
        estimatedCost: 350.0,
        instructions: 'Wear comfortable clothes and walking shoes',
        completedDate: lastWeek.subtract(const Duration(days: 3)),
        results: 'Exercise tolerance excellent, no signs of ischemia',
        hasReminder: true,
        reminderTime: lastWeek.subtract(const Duration(days: 3, hours: 2)),
        createdAt: lastWeek.subtract(const Duration(days: 21)),
        updatedAt: lastWeek.subtract(const Duration(days: 3)),
      ),

      TestCheckup(
        id: '14',
        title: 'Hearing Test',
        description: 'Comprehensive audiological evaluation',
        type: TestCheckupType.hearingTest,
        status: TestCheckupStatus.completed,
        priority: TestCheckupPriority.low,
        scheduledDate: lastWeek.subtract(const Duration(days: 5)),
        scheduledTime: const TimeOfDay(hour: 14, minute: 0),
        location: 'Audiology Clinic',
        doctorName: 'Dr. Rachel Green',
        doctorSpecialty: 'Audiologist',
        estimatedCost: 125.0,
        instructions: 'Avoid loud noises 24 hours before test',
        completedDate: lastWeek.subtract(const Duration(days: 5)),
        results: 'Hearing within normal limits bilaterally',
        hasReminder: true,
        reminderTime: lastWeek.subtract(const Duration(days: 5, hours: 2)),
        createdAt: lastWeek.subtract(const Duration(days: 30)),
        updatedAt: lastWeek.subtract(const Duration(days: 5)),
      ),

      // Overdue tests
      TestCheckup(
        id: '15',
        title: 'Skin Cancer Screening',
        description: 'Full body skin examination for cancer screening',
        type: TestCheckupType.skinCheck,
        status: TestCheckupStatus.overdue,
        priority: TestCheckupPriority.medium,
        scheduledDate: lastWeek.subtract(const Duration(days: 10)),
        scheduledTime: const TimeOfDay(hour: 13, minute: 30),
        location: 'Dermatology Associates',
        doctorName: 'Dr. Karen Davis',
        doctorSpecialty: 'Dermatologist',
        estimatedCost: 175.0,
        instructions: 'Remove nail polish, note any concerning spots',
        requiredDocuments: ['Insurance Card', 'Skin Photo (if applicable)'],
        hasReminder: true,
        reminderTime: lastWeek.subtract(const Duration(days: 10, hours: 2)),
        createdAt: lastWeek.subtract(const Duration(days: 60)),
        updatedAt: now,
      ),

      TestCheckup(
        id: '16',
        title: 'Blood Pressure Check',
        description: 'Routine blood pressure monitoring',
        type: TestCheckupType.physicalExam,
        status: TestCheckupStatus.overdue,
        priority: TestCheckupPriority.high,
        scheduledDate: lastWeek.subtract(const Duration(days: 5)),
        scheduledTime: const TimeOfDay(hour: 15, minute: 0),
        location: 'Family Health Clinic',
        doctorName: 'Dr. Lisa Anderson',
        doctorSpecialty: 'General Physician',
        estimatedCost: 50.0,
        instructions: 'Avoid caffeine 1 hour before',
        requiredDocuments: ['Insurance Card'],
        hasReminder: true,
        reminderTime: lastWeek.subtract(const Duration(days: 5, hours: 2)),
        createdAt: lastWeek.subtract(const Duration(days: 30)),
        updatedAt: now,
      ),
    ];
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
      filtered =
          filtered.where((checkup) => checkup.type == _selectedFilter).toList();
    }

    if (_statusFilter != null) {
      filtered =
          filtered.where((checkup) => checkup.status == _statusFilter).toList();
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
      String id, DateTime newDate, TimeOfDay newTime) async {
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
    final pending =
        _checkups.where((c) => c.status == TestCheckupStatus.scheduled).length;
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
        0.0, (sum, checkup) => sum + (checkup.estimatedCost ?? 0));
  }

  // Get checkups requiring preparation
  List<TestCheckup> getCheckupsRequiringPreparation() {
    return _checkups
        .where((checkup) =>
            checkup.requiresPreparation &&
            checkup.status == TestCheckupStatus.scheduled &&
            checkup.scheduledDate.isAfter(DateTime.now()))
        .toList();
  }

  // Get checkups requiring fasting
  List<TestCheckup> getCheckupsRequiringFasting() {
    return _checkups
        .where((checkup) =>
            checkup.requiresFasting &&
            checkup.status == TestCheckupStatus.scheduled &&
            checkup.scheduledDate.isAfter(DateTime.now()))
        .toList();
  }

  // Clear filters
  void clearFilters() {
    _selectedFilter = null;
    _statusFilter = null;
    notifyListeners();
  }
}
