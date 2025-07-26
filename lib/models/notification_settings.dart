class NotificationChannelSettings {
  final bool enabled;
  final int timeBeforeDose; // minutes before dose to notify

  const NotificationChannelSettings({
    required this.enabled,
    required this.timeBeforeDose,
  });

  factory NotificationChannelSettings.fromJson(Map<String, dynamic> json) {
    return NotificationChannelSettings(
      enabled: json['enabled'] ?? false,
      timeBeforeDose: json['timeBeforeDose'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'timeBeforeDose': timeBeforeDose,
    };
  }

  NotificationChannelSettings copyWith({
    bool? enabled,
    int? timeBeforeDose,
  }) {
    return NotificationChannelSettings(
      enabled: enabled ?? this.enabled,
      timeBeforeDose: timeBeforeDose ?? this.timeBeforeDose,
    );
  }
}

class NotificationSettings {
  final NotificationChannelSettings email;
  final NotificationChannelSettings push;
  final NotificationChannelSettings sms;

  const NotificationSettings({
    required this.email,
    required this.push,
    required this.sms,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      email: NotificationChannelSettings.fromJson(json['email'] ?? {}),
      push: NotificationChannelSettings.fromJson(json['push'] ?? {}),
      sms: NotificationChannelSettings.fromJson(json['sms'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email.toJson(),
      'push': push.toJson(),
      'sms': sms.toJson(),
    };
  }

  NotificationSettings copyWith({
    NotificationChannelSettings? email,
    NotificationChannelSettings? push,
    NotificationChannelSettings? sms,
  }) {
    return NotificationSettings(
      email: email ?? this.email,
      push: push ?? this.push,
      sms: sms ?? this.sms,
    );
  }
}
