import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/test_checkup.dart';
import '../../viewmodels/test_checkup_view_model.dart';
import '../../core/views/base_view.dart';
import 'widgets/test_checkup_card.dart';
import 'widgets/test_checkup_stats_card.dart';
import 'add_test_checkup_screen.dart';
import 'test_checkup_detail_screen.dart';

class TestCheckupsScreen extends StatefulWidget {
  const TestCheckupsScreen({Key? key}) : super(key: key);

  @override
  State<TestCheckupsScreen> createState() => _TestCheckupsScreenState();
}

class _TestCheckupsScreenState extends State<TestCheckupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<TestCheckupViewModel>(
      viewModelBuilder: () => TestCheckupViewModel(),
      onModelReady: (model) {
        // Initialize the view model when it's ready
        model.init();
      },
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Test & Checkups'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48.0),
              child: Container(
                color: AppColors.primary,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  isScrollable: true, // Make tabs scrollable
                  tabAlignment: TabAlignment.start, // Align tabs to start
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                  tabs: [
                    Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Today'),
                            const SizedBox(width: 6),
                            if (model.todayCheckups.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${model.todayCheckups.length}',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Upcoming'),
                            const SizedBox(width: 6),
                            if (model.upcomingCheckups.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${model.upcomingCheckups.length}',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Overdue'),
                            const SizedBox(width: 6),
                            if (model.overdueCheckups.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${model.overdueCheckups.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Completed'),
                            const SizedBox(width: 6),
                            if (model.completedCheckups.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${model.completedCheckups.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('All'),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${model.checkups.length}',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              // Statistics Card - only show on Today and All tabs
              AnimatedBuilder(
                animation: _tabController,
                builder: (context, child) {
                  if (_tabController.index == 0 || _tabController.index == 4) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TestCheckupStatsCard(
                          statistics: model.getStatistics()),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCheckupList(model.todayCheckups, 'Today', model),
                    _buildCheckupList(
                        model.upcomingCheckups, 'Upcoming', model),
                    _buildCheckupList(model.overdueCheckups, 'Overdue', model),
                    _buildCheckupList(
                        model.completedCheckups, 'Completed', model),
                    _buildCheckupList(model.checkups, 'All', model),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addNewCheckup(context, model),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildCheckupList(
      List<TestCheckup> checkups, String title, TestCheckupViewModel model) {
    if (checkups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyStateIcon(title),
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyStateMessage(title),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            if (title == 'Today' || title == 'Upcoming')
              Text(
                'Tap the + button to schedule a new test',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: checkups.length,
      itemBuilder: (context, index) {
        final checkup = checkups[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TestCheckupCard(
            checkup: checkup,
            onTap: () => _viewCheckupDetails(context, checkup),
            onMarkCompleted: () => _markAsCompleted(context, checkup, model),
            onCancel: () => _cancelCheckup(context, checkup, model),
            onReschedule: () => _rescheduleCheckup(context, checkup, model),
          ),
        );
      },
    );
  }

  IconData _getEmptyStateIcon(String title) {
    switch (title) {
      case 'Today':
        return Icons.today;
      case 'Upcoming':
        return Icons.upcoming;
      case 'Overdue':
        return Icons.warning;
      case 'Completed':
        return Icons.check_circle;
      case 'All':
        return Icons.medical_services;
      default:
        return Icons.medical_services;
    }
  }

  String _getEmptyStateMessage(String title) {
    switch (title) {
      case 'Today':
        return 'No tests scheduled for today';
      case 'Upcoming':
        return 'No upcoming tests';
      case 'Overdue':
        return 'No overdue tests';
      case 'Completed':
        return 'No completed tests';
      case 'All':
        return 'No tests found';
      default:
        return 'No tests found';
    }
  }

  void _addNewCheckup(BuildContext context, TestCheckupViewModel model) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTestCheckupScreen(),
      ),
    );

    if (result != null && result is TestCheckup) {
      await model.addCheckup(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test checkup added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _viewCheckupDetails(BuildContext context, TestCheckup checkup) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestCheckupDetailScreen(checkup: checkup),
      ),
    );
  }

  void _markAsCompleted(BuildContext context, TestCheckup checkup,
      TestCheckupViewModel model) async {
    final results = await _showResultsDialog(context);
    if (results != null) {
      await model.markAsCompleted(checkup.id, results: results);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test marked as completed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _cancelCheckup(BuildContext context, TestCheckup checkup,
      TestCheckupViewModel model) async {
    final confirmed = await _showConfirmationDialog(
      context,
      'Cancel Test',
      'Are you sure you want to cancel this test?',
    );

    if (confirmed == true) {
      await model.cancelCheckup(checkup.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _rescheduleCheckup(BuildContext context, TestCheckup checkup,
      TestCheckupViewModel model) async {
    final result = await _showRescheduleDialog(context, checkup);
    if (result != null) {
      final newDate = result['date'] as DateTime;
      final newTime = result['time'] as TimeOfDay;

      await model.rescheduleCheckup(checkup.id, newDate, newTime);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test rescheduled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>?> _showRescheduleDialog(
      BuildContext context, TestCheckup checkup) async {
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Reschedule Test'),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Test: ${checkup.title}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Date Selection
                const Text(
                  'Select New Date:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate:
                            checkup.scheduledDate.isAfter(DateTime.now())
                                ? checkup.scheduledDate
                                : DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                                  primary: AppColors.primary,
                                ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      selectedDate == null
                          ? 'Choose Date'
                          : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Time Selection
                const Text(
                  'Select New Time:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: checkup.scheduledTime,
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                                  primary: AppColors.primary,
                                ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setState(() => selectedTime = picked);
                      }
                    },
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      selectedTime == null
                          ? 'Choose Time'
                          : selectedTime!.format(context),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                if (selectedDate != null && selectedTime != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.schedule,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'New appointment: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} at ${selectedTime!.format(context)}',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedDate != null && selectedTime != null
                  ? () => Navigator.pop(context, {
                        'date': selectedDate,
                        'time': selectedTime,
                      })
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Reschedule'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _showResultsDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Results'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Test Results',
            hintText: 'Enter test results or notes...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
