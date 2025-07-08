import 'package:flutter/material.dart';
import '../../core/services/workflow_service.dart';
import '../../core/theme/app_colors.dart';
import 'medical_workflow_screen.dart';

class WorkflowDemoScreen extends StatefulWidget {
  const WorkflowDemoScreen({Key? key}) : super(key: key);

  @override
  State<WorkflowDemoScreen> createState() => _WorkflowDemoScreenState();
}

class _WorkflowDemoScreenState extends State<WorkflowDemoScreen> {
  final WorkflowService _workflowService = WorkflowService();

  final List<Map<String, dynamic>> _demoScenarios = [
    {
      'title': 'Cardiac Assessment',
      'description':
          'Complete cardiac evaluation with consultation, tests, and potential surgery',
      'patient': 'John Doe',
      'doctor': 'Dr. Sarah Johnson',
      'isUrgent': false,
      'includeSurgery': true,
      'condition': 'Cardiac Assessment',
      'icon': Icons.favorite,
      'color': Colors.red,
    },
    {
      'title': 'Knee Surgery',
      'description':
          'Orthopedic consultation, imaging tests, and surgical procedure',
      'patient': 'Jane Smith',
      'doctor': 'Dr. Michael Chen',
      'isUrgent': true,
      'includeSurgery': true,
      'condition': 'Knee Surgery',
      'icon': Icons.accessibility,
      'color': Colors.orange,
    },
    {
      'title': 'Diabetes Management',
      'description':
          'Consultation and diagnostic tests without surgical intervention',
      'patient': 'Robert Wilson',
      'doctor': 'Dr. Emily Davis',
      'isUrgent': false,
      'includeSurgery': false,
      'condition': 'Diabetes Management',
      'icon': Icons.medical_services,
      'color': Colors.blue,
    },
    {
      'title': 'Cancer Screening',
      'description':
          'Comprehensive screening with multiple tests and follow-up procedures',
      'patient': 'Maria Garcia',
      'doctor': 'Dr. James Wilson',
      'isUrgent': true,
      'includeSurgery': true,
      'condition': 'Cancer Screening',
      'icon': Icons.health_and_safety,
      'color': Colors.purple,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize workflow service with mock data
    _workflowService.initializeMockData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workflow Demo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MedicalWorkflowScreen(),
              ),
            ),
            icon: const Icon(Icons.timeline),
            tooltip: 'View All Workflows',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildStagesOverview(),
            const SizedBox(height: 24),
            _buildDemoScenarios(),
            const SizedBox(height: 24),
            _buildExistingWorkflows(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.timeline,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medical Workflow System',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Streamlined patient journey management',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'This system manages patient journeys through three main stages: Consultation, Testing, and Surgery. Each workflow is customized based on the patient\'s condition and treatment requirements.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStagesOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Workflow Stages',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildStageCard(
                    'Consult', Icons.medical_services, Colors.blue, '1')),
            const SizedBox(width: 12),
            Expanded(
                child:
                    _buildStageCard('Test', Icons.science, Colors.green, '2')),
            const SizedBox(width: 12),
            Expanded(
                child: _buildStageCard(
                    'Surgery', Icons.local_hospital, Colors.red, '3')),
          ],
        ),
      ],
    );
  }

  Widget _buildStageCard(
      String title, IconData icon, Color color, String step) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      step,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Icon(icon, color: color, size: 24),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoScenarios() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Demo Scenarios',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Create new workflows for different medical conditions',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        ..._demoScenarios
            .map((scenario) => _buildDemoScenarioCard(scenario))
            .toList(),
      ],
    );
  }

  Widget _buildDemoScenarioCard(Map<String, dynamic> scenario) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _createDemoWorkflow(scenario),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scenario['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  scenario['icon'],
                  color: scenario['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            scenario['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (scenario['isUrgent'])
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red),
                            ),
                            child: const Text(
                              'URGENT',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scenario['description'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          scenario['patient'],
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.medical_services,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          scenario['doctor'],
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExistingWorkflows() {
    final workflows = _workflowService.workflows;
    final stats = _workflowService.getWorkflowStatistics();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Existing Workflows',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MedicalWorkflowScreen(),
                ),
              ),
              icon: const Icon(Icons.timeline),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total',
                stats['total'].toString(),
                Icons.timeline,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'In Progress',
                stats['inProgress'].toString(),
                Icons.play_circle,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Completed',
                stats['completed'].toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createDemoWorkflow(Map<String, dynamic> scenario) async {
    try {
      final workflow = await _workflowService.createWorkflow(
        patientId: 'patient_${DateTime.now().millisecondsSinceEpoch}',
        patientName: scenario['patient'],
        condition: scenario['condition'],
        primaryDoctorId: 'doc_${DateTime.now().millisecondsSinceEpoch}',
        primaryDoctorName: scenario['doctor'],
        isUrgent: scenario['isUrgent'],
        includeSurgery: scenario['includeSurgery'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Workflow created for ${scenario['patient']}'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MedicalWorkflowScreen(
                    workflowId: workflow.id,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating workflow: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
