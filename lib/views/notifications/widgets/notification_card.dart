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
      case NotificationType.appointment:
        return Icons.calendar_today;
      case NotificationType.offer:
        return Icons.local_offer;
      case NotificationType.reminder:
        return Icons.medication;
      case NotificationType.general:
        return Icons.info;
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
        return const Color(0xFF2E7D32); // Dark green
      case NotificationType.offer:
        return const Color(0xFF1B5E20); // Darker green
      case NotificationType.reminder:
        return const Color(0xFF43A047); // Medium green
      case NotificationType.general:
        return const Color(0xFF66BB6A); // Light green
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
