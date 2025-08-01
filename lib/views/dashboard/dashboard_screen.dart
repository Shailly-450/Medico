import 'package:flutter/material.dart';
import '../../core/views/base_view.dart';
import '../../viewmodels/dashboard_view_model.dart';
import '../../core/theme/app_colors.dart';

import '../video_call/video_call_screen.dart';
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
import '../policy/policy_documents_screen.dart';
import 'widgets/pre_approval_summary_card.dart';
import 'widgets/policy_documents_card.dart';
import 'widgets/vitals_graph_section.dart';
import '../chat/chat_list_screen.dart';

import '../insurance/insurance_screen.dart';
import '../appointments/appointment_calendar_screen.dart';
import '../prescriptions/prescription_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<DashboardViewModel>(
      viewModelBuilder: () => DashboardViewModel(),
      onModelReady: (model) async {
        await model.initialize();
      },
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: null,
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
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modern Custom App Bar
                  _buildModernDashboardAppBar(context, model),

                  // Health Overview Cards - Most Important Info First
                  _buildHealthOverview(context, model),

                  // Health Tracker - Vital Signs and Metrics
                  _buildHealthTracker(context, model),

                  // Vitals Trends Graph
                  const SizedBox(height: 16),
                  const VitalsGraphSection(),

                  // Quick Actions - Easy Access to Common Tasks
                  _buildQuickActions(context, model),

                  // Pre-approval Summary - Important Status
                  const SizedBox(height: 16),
                  const PreApprovalSummaryCard(),

                  // Policy Documents - Important for Insurance
                  const SizedBox(height: 16),
                  const PolicyDocumentsCard(),

                  // Recent Medical History
                  _buildRecentHistory(context, model),

                  // Active Care Section
                  _buildActiveCare(context, model),

                  // Test Checkups Section
                  _buildTestCheckups(context, model),

                  // Smart Recommendations
                  _buildRecommendations(context, model),

                  // Add bottom padding to prevent overflow with bottom navigation
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernDashboardAppBar(
      BuildContext context, DashboardViewModel model) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2E7D32),
                  const Color(0xFF4CAF50),
                  const Color(0xFF66BB6A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 18),
          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textBlack,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Your health at a glance',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Actions
          Row(
            children: [

              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: AppColors.primary,
                ),
                tooltip: 'Refresh Dashboard',
                onPressed: () async {
                  await model.loadDashboardData();
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.medical_information,
                  color: AppColors.primary,
                ),
                tooltip: 'Health Records',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const HealthRecordsScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.compare_arrows,
                  color: AppColors.primary,
                ),
                tooltip: 'Compare Services',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ComparisonScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.video_call, color: AppColors.primary),
                tooltip: 'Test Video Calls',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const VideoCallScreen(doctorName: '', doctorSpecialty: '',),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildHealthOverview(BuildContext context, DashboardViewModel model) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Health Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: HealthOverviewCard(
                  title: 'Total Savings',
                  value: '\$${model.totalSavings.toStringAsFixed(2)}',
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

  Widget _buildHealthTracker(BuildContext context, DashboardViewModel model) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Health Tracker',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HealthRecordsScreen(),
                    ),
                  );
                },
                child: Text(
                  'View Details',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Vital Signs Section
          if (model.latestVitals != null) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Latest Vital Signs',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textBlack,
                                  ),
                        ),
                        const Spacer(),
                        Text(
                          model.formatDate(model.latestVitals!.timestamp),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildVitalSignCard(
                                context,
                                'Blood Pressure',
                                '${model.latestVitals!.bloodPressureSystolic.toInt()}/${model.latestVitals!.bloodPressureDiastolic.toInt()}',
                                'mmHg',
                                model.getVitalSignStatus('bloodPressure', {
                                  'systolic':
                                      model.latestVitals!.bloodPressureSystolic,
                                  'diastolic': model
                                      .latestVitals!.bloodPressureDiastolic,
                                }),
                                Icons.favorite,
                                Colors.red,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildVitalSignCard(
                                context,
                                'Heart Rate',
                                '${model.latestVitals!.heartRate}',
                                'bpm',
                                model.getVitalSignStatus(
                                  'heartRate',
                                  {'rate': model.latestVitals!.heartRate},
                                ),
                                Icons.favorite,
                                Colors.pink,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildVitalSignCard(
                                context,
                                'Temperature',
                                '${model.latestVitals!.temperature.toStringAsFixed(1)}',
                                '°F',
                                model.getVitalSignStatus(
                                  'temperature',
                                  {'temp': model.latestVitals!.temperature},
                                ),
                                Icons.thermostat,
                                Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildVitalSignCard(
                                context,
                                'O₂ Saturation',
                                '${model.latestVitals!.oxygenSaturation.toInt()}',
                                '%',
                                'Normal', // Simplified status for O2
                                Icons.air,
                                Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildVitalSignCard(
                                context,
                                'Weight',
                                '${model.latestVitals!.weight.toStringAsFixed(1)}',
                                'kg',
                                'Normal', // Simplified status for weight
                                Icons.monitor_weight,
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildVitalSignCard(
                                context,
                                'Blood Sugar',
                                '${model.latestVitals!.bloodSugar.toInt()}',
                                'mg/dL',
                                'Normal', // Simplified status for blood sugar
                                Icons.water_drop,
                                Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ] else ...[
            // Show placeholder when no vitals data
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                children: [
                  Icon(
                    Icons.health_and_safety,
                    color: Colors.grey[400],
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No Vital Signs Data',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your latest vital signs to track your health',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],

          // Health Metrics Section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Daily Health Metrics',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBlack,
                            ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: model.healthMetrics.map((metric) {
                      return _buildHealthMetricCard(context, metric);
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Quick Add Vital Signs Button
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to add vital signs screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add Vital Signs feature coming soon!'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add New Vital Signs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSignCard(
    BuildContext context,
    String label,
    String value,
    String unit,
    String status,
    IconData icon,
    Color color,
  ) {
    final statusColor = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: TextStyle(color: Colors.grey[600], fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetricCard(
    BuildContext context,
    Map<String, dynamic> metric,
  ) {
    final statusColor = _getStatusColor(metric['status']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (metric['color'] as Color?)?.withOpacity(0.1) ??
            Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (metric['color'] as Color?)?.withOpacity(0.1) ??
                  Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(metric['icon'] as IconData?,
                color: metric['color'] as Color?, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (metric['name'] as String?) ?? 'Unknown Metric',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${(metric['value'] as num?) ?? 0} ${(metric['unit'] as String?) ?? ''}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: metric['color'] as Color?,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'of ${(metric['target'] as num?) ?? 0}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: (metric['progress'] as num?)?.toDouble() ?? 0.0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                      (metric['color'] as Color?) ?? Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              (metric['status'] as String?)?.toUpperCase() ?? 'UNKNOWN',
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
      case 'good':
        return Colors.green;
      case 'elevated':
      case 'low':
      case 'high':
      case 'warning':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildQuickActions(BuildContext context, DashboardViewModel model) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0, // Changed from 1.4 to 1.0 for taller cards
            ),
            itemCount: model.quickActions.length,
            itemBuilder: (context, index) {
              return QuickActionCard(action: model.quickActions[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineReminders(
    BuildContext context,
    DashboardViewModel model,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.medication, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Today\'s Medicine Reminders',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                  ),
                ],
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Show actual reminders if available, otherwise show setup card
          if (model.activeMedications.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Column(
                children: model.activeMedications.take(2).map((medication) {
                  return MedicationCard(
                    medication: medication,
                    onRefill: () => model.refillMedication(
                      (medication['name'] as String?) ?? 'Unknown Medication',
                    ),
                  );
                }).toList(),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.medication, color: Colors.blue, size: 24),
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
        ],
      ),
    );
  }

  Widget _buildRecentHistory(BuildContext context, DashboardViewModel model) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.history, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Medical History',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (model.recentVisits.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: model.recentVisits.length,
                itemBuilder: (context, index) {
                  return RecentVisitCard(visit: model.recentVisits[index]);
                },
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.history, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No recent visits',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your medical history will appear here',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveCare(BuildContext context, DashboardViewModel model) {
    if (model.activeMedications.isEmpty && model.ongoingTreatments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.healing, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Active Care',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
              children: [
                // Medications
                if (model.activeMedications.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Medications',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textBlack,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        ...model.activeMedications.map((medication) {
                          return MedicationCard(
                            medication: medication,
                            onRefill: () => model.refillMedication(
                              (medication['name'] as String?) ??
                                  'Unknown Medication',
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],

                // Ongoing Treatments
                if (model.ongoingTreatments.isNotEmpty) ...[
                  if (model.activeMedications.isNotEmpty)
                    Divider(height: 1, color: Colors.grey[200]),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ongoing Treatments',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textBlack,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        ...model.ongoingTreatments.map((treatment) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey[200]!),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        (treatment['type'] as String?) ??
                                            'Unknown Treatment',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          (treatment['sessions'] as String?) ??
                                              '0/0',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: (treatment['progress'] as num?)
                                            ?.toDouble() ??
                                        0.0,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Next: ${(treatment['nextSession'] as String?) ?? 'Not scheduled'}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],

                // Active Medical Journeys
                if (model.activeJourneyStages.isNotEmpty) ...[
                  if (model.activeMedications.isNotEmpty || model.ongoingTreatments.isNotEmpty)
                    Divider(height: 1, color: Colors.grey[200]),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Medical Journeys',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textBlack,
                              ),
                        ),
                        const SizedBox(height: 8),
                        ...model.activeJourneyStages.map((stage) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey[200]!),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        stage.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          stage.status.toString().split('.').last,
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    stage.description,
                                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'Type: ${stage.type.toString().split('.').last}',
                                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                      ),
                                      const SizedBox(width: 12),
                                      if (stage.startDate != null)
                                        Text(
                                          'Started: ${stage.startDate!.toLocal().toString().split(' ')[0]}',
                                          style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCheckups(BuildContext context, DashboardViewModel model) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.science, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Test Checkups',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                  ),
                ],
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Filter chips
          SizedBox(
            height: 40,
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: model.getFilteredTestCheckups().isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
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
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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

  Widget _buildTestCheckupCard(Map<String, dynamic> testCheckup) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTypeColor(testCheckup['type']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTypeIcon(testCheckup['type']),
                  color: _getTypeColor(testCheckup['type']),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testCheckup['title'] ?? 'Unknown Test',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      testCheckup['description'] ?? 'No description available',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTestCheckupStatusColor(
                    testCheckup['status'],
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  testCheckup['statusDisplayName'] ?? 'Unknown',
                  style: TextStyle(
                    color: _getTestCheckupStatusColor(testCheckup['status']),
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
                testCheckup['formattedDateTime'] ?? 'No date',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const Spacer(),
              if (testCheckup['estimatedCost'] != null) ...[
                Icon(Icons.currency_rupee, size: 14, color: Colors.grey[600]),
                Text(
                  '${(testCheckup['estimatedCost'] as num).toInt()}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          if (testCheckup['location'] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  testCheckup['location'] as String,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
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

  Color _getTestCheckupStatusColor(status) {
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
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Smart Recommendations',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: model.recommendations.length,
              itemBuilder: (context, index) {
                return RecommendationCard(
                  recommendation: model.recommendations[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }


}
