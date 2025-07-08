import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../prescriptions/prescriptions_screen.dart';
import '../health_records/health_records_screen.dart';

class PrescriptionsReportsScreen extends StatefulWidget {
  const PrescriptionsReportsScreen({Key? key}) : super(key: key);

  @override
  State<PrescriptionsReportsScreen> createState() =>
      _PrescriptionsReportsScreenState();
}

class _PrescriptionsReportsScreenState extends State<PrescriptionsReportsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Prescriptions & Reports',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.medication),
              text: 'Prescriptions',
            ),
            Tab(
              icon: Icon(Icons.assessment),
              text: 'Reports',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPrescriptionsTab(),
          _buildReportsTab(),
        ],
      ),
    );
  }

  Widget _buildPrescriptionsTab() {
    return Column(
      children: [
        // Quick Stats Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Active',
                  '12',
                  Icons.medication_liquid,
                  Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildStatItem(
                  'Completed',
                  '34',
                  Icons.check_circle,
                  Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildStatItem(
                  'Total',
                  '46',
                  Icons.receipt_long,
                  Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Quick Actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'View All Prescriptions',
                  Icons.visibility,
                  Colors.blue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrescriptionsScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Add New Prescription',
                  Icons.add_circle,
                  Colors.green,
                  () => _showAddPrescriptionDialog(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Recent Prescriptions
        Expanded(
          child: _buildRecentPrescriptions(),
        ),
      ],
    );
  }

  Widget _buildReportsTab() {
    return Column(
      children: [
        // Quick Stats Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.teal.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Lab Reports',
                  '8',
                  Icons.science,
                  Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildStatItem(
                  'Imaging',
                  '5',
                  Icons.medical_information,
                  Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildStatItem(
                  'Total',
                  '13',
                  Icons.folder,
                  Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Quick Actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'View Health Records',
                  Icons.folder_open,
                  Colors.purple,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HealthRecordsScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Upload Report',
                  Icons.cloud_upload,
                  Colors.orange,
                  () => _showUploadReportDialog(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Recent Reports
        Expanded(
          child: _buildRecentReports(),
        ),
      ],
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentPrescriptions() {
    final prescriptions = [
      {
        'name': 'Amoxicillin 500mg',
        'doctor': 'Dr. Sarah Johnson',
        'date': '2024-01-15',
        'status': 'Active',
        'color': Colors.green,
      },
      {
        'name': 'Ibuprofen 400mg',
        'doctor': 'Dr. Michael Chen',
        'date': '2024-01-12',
        'status': 'Active',
        'color': Colors.green,
      },
      {
        'name': 'Lisinopril 10mg',
        'doctor': 'Dr. Emily Davis',
        'date': '2024-01-10',
        'status': 'Completed',
        'color': Colors.grey,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Recent Prescriptions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: prescriptions.length,
            itemBuilder: (context, index) {
              final prescription = prescriptions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (prescription['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.medication,
                      color: prescription['color'] as Color,
                    ),
                  ),
                  title: Text(
                    prescription['name'].toString(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(prescription['doctor'].toString()),
                      Text(
                        prescription['date'].toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (prescription['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      prescription['status'].toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: prescription['color'] as Color,
                      ),
                    ),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrescriptionsScreen(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentReports() {
    final reports = [
      {
        'name': 'Blood Test Results',
        'type': 'Lab Report',
        'date': '2024-01-14',
        'status': 'Normal',
        'color': Colors.green,
        'icon': Icons.science,
      },
      {
        'name': 'Chest X-Ray',
        'type': 'Imaging',
        'date': '2024-01-10',
        'status': 'Clear',
        'color': Colors.blue,
        'icon': Icons.medical_information,
      },
      {
        'name': 'ECG Report',
        'type': 'Diagnostic',
        'date': '2024-01-08',
        'status': 'Review',
        'color': Colors.orange,
        'icon': Icons.monitor_heart,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Recent Reports',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (report['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      report['icon'] as IconData,
                      color: report['color'] as Color,
                    ),
                  ),
                  title: Text(
                    report['name'].toString(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report['type'].toString()),
                      Text(
                        report['date'].toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (report['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report['status'].toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: report['color'] as Color,
                      ),
                    ),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HealthRecordsScreen(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddPrescriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Prescription'),
        content: const Text(
            'This feature will allow you to add new prescriptions to your medical records.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add prescription feature coming soon!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showUploadReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Report'),
        content: const Text(
            'This feature will allow you to upload medical reports and lab results.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Upload report feature coming soon!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }
}
