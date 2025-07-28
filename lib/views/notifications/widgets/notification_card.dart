import 'package:flutter/material.dart';
import '../../../models/notification_item.dart';
import '../../../core/theme/app_colors.dart';

class NotificationCard extends StatefulWidget {
  final NotificationItem notification;
  final VoidCallback? onTap;

  const NotificationCard({
    Key? key,
    required this.notification,
    this.onTap,
  }) : super(key: key);

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 1,
            color: Colors.white.withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: () {
                _animationController.forward().then((_) {
                  _animationController.reverse();
                  widget.onTap?.call();
                });
              },
              borderRadius: BorderRadius.circular(16),
              splashColor: const Color(0xFF2E7D32).withOpacity(0.1),
              highlightColor: const Color(0xFF81C784).withOpacity(0.1),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: widget.notification.isRead
                      ? Colors.white.withOpacity(0.9)
                      : const Color(0xFFE8F5E8).withOpacity(0.9),
                  border: widget.notification.isRead
                      ? null
                      : Border.all(
                          color: const Color(0xFF2E7D32).withOpacity(0.2),
                          width: 1,
                        ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getIconColor(widget.notification.type)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getIconColor(widget.notification.type)
                              .withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        _getIcon(widget.notification.type),
                        color: _getIconColor(widget.notification.type),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.notification.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: widget.notification.isRead
                                            ? FontWeight.w500
                                            : FontWeight.bold,
                                        color: const Color(0xFF2E7D32),
                                      ),
                                ),
                              ),
                              if (!widget.notification.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E7D32),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.notification.message,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color:
                                      const Color(0xFF2E7D32).withOpacity(0.7),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                _formatTimestamp(widget.notification.timestamp),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: const Color(0xFF2E7D32)
                                          .withOpacity(0.6),
                                    ),
                              ),
                              const Spacer(),
                              if (!widget.notification.isRead)
                                Text(
                                  'Tap to mark as read',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: const Color(0xFF2E7D32),
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.appointment_reminder:
        return Icons.calendar_today;
      case NotificationType.appointment_confirmed:
        return Icons.event_available;
      case NotificationType.appointment_cancelled:
        return Icons.event_busy;
      case NotificationType.prescription_ready:
        return Icons.medical_services;
      case NotificationType.test_result_ready:
        return Icons.science;
      case NotificationType.doctor_message:
        return Icons.chat_bubble_outline;
      case NotificationType.system_alert:
        return Icons.warning_amber_rounded;
      case NotificationType.payment_reminder:
        return Icons.payments;
      case NotificationType.video_call_invite:
        return Icons.video_call;
      case NotificationType.health_reminder:
        return Icons.health_and_safety;
      case NotificationType.general:
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.appointment_reminder:
        return const Color(0xFF2E7D32);
      case NotificationType.appointment_confirmed:
        return const Color(0xFF388E3C);
      case NotificationType.appointment_cancelled:
        return const Color(0xFFD32F2F);
      case NotificationType.prescription_ready:
        return const Color(0xFF1976D2);
      case NotificationType.test_result_ready:
        return const Color(0xFF512DA8);
      case NotificationType.doctor_message:
        return const Color(0xFF00897B);
      case NotificationType.system_alert:
        return const Color(0xFFFBC02D);
      case NotificationType.payment_reminder:
        return const Color(0xFF6D4C41);
      case NotificationType.video_call_invite:
        return const Color(0xFF0288D1);
      case NotificationType.health_reminder:
        return const Color(0xFF43A047);
      case NotificationType.general:
      default:
        return const Color(0xFF66BB6A);
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
