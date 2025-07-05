import 'package:flutter/material.dart';
import '../../core/views/base_view.dart';
import '../../viewmodels/medicine_reminder_view_model.dart';
import '../../core/theme/app_colors.dart';
import '../../models/medicine_reminder.dart';
import 'widgets/medicine_reminder_card.dart';
import 'widgets/reminder_stats_card.dart';
import 'add_medicine_reminder_screen.dart';
import 'medicine_reminder_detail_screen.dart';
import '../rx_orders/rx_orders_screen.dart';

class MedicineRemindersScreen extends StatefulWidget {
  const MedicineRemindersScreen({Key? key}) : super(key: key);

  @override
  State<MedicineRemindersScreen> createState() =>
      _MedicineRemindersScreenState();
}

class _MedicineRemindersScreenState extends State<MedicineRemindersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<MedicineReminderViewModel>(
      viewModelBuilder: () => MedicineReminderViewModel()..initialize(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Medicine Reminders'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showSearchDialog(context, model),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(context, model),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                text: 'Today',
                icon: Badge.count(
                  count: model.pendingTodayCount,
                  isLabelVisible: model.pendingTodayCount > 0,
                  child: const Icon(Icons.today),
                ),
              ),
              Tab(
                text: 'Upcoming',
                icon: Badge.count(
                  count: model.upcomingReminders.length,
                  isLabelVisible: model.upcomingReminders.isNotEmpty,
                  child: const Icon(Icons.schedule),
                ),
              ),
              Tab(
                text: 'Overdue',
                icon: Badge.count(
                  count: model.overdueCount,
                  isLabelVisible: model.overdueCount > 0,
                  child: const Icon(Icons.warning),
                ),
              ),
              const Tab(
                text: 'All',
                icon: Icon(Icons.medication),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // Stats Cards
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ReminderStatsCard(model: model),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTodayTab(context, model),
                  _buildUpcomingTab(context, model),
                  _buildOverdueTab(context, model),
                  _buildAllTab(context, model),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () => _navigateToRxOrders(context),
              backgroundColor: Colors.orange,
              heroTag: 'rx_orders',
              child: const Icon(Icons.local_pharmacy, color: Colors.white),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              onPressed: () => _navigateToAddReminder(context, model),
              backgroundColor: AppColors.primary,
              heroTag: 'add_reminder',
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayTab(BuildContext context, MedicineReminderViewModel model) {
    if (model.todayReminders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        title: 'No reminders for today',
        subtitle: 'Great! You\'re all caught up.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: model.todayReminders.length,
      itemBuilder: (context, index) {
        final reminder = model.todayReminders[index];
        return MedicineReminderCard(
          reminder: reminder,
          onTap: () => _navigateToDetail(context, reminder),
          onTakeDose: () => model.markDoseTaken(reminder.id),
          onSkipDose: () => model.markDoseSkipped(reminder.id),
          onRefill: reminder.medicine?.needsRefill == true ? () => _navigateToRxOrders(context) : null,
          showDoseActions: true,
        );
      },
    );
  }

  Widget _buildUpcomingTab(
      BuildContext context, MedicineReminderViewModel model) {
    if (model.upcomingReminders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.schedule,
        title: 'No upcoming reminders',
        subtitle: 'Your upcoming reminders will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: model.upcomingReminders.length,
      itemBuilder: (context, index) {
        final reminder = model.upcomingReminders[index];
        return MedicineReminderCard(
          reminder: reminder,
          onTap: () => _navigateToDetail(context, reminder),
          showDoseActions: false,
        );
      },
    );
  }

  Widget _buildOverdueTab(
      BuildContext context, MedicineReminderViewModel model) {
    if (model.overdueReminders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        title: 'No overdue reminders',
        subtitle: 'You\'re staying on track!',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: model.overdueReminders.length,
      itemBuilder: (context, index) {
        final reminder = model.overdueReminders[index];
        return MedicineReminderCard(
          reminder: reminder,
          onTap: () => _navigateToDetail(context, reminder),
          onTakeDose: () => model.markDoseTaken(reminder.id),
          onSkipDose: () => model.markDoseSkipped(reminder.id),
          onRefill: reminder.medicine?.needsRefill == true ? () => _navigateToRxOrders(context) : null,
          showDoseActions: true,
          isOverdue: true,
        );
      },
    );
  }

  Widget _buildAllTab(BuildContext context, MedicineReminderViewModel model) {
    final filteredReminders = model.getFilteredReminders();

    if (filteredReminders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.medication,
        title: 'No reminders found',
        subtitle: 'Add your first medicine reminder to get started.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredReminders.length,
      itemBuilder: (context, index) {
        final reminder = filteredReminders[index];
        return MedicineReminderCard(
          reminder: reminder,
          onTap: () => _navigateToDetail(context, reminder),
          onEdit: () => _navigateToEdit(context, model, reminder),
          onDelete: () => _showDeleteConfirmation(context, model, reminder),
          onPause: reminder.status == ReminderStatus.active
              ? () => model.pauseReminder(reminder.id)
              : () => model.resumeReminder(reminder.id),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToRxOrders(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RxOrdersScreen(),
      ),
    );
  }

  void _navigateToAddReminder(
      BuildContext context, MedicineReminderViewModel model) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AddMedicineReminderScreen(medicines: model.medicines),
      ),
    );

    if (result != null && result is MedicineReminder) {
      model.addReminder(result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder added successfully')),
      );
    }
  }

  void _navigateToDetail(BuildContext context, MedicineReminder reminder) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MedicineReminderDetailScreen(reminder: reminder),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, MedicineReminderViewModel model,
      MedicineReminder reminder) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddMedicineReminderScreen(
          medicines: model.medicines,
          editingReminder: reminder,
        ),
      ),
    );

    if (result != null && result is MedicineReminder) {
      model.updateReminder(result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder updated successfully')),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context,
      MedicineReminderViewModel model, MedicineReminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text(
            'Are you sure you want to delete the reminder for ${reminder.reminderName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              model.deleteReminder(reminder.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reminder deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(
      BuildContext context, MedicineReminderViewModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Reminders'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter medicine name or reminder name',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: model.setSearchQuery,
        ),
        actions: [
          TextButton(
            onPressed: () {
              model.setSearchQuery('');
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(
      BuildContext context, MedicineReminderViewModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Reminders'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Show only active'),
              value: model.showOnlyActive,
              onChanged: (_) => model.toggleShowOnlyActive(),
            ),
            const Divider(),
            const Text('Status Filter:'),
            ...ReminderStatus.values
                .map((status) => RadioListTile<ReminderStatus>(
                      title: Text(status.name.toUpperCase()),
                      value: status,
                      groupValue: model.statusFilter,
                      onChanged: model.setStatusFilter,
                    )),
            RadioListTile<ReminderStatus?>(
              title: const Text('All'),
              value: null,
              groupValue: model.statusFilter,
              onChanged: model.setStatusFilter,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              model.setStatusFilter(null);
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
