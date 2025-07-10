import 'package:flutter/material.dart';
import '../../core/views/base_view.dart';
import '../../viewmodels/notification_view_model.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/notification_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return BaseView<NotificationViewModel>(
      viewModelBuilder: () => NotificationViewModel(),
      onModelReady: (model) => model.init(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Notifications',
            style: TextStyle(
              color: Color(0xFF2E7D32), // Dark green color for title
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor:
              const Color(0xFFE8F5E8), // Light mint green from gradient
          elevation: 0,
          iconTheme: const IconThemeData(
              color: Color(0xFF2E7D32)), // Dark green for back button
          actions: [
            if (model.unreadCount > 0)
              TextButton(
                onPressed: model.markAllAsRead,
                child: Text(
                  'Mark all read',
                  style: TextStyle(
                    color: const Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE8F5E8), // Light mint green
                Color(0xFFF0F8F0), // Very light sage
                Color(0xFFE6F3E6), // Soft green tint
                Color(0xFFF5F9F5), // Almost white with green tint
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: _buildNotificationsTab(context, model),
        ),
      ),
    );
  }

  Widget _buildNotificationsTab(
      BuildContext context, NotificationViewModel model) {
    print(
        'Building notifications tab with ${model.notifications.length} notifications');
    if (model.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: const Color(0xFF2E7D32).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                color: const Color(0xFF2E7D32).withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: model.notifications.length,
      itemBuilder: (context, index) {
        final notification = model.notifications[index];
        return Dismissible(
          key: Key(notification.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.red.withOpacity(0.2),
                width: 1,
              ),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 30,
                ),
                SizedBox(height: 4),
                Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            // Show confirmation dialog
            return await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Delete Notification'),
                  content: const Text(
                      'Are you sure you want to delete this notification?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) {
            model.deleteNotification(notification.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${notification.title} deleted'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    // Note: In a real app, you'd want to implement undo functionality
                    // For now, we'll just show a message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Undo functionality coming soon!')),
                    );
                  },
                ),
              ),
            );
          },
          child: NotificationCard(
            notification: notification,
            onTap: () => model.markAsRead(notification.id),
          ),
        );
      },
    );
  }
}
