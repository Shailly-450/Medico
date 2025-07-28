import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/dashboard_view_model.dart';
import 'widgets/notification_card.dart';

class NotificationsPage extends StatelessWidget {
  final DashboardViewModel model;
  const NotificationsPage({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              model.markAllNotificationsAsRead();
            },
            child: Text(
              'Mark All Read',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: model.notifications.length,
          itemBuilder: (context, index) {
            return NotificationCard(
              notification: model.notifications[index],
              onTap: () => model.markNotificationAsRead(index),
            );
          },
        ),
      ),
    );
  }
}
