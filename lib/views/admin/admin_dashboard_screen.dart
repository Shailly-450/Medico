import 'package:flutter/material.dart';
import 'package:medico/views/admin/appointments/admin_appointments_panel.dart';
import 'package:medico/views/admin/special_offers/special_offers_management_screen.dart';
import 'package:medico/views/admin/orders/admin_orders_panel.dart';
import '../../core/theme/app_colors.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAdminCard(
              context,
              icon: Icons.notifications_active,
              title: 'Special Offers Management',
              subtitle: 'Create, manage, and send push notifications for special offers',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SpecialOffersManagementScreen()),
              ),
            ),
            const SizedBox(height: 5),
            _buildAdminCard(
              context,
              icon: Icons.event_available,
              title: 'Appointment Management',
              subtitle: 'Approve or reject appointments',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminAppointmentsPanel()),
              ),
            ),
            const SizedBox(height: 5),
            _buildAdminCard(
              context,
              icon: Icons.shopping_bag,
              title: 'Order Management',
              subtitle: 'View and update order statuses',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminOrdersPanel()),
              ),
            ),
            const SizedBox(height: 24),
            _buildAdminCard(
              context,
              icon: Icons.people,
              title: 'User Management',
              subtitle: 'Manage users, doctors, and permissions',
              onTap: () {
                // TODO: Navigate to user management screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User Management coming soon!'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _buildAdminCard(
              context,
              icon: Icons.analytics,
              title: 'Analytics & Reports',
              subtitle: 'View app analytics and generate reports',
              onTap: () {
                // TODO: Navigate to analytics screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Analytics & Reports coming soon!'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
            // Add more admin features here as needed
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: AppColors.primary),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
} 