import 'medicine.dart';

enum ReminderFrequency {
  once, // Once only
  daily, // Every day
  everyOtherDay, // Every 2 days
  weekly, // Once a week
  biWeekly, // Every 2 weeks
  monthly, // Once a month
  asNeeded, // As needed
  custom, // Custom frequency
}

enum ReminderStatus { active, paused, completed, skipped }

class NotificationChannelSettings {
  final bool enabled;
  final int timeBeforeDose;

  NotificationChannelSettings({
    required this.enabled,
    required this.timeBeforeDose,
  });

  factory NotificationChannelSettings.fromJson(Map<String, dynamic> json) =>
      NotificationChannelSettings(
        enabled: json['enabled'] as bool,
        timeBeforeDose: json['timeBeforeDose'] as int,
      );

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'timeBeforeDose': timeBeforeDose,
  };
}

class NotificationSettings {
  final NotificationChannelSettings email;
  final NotificationChannelSettings push;
  final NotificationChannelSettings sms;

  NotificationSettings({
    required this.email,
    required this.push,
    required this.sms,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      NotificationSettings(
        email: NotificationChannelSettings.fromJson(json['email']),
        push: NotificationChannelSettings.fromJson(json['push']),
        sms: NotificationChannelSettings.fromJson(json['sms']),
      );

  Map<String, dynamic> toJson() => {
    'email': email.toJson(),
    'push': push.toJson(),
    'sms': sms.toJson(),
  };
}

class MedicineReminder {
  final String id;
  final String medicineId;
  final Medicine? medicine; // Optional populated medicine object
  final String reminderName;
  final ReminderFrequency frequency;
  final int dosesPerDay;
  final List<DateTime> reminderTimes; // Daily reminder times
  final DateTime startDate;
  final DateTime? endDate;
  final int? totalDoses; // For finite courses
  final int dosesCompleted;
  final bool isActive;
  final ReminderStatus status;
  final String? instructions; // Special instructions
  final bool takeWithFood;
  final bool takeWithWater;
  final String? customFrequencyDescription; // For custom frequency
  final int? customIntervalDays; // For custom frequency
  final List<String> skipDays; // Days to skip (e.g., ["Saturday", "Sunday"])
  final bool hasNotifications;
  final DateTime createdAt;
  final DateTime updatedAt;
  final NotificationSettings notificationSettings;
  final bool reminderVibration;

  MedicineReminder({
    required this.id,
    required this.medicineId,
    this.medicine,
    required this.reminderName,
    required this.frequency,
    required this.dosesPerDay,
    required this.reminderTimes,
    required this.startDate,
    this.endDate,
    this.totalDoses,
    this.dosesCompleted = 0,
    this.isActive = true,
    this.status = ReminderStatus.active,
    this.instructions,
    this.takeWithFood = false,
    this.takeWithWater = true,
    this.customFrequencyDescription,
    this.customIntervalDays,
    this.skipDays = const [],
    this.hasNotifications = true,
    required this.notificationSettings,
    required this.reminderVibration,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create MedicineReminder from JSON
  factory MedicineReminder.fromJson(Map<String, dynamic> json) {
    return MedicineReminder(
      id: json['id'] as String,
      medicineId: json['medicineId'] as String,
      medicine: json['medicine'] != null
          ? Medicine.fromJson(json['medicine'] as Map<String, dynamic>)
          : null,
      reminderName: json['reminderName'] as String,
      frequency: ReminderFrequency.values.firstWhere(
        (e) => e.toString() == json['frequency'],
        orElse: () => ReminderFrequency.daily,
      ),
      dosesPerDay: json['dosesPerDay'] as int,
      reminderTimes: (json['reminderTimes'] as List)
          .map((time) => DateTime.parse(time as String))
          .toList(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      totalDoses: json['totalDoses'] as int?,
      dosesCompleted: json['dosesCompleted'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      status: ReminderStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ReminderStatus.active,
      ),
      instructions: json['instructions'] as String?,
      takeWithFood: json['takeWithFood'] as bool? ?? false,
      takeWithWater: json['takeWithWater'] as bool? ?? true,
      customFrequencyDescription: json['customFrequencyDescription'] as String?,
      customIntervalDays: json['customIntervalDays'] as int?,
      skipDays: List<String>.from(json['skipDays'] ?? []),
      hasNotifications: json['hasNotifications'] as bool? ?? true,
      notificationSettings: json['notificationSettings'] != null
          ? NotificationSettings.fromJson(json['notificationSettings'])
          : NotificationSettings(
              email: NotificationChannelSettings(
                enabled: true,
                timeBeforeDose: 10,
              ),
              push: NotificationChannelSettings(
                enabled: true,
                timeBeforeDose: 10,
              ),
              sms: NotificationChannelSettings(
                enabled: false,
                timeBeforeDose: 10,
              ),
            ),
      reminderVibration: json['reminderVibration'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Convert MedicineReminder to JSON
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id': id,
      'medicineId': medicineId,
      'medicine': medicine?.toJson(),
      'reminderName': reminderName,
      'frequency': frequency.toString(),
      'dosesPerDay': dosesPerDay,
      'reminderTimes': reminderTimes
          .map((time) => time.toIso8601String())
          .toList(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'totalDoses': totalDoses,
      'dosesCompleted': dosesCompleted,
      'isActive': isActive,
      'status': status.toString(),
      'instructions': instructions,
      'takeWithFood': takeWithFood,
      'takeWithWater': takeWithWater,
      'customFrequencyDescription': customFrequencyDescription,
      'customIntervalDays': customIntervalDays,
      'skipDays': skipDays,
      'hasNotifications': hasNotifications,
      'notificationSettings': notificationSettings.toJson(),
      'reminderVibration': reminderVibration,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
    return data;
  }

  // Check if reminder is due now
  bool get isDueNow {
    if (!isActive || status != ReminderStatus.active) return false;

    final now = DateTime.now();
    return reminderTimes.any((reminderTime) {
      final todayReminder = DateTime(
        now.year,
        now.month,
        now.day,
        reminderTime.hour,
        reminderTime.minute,
      );
      return now.difference(todayReminder).inMinutes.abs() <= 5;
    });
  }

  // Get next reminder time
  DateTime? get nextReminderTime {
    if (!isActive || status != ReminderStatus.active) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if any reminder time today is still upcoming
    for (final reminderTime in reminderTimes) {
      final todayReminder = DateTime(
        today.year,
        today.month,
        today.day,
        reminderTime.hour,
        reminderTime.minute,
      );
      if (todayReminder.isAfter(now)) {
        return todayReminder;
      }
    }

    // If no more reminders today, return first reminder tomorrow
    final tomorrow = today.add(const Duration(days: 1));
    return DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      reminderTimes.first.hour,
      reminderTimes.first.minute,
    );
  }

  // Calculate completion percentage
  double get completionPercentage {
    if (totalDoses == null || totalDoses == 0) return 0.0;
    return (dosesCompleted / totalDoses!) * 100;
  }

  // Check if reminder course is completed
  bool get isCompleted {
    if (totalDoses == null) return false;
    return dosesCompleted >= totalDoses!;
  }

  // Get remaining doses
  int? get remainingDoses {
    if (totalDoses == null) return null;
    return totalDoses! - dosesCompleted;
  }

  // Calculate days until end date
  int? get daysUntilEnd {
    if (endDate == null) return null;
    return endDate!.difference(DateTime.now()).inDays;
  }

  // Get frequency description
  String get frequencyDescription {
    switch (frequency) {
      case ReminderFrequency.once:
        return 'Once only';
      case ReminderFrequency.daily:
        return 'Daily';
      case ReminderFrequency.everyOtherDay:
        return 'Every other day';
      case ReminderFrequency.weekly:
        return 'Weekly';
      case ReminderFrequency.biWeekly:
        return 'Every 2 weeks';
      case ReminderFrequency.monthly:
        return 'Monthly';
      case ReminderFrequency.asNeeded:
        return 'As needed';
      case ReminderFrequency.custom:
        return customFrequencyDescription ?? 'Custom';
    }
  }

  // Copy with method for updates
  MedicineReminder copyWith({
    String? id,
    String? medicineId,
    Medicine? medicine,
    String? reminderName,
    ReminderFrequency? frequency,
    int? dosesPerDay,
    List<DateTime>? reminderTimes,
    DateTime? startDate,
    DateTime? endDate,
    int? totalDoses,
    int? dosesCompleted,
    bool? isActive,
    ReminderStatus? status,
    String? instructions,
    bool? takeWithFood,
    bool? takeWithWater,
    String? customFrequencyDescription,
    int? customIntervalDays,
    List<String>? skipDays,
    bool? hasNotifications,
    NotificationSettings? notificationSettings,
    bool? reminderVibration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicineReminder(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      medicine: medicine ?? this.medicine,
      reminderName: reminderName ?? this.reminderName,
      frequency: frequency ?? this.frequency,
      dosesPerDay: dosesPerDay ?? this.dosesPerDay,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalDoses: totalDoses ?? this.totalDoses,
      dosesCompleted: dosesCompleted ?? this.dosesCompleted,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      instructions: instructions ?? this.instructions,
      takeWithFood: takeWithFood ?? this.takeWithFood,
      takeWithWater: takeWithWater ?? this.takeWithWater,
      customFrequencyDescription:
          customFrequencyDescription ?? this.customFrequencyDescription,
      customIntervalDays: customIntervalDays ?? this.customIntervalDays,
      skipDays: skipDays ?? this.skipDays,
      hasNotifications: hasNotifications ?? this.hasNotifications,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      reminderVibration: reminderVibration ?? this.reminderVibration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
