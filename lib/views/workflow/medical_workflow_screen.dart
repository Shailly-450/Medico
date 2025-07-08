import 'package:flutter/material.dart';
import '../../models/medical_workflow.dart';
import '../../core/services/workflow_service.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/workflow_stage_card.dart';
import 'widgets/workflow_timeline.dart';
import 'widgets/workflow_header.dart';
import 'widgets/workflow_progress_bar.dart';

class MedicalWorkflowScreen extends StatefulWidget {
  final String? workflowId;
  final String? patientId;

  const MedicalWorkflowScreen({
    Key? key,
    this.workflowId,
    this.patientId,
  }) : super(key: key);

  @override
  State<MedicalWorkflowScreen> createState() => _MedicalWorkflowScreenState();
}

class _MedicalWorkflowScreenState extends State<MedicalWorkflowScreen>
    with TickerProviderStateMixin {
  final WorkflowService _workflowService = WorkflowService();
  late TabController _tabController;
  MedicalWorkflow? selectedWorkflow;
  List<MedicalWorkflow> workflows = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadWorkflows();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadWorkflows() {
    setState(() {
      isLoading = true;
    });

    // Initialize mock data if needed
    _workflowService.initializeMockData();

    if (widget.workflowId != null) {
      selectedWorkflow = _workflowService.getWorkflowById(widget.workflowId!);
    } else if (widget.patientId != null) {
      workflows = _workflowService.getWorkflowsByPatient(widget.patientId!);
      if (workflows.isNotEmpty) {
        selectedWorkflow = workflows.first;
      }
    } else {
      workflows = _workflowService.workflows;
      if (workflows.isNotEmpty) {
        selectedWorkflow = workflows.first;
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  void _selectWorkflow(MedicalWorkflow workflow) {
    setState(() {
      selectedWorkflow = workflow;
    });
  }

  Future<void> _advanceStage() async {
    if (selectedWorkflow == null) return;

    final success = await _workflowService.advanceToNextStage(
      selectedWorkflow!.id,
      notes: 'Stage completed successfully',
    );

    if (success) {
      _loadWorkflows();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stage advanced successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Widget _buildWorkflowsList() {
    if (workflows.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Workflows Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create a new workflow to get started',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: workflows.length,
      itemBuilder: (context, index) {
        final workflow = workflows[index];
        final isSelected = selectedWorkflow?.id == workflow.id;

        return Card(
          elevation: isSelected ? 4 : 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _selectWorkflow(workflow),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workflow.patientName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              workflow.condition,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (workflow.isUrgent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red),
                          ),
                          child: const Text(
                            'URGENT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  WorkflowProgressBar(workflow: workflow),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _getStageIcon(workflow.currentStage),
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStageTitle(workflow.currentStage),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${workflow.completedStages.length}/${workflow.stages.length} Completed',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkflowDetails() {
    if (selectedWorkflow == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Select a Workflow',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Choose a workflow from the list to view details',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WorkflowHeader(workflow: selectedWorkflow!),
          const SizedBox(height: 24),
          WorkflowTimeline(workflow: selectedWorkflow!),
          const SizedBox(height: 24),
          _buildStagesList(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStagesList() {
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
        ...selectedWorkflow!.stages.map((stage) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: WorkflowStageCard(
              stage: stage,
              onStatusUpdate: (status) => _updateStageStatus(stage.id, status),
              onAdvance: stage.status == WorkflowStatus.inProgress
                  ? _advanceStage
                  : null,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildActionButtons() {
    final canAdvance = selectedWorkflow?.currentStageData != null;
    final isCompleted = selectedWorkflow?.isCompleted ?? false;

    return Column(
      children: [
        if (!isCompleted && canAdvance)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _advanceStage,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Advance to Next Stage'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showAddNoteDialog(),
                icon: const Icon(Icons.note_add),
                label: const Text('Add Note'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showScheduleDialog(),
                icon: const Icon(Icons.schedule),
                label: const Text('Schedule'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _updateStageStatus(String stageId, WorkflowStatus status) async {
    if (selectedWorkflow == null) return;

    final success = await _workflowService.updateStageStatus(
      selectedWorkflow!.id,
      stageId,
      status,
    );

    if (success) {
      _loadWorkflows();
    }
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Enter your note...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Add Note'),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Appointment'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Time',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.access_time),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  IconData _getStageIcon(WorkflowStage stage) {
    switch (stage) {
      case WorkflowStage.consultation:
        return Icons.medical_services;
      case WorkflowStage.testing:
        return Icons.science;
      case WorkflowStage.surgery:
        return Icons.local_hospital;
      case WorkflowStage.completed:
        return Icons.check_circle;
      default:
        return Icons.medical_services;
    }
  }

  String _getStageTitle(WorkflowStage stage) {
    switch (stage) {
      case WorkflowStage.consultation:
        return 'Consultation';
      case WorkflowStage.testing:
        return 'Testing';
      case WorkflowStage.surgery:
        return 'Surgery';
      case WorkflowStage.completed:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Workflows'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Workflows'),
            Tab(text: 'Details'),
            Tab(text: 'Timeline'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showCreateWorkflowDialog(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWorkflowsList(),
          _buildWorkflowDetails(),
          selectedWorkflow != null
              ? WorkflowTimeline(workflow: selectedWorkflow!)
              : const Center(child: Text('Select a workflow to view timeline')),
        ],
      ),
    );
  }

  void _showCreateWorkflowDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Workflow'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Patient Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Condition',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Primary Doctor',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Create workflow logic here
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
