import 'package:flutter/material.dart';
import '../../core/views/base_view.dart';
import '../../viewmodels/dashboard_view_model.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/health_overview_card.dart';
import 'widgets/recent_visit_card.dart';
import 'widgets/medication_card.dart';
import 'widgets/recommendation_card.dart';
import 'widgets/notification_card.dart';
import 'widgets/quick_action_card.dart';
import '../shared/profile_header.dart';
import 'notifications_page.dart';
import '../notifications/notification_screen.dart';
import '../comparison/comparison_screen.dart';
import '../schedule/schedule_screen.dart';
import '../health_records/health_records_screen.dart';
import '../medicine_reminders/medicine_reminders_screen.dart';
import '../test_checkups/test_checkups_screen.dart';
import 'widgets/pre_approval_summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<DashboardViewModel>(
      viewModelBuilder: () => DashboardViewModel(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shared Profile Header
                ProfileHeader(
                  name: 'Your health dashboard',
                  location: model.userName,
                  subtitle: '',
                  notificationCount: model.getUnreadNotificationsCount(),
                  onNotificationTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NotificationScreen(),
                      ),
                    );
                  },
                ),

                // Health Overview Cards
                _buildHealthOverview(context, model),

                // Pre-approval Summary
                const SizedBox(height: 20),
                const PreApprovalSummaryCard(),

                // Recent Medical History
                _buildRecentHistory(context, model),

                // Active Care Section
                _buildActiveCare(context, model),

                // Medicine Reminders Section
                _buildMedicineReminders(context, model),

                // Test Checkups Section
                _buildTestCheckups(context, model),

                // Smart Recommendations
                _buildRecommendations(context, model),

                // Quick Actions
                _buildQuickActions(context, model),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          title: Text('Dashboard'),
          actions: [
            IconButton(
              icon: Icon(Icons.medical_information),
              tooltip: 'Health Records',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const HealthRecordsScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.compare_arrows),
              tooltip: 'Compare Services',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ComparisonScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthOverview(BuildContext context, DashboardViewModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: HealthOverviewCard(
                  title: 'Total Savings',
                  value: model.formatCurrency(model.totalSavings),
                  subtitle: 'This year',
                  icon: Icons.savings,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: HealthOverviewCard(
                  title: 'Health Score',
                  value: '${model.healthScore.toInt()}%',
                  subtitle: 'Excellent',
                  icon: Icons.favorite,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: HealthOverviewCard(
                  title: 'Visits This Month',
                  value: '${model.visitsThisMonth}',
                  subtitle: '${model.visitsThisYear} total this year',
                  icon: Icons.calendar_month,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: HealthOverviewCard(
                  title: 'Insurance',
                  value: model.hasInsurance ? 'Active' : 'Inactive',
                  subtitle: 'Coverage status',
                  icon: Icons.security,
                  color: model.hasInsurance ? AppColors.accent : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHistory(BuildContext context, DashboardViewModel model) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Medical History',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: model.recentVisits.length,
            itemBuilder: (context, index) {
              return RecentVisitCard(
                visit: model.recentVisits[index],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCare(BuildContext context, DashboardViewModel model) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Care',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
          ),
          const SizedBox(height: 12),

          // Medications
          if (model.activeMedications.isNotEmpty) ...[
            Text(
              'Current Medications',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: model.activeMedications.length,
              itemBuilder: (context, index) {
                return MedicationCard(
                  medication: model.activeMedications[index],
                  onRefill: () => model.refillMedication(index),
                );
              },
            ),
            const SizedBox(height: 16),
          ],

          // Ongoing Treatments
          if (model.ongoingTreatments.isNotEmpty) ...[
            Text(
              'Ongoing Treatments',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: model.ongoingTreatments.length,
              itemBuilder: (context, index) {
                final treatment = model.ongoingTreatments[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              treatment['type'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                treatment['sessions'],
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: treatment['progress'],
                          backgroundColor: Colors.grey[300],
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Next: ${treatment['nextSession']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicineReminders(
      BuildContext context, DashboardViewModel model) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Medicine Reminders',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MedicineRemindersScreen(),
                    ),
                  );
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.medication,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medicine Reminder System',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Never miss your medication again! Set up personalized reminders.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MedicineRemindersScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Setup'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCheckups(BuildContext context, DashboardViewModel model) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Test Checkups',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TestCheckupsScreen(),
                    ),
                  );
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Filter chips
          Container(
            height: 35,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: model.testFilterOptions.length,
              itemBuilder: (context, index) {
                final filter = model.testFilterOptions[index];
                final isSelected = model.selectedTestFilter == filter;
                final count = model.getTestCheckupCount(filter);

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(
                      '$filter${count > 0 ? ' ($count)' : ''}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      model.setTestFilter(filter);
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color:
                            isSelected ? AppColors.primary : Colors.grey[300]!,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Test checkup list
          Container(
            constraints: BoxConstraints(maxHeight: 300),
            child: model.getFilteredTestCheckups().isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.science_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No ${model.selectedTestFilter.toLowerCase()} test checkups',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: model.getFilteredTestCheckups().length,
                    itemBuilder: (context, index) {
                      final testCheckup =
                          model.getFilteredTestCheckups()[index];
                      return _buildTestCheckupCard(testCheckup);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCheckupCard(testCheckup) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTypeColor(testCheckup.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTypeIcon(testCheckup.type),
                  color: _getTypeColor(testCheckup.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testCheckup.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      testCheckup.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(testCheckup.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  testCheckup.statusDisplayName,
                  style: TextStyle(
                    color: _getStatusColor(testCheckup.status),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                testCheckup.formattedDateTime,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              if (testCheckup.estimatedCost != null) ...[
                Icon(Icons.currency_rupee, size: 14, color: Colors.grey[600]),
                Text(
                  '${testCheckup.estimatedCost!.toInt()}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          if (testCheckup.location != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  testCheckup.location!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getTypeColor(type) {
    switch (type.toString()) {
      case 'TestCheckupType.bloodTest':
        return Colors.red;
      case 'TestCheckupType.xRay':
        return Colors.blue;
      case 'TestCheckupType.mri':
        return Colors.purple;
      case 'TestCheckupType.physicalExam':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }

  IconData _getTypeIcon(type) {
    switch (type.toString()) {
      case 'TestCheckupType.bloodTest':
        return Icons.bloodtype;
      case 'TestCheckupType.xRay':
        return Icons.medical_services;
      case 'TestCheckupType.mri':
        return Icons.scanner;
      case 'TestCheckupType.physicalExam':
        return Icons.health_and_safety;
      default:
        return Icons.science;
    }
  }

  Color _getStatusColor(status) {
    switch (status.toString()) {
      case 'TestCheckupStatus.scheduled':
        return Colors.blue;
      case 'TestCheckupStatus.completed':
        return Colors.green;
      case 'TestCheckupStatus.cancelled':
        return Colors.red;
      case 'TestCheckupStatus.overdue':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRecommendations(BuildContext context, DashboardViewModel model) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Smart Recommendations',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: model.recommendations.length,
            itemBuilder: (context, index) {
              return RecommendationCard(
                recommendation: model.recommendations[index],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, DashboardViewModel model) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: model.quickActions.length,
            itemBuilder: (context, index) {
              return QuickActionCard(
                action: model.quickActions[index],
              );
            },
          ),
        ],
      ),
    );
  }
}
