enum NotificationType {
  appointment_reminder,
  appointment_confirmed,
  appointment_cancelled,
  prescription_ready,
  test_result_ready,
  doctor_message,
  system_alert,
  payment_reminder,
  video_call_invite,
  health_reminder,
  order_confirmed,
  order_status_updated,
  general,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.data,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['createdAt']),
      type: _parseType(json['type']),
      isRead: json['isRead'] ?? false,
      data: json,
    );
  }

  static NotificationType _parseType(String? type) {
    switch (type) {
      case 'appointment_reminder': return NotificationType.appointment_reminder;
      case 'appointment_confirmed': return NotificationType.appointment_confirmed;
      case 'appointment_cancelled': return NotificationType.appointment_cancelled;
      case 'prescription_ready': return NotificationType.prescription_ready;
      case 'test_result_ready': return NotificationType.test_result_ready;
      case 'doctor_message': return NotificationType.doctor_message;
      case 'system_alert': return NotificationType.system_alert;
      case 'payment_reminder': return NotificationType.payment_reminder;
      case 'video_call_invite': return NotificationType.video_call_invite;
      case 'health_reminder': return NotificationType.health_reminder;
      case 'order_confirmed': return NotificationType.order_confirmed;
      case 'order_status_updated': return NotificationType.order_status_updated;
      default: return NotificationType.general;
    }
  }
}
