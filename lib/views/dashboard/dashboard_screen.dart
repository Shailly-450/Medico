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

                // Recent Medical History
                _buildRecentHistory(context, model),

                // Active Care Section
                _buildActiveCare(context, model),

                // Smart Recommendations
                _buildRecommendations(context, model),

                // Quick Actions
                _buildQuickActions(context, model),

                const SizedBox(height: 20),
              ],
            ),
          ),
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
                  color: Colors.green,
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
                  color: model.hasInsurance ? Colors.green : Colors.orange,
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
