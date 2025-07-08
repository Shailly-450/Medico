import 'package:flutter/material.dart';
import '../../models/medical_workflow.dart';

class WorkflowService {
  // Singleton instance
  static final WorkflowService _instance = WorkflowService._internal();
  factory WorkflowService() => _instance;
  WorkflowService._internal();

  // Mock storage for workflows
  final List<MedicalWorkflow> _workflows = [];

  // Get all workflows
  List<MedicalWorkflow> get workflows => List.unmodifiable(_workflows);

  // Get workflow by ID
  MedicalWorkflow? getWorkflowById(String id) {
    try {
      return _workflows.firstWhere((workflow) => workflow.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get workflows by patient ID
  List<MedicalWorkflow> getWorkflowsByPatient(String patientId) {
    return _workflows
        .where((workflow) => workflow.patientId == patientId)
        .toList();
  }

  // Create a new medical workflow
  Future<MedicalWorkflow> createWorkflow({
    required String patientId,
    required String patientName,
    required String condition,
    required String primaryDoctorId,
    required String primaryDoctorName,
    bool includeConsultation = true,
    bool includeTesting = true,
    bool includeSurgery = true,
    bool isUrgent = false,
  }) async {
    final workflowId = 'WF${DateTime.now().millisecondsSinceEpoch}';

    // Create stages based on requirements
    final stages = <WorkflowStageData>[];
    int order = 0;

    // Consultation Stage
    if (includeConsultation) {
      stages.add(WorkflowStageData(
        id: '${workflowId}_consultation',
        type: StageType.consultation,
        title: 'Initial Consultation',
        description: 'Initial assessment and diagnosis with primary doctor',
        status: WorkflowStatus.pending,
        doctorId: primaryDoctorId,
        doctorName: primaryDoctorName,
        requirements: [
          'Medical history review',
          'Physical examination',
          'Symptom assessment',
          'Treatment plan discussion',
        ],
        order: order++,
      ));
    }

    // Testing Stage
    if (includeTesting) {
      stages.addAll([
        WorkflowStageData(
          id: '${workflowId}_lab_tests',
          type: StageType.labTest,
          title: 'Laboratory Tests',
          description: 'Blood tests, urine analysis, and other lab work',
          status: WorkflowStatus.pending,
          requirements: [
            'Fasting requirements (if applicable)',
            'Previous test results',
            'Insurance pre-authorization',
          ],
          order: order++,
        ),
        WorkflowStageData(
          id: '${workflowId}_imaging',
          type: StageType.imaging,
          title: 'Medical Imaging',
          description: 'X-rays, CT scans, MRI, or ultrasound as needed',
          status: WorkflowStatus.pending,
          requirements: [
            'Remove metal objects',
            'Contrast allergies check',
            'Preparation instructions',
          ],
          order: order++,
        ),
      ]);
    }

    // Surgery Stage
    if (includeSurgery) {
      stages.addAll([
        WorkflowStageData(
          id: '${workflowId}_pre_surgery',
          type: StageType.procedure,
          title: 'Pre-Surgery Consultation',
          description: 'Pre-operative assessment and preparation',
          status: WorkflowStatus.pending,
          requirements: [
            'Anesthesia consultation',
            'Pre-operative tests',
            'Surgical consent',
            'Pre-surgery instructions',
          ],
          order: order++,
        ),
        WorkflowStageData(
          id: '${workflowId}_surgery',
          type: StageType.surgery,
          title: 'Surgical Procedure',
          description: 'Main surgical intervention',
          status: WorkflowStatus.pending,
          requirements: [
            'Fasting requirements',
            'Arrival time compliance',
            'Support person arrangement',
            'Post-surgery care plan',
          ],
          order: order++,
        ),
        WorkflowStageData(
          id: '${workflowId}_post_surgery',
          type: StageType.followUp,
          title: 'Post-Surgery Follow-up',
          description: 'Recovery monitoring and follow-up care',
          status: WorkflowStatus.pending,
          requirements: [
            'Wound care instructions',
            'Medication compliance',
            'Activity restrictions',
            'Follow-up appointments',
          ],
          order: order++,
        ),
      ]);
    }

    // Set first stage to in progress
    if (stages.isNotEmpty) {
      stages[0] = stages[0].copyWith(status: WorkflowStatus.inProgress);
    }

    final workflow = MedicalWorkflow(
      id: workflowId,
      patientId: patientId,
      patientName: patientName,
      condition: condition,
      primaryDoctorId: primaryDoctorId,
      primaryDoctorName: primaryDoctorName,
      currentStage: WorkflowStage.consultation,
      overallStatus: WorkflowStatus.inProgress,
      createdDate: DateTime.now(),
      lastUpdated: DateTime.now(),
      stages: stages,
      isUrgent: isUrgent,
    );

    _workflows.add(workflow);
    return workflow;
  }

  // Advance to next stage
  Future<bool> advanceToNextStage(
    String workflowId, {
    String? notes,
    Map<String, dynamic>? results,
  }) async {
    final workflow = getWorkflowById(workflowId);
    if (workflow == null) return false;

    // Find current stage
    final currentStageIndex = workflow.stages.indexWhere(
      (stage) => stage.status == WorkflowStatus.inProgress,
    );

    if (currentStageIndex == -1) return false;

    // Complete current stage
    final updatedStages = List<WorkflowStageData>.from(workflow.stages);
    updatedStages[currentStageIndex] =
        updatedStages[currentStageIndex].copyWith(
      status: WorkflowStatus.completed,
      completedDate: DateTime.now(),
      results: results,
      notes: notes != null
          ? [...updatedStages[currentStageIndex].notes, notes]
          : updatedStages[currentStageIndex].notes,
    );

    // Start next stage if available
    WorkflowStage newCurrentStage = workflow.currentStage;
    WorkflowStatus newOverallStatus = workflow.overallStatus;

    if (currentStageIndex < updatedStages.length - 1) {
      // Move to next stage
      updatedStages[currentStageIndex + 1] =
          updatedStages[currentStageIndex + 1]
              .copyWith(status: WorkflowStatus.inProgress);

      // Update current stage based on next stage type
      final nextStageType = updatedStages[currentStageIndex + 1].type;
      if (nextStageType == StageType.labTest ||
          nextStageType == StageType.imaging) {
        newCurrentStage = WorkflowStage.testing;
      } else if (nextStageType == StageType.surgery ||
          nextStageType == StageType.procedure) {
        newCurrentStage = WorkflowStage.surgery;
      }
    } else {
      // All stages completed
      newCurrentStage = WorkflowStage.completed;
      newOverallStatus = WorkflowStatus.completed;
    }

    // Update workflow
    final updatedWorkflow = workflow.copyWith(
      stages: updatedStages,
      currentStage: newCurrentStage,
      overallStatus: newOverallStatus,
      lastUpdated: DateTime.now(),
    );

    // Replace in list
    final workflowIndex = _workflows.indexWhere((w) => w.id == workflowId);
    if (workflowIndex != -1) {
      _workflows[workflowIndex] = updatedWorkflow;
    }

    return true;
  }

  // Update stage status
  Future<bool> updateStageStatus(
    String workflowId,
    String stageId,
    WorkflowStatus status, {
    DateTime? scheduledDate,
    String? doctorId,
    String? doctorName,
    String? location,
    double? cost,
    String? notes,
  }) async {
    final workflow = getWorkflowById(workflowId);
    if (workflow == null) return false;

    final stageIndex =
        workflow.stages.indexWhere((stage) => stage.id == stageId);
    if (stageIndex == -1) return false;

    final updatedStages = List<WorkflowStageData>.from(workflow.stages);
    updatedStages[stageIndex] = updatedStages[stageIndex].copyWith(
      status: status,
      scheduledDate: scheduledDate ?? updatedStages[stageIndex].scheduledDate,
      doctorId: doctorId ?? updatedStages[stageIndex].doctorId,
      doctorName: doctorName ?? updatedStages[stageIndex].doctorName,
      location: location ?? updatedStages[stageIndex].location,
      cost: cost ?? updatedStages[stageIndex].cost,
      notes: notes != null
          ? [...updatedStages[stageIndex].notes, notes]
          : updatedStages[stageIndex].notes,
    );

    final updatedWorkflow = workflow.copyWith(
      stages: updatedStages,
      lastUpdated: DateTime.now(),
    );

    final workflowIndex = _workflows.indexWhere((w) => w.id == workflowId);
    if (workflowIndex != -1) {
      _workflows[workflowIndex] = updatedWorkflow;
    }

    return true;
  }

  // Get workflows by stage
  List<MedicalWorkflow> getWorkflowsByStage(WorkflowStage stage) {
    return _workflows
        .where((workflow) => workflow.currentStage == stage)
        .toList();
  }

  // Get urgent workflows
  List<MedicalWorkflow> getUrgentWorkflows() {
    return _workflows.where((workflow) => workflow.isUrgent).toList();
  }

  // Calculate total cost for workflow
  double calculateWorkflowCost(String workflowId) {
    final workflow = getWorkflowById(workflowId);
    if (workflow == null) return 0.0;

    return workflow.stages
        .where((stage) => stage.cost != null)
        .fold(0.0, (sum, stage) => sum + (stage.cost ?? 0.0));
  }

  // Get workflow statistics
  Map<String, dynamic> getWorkflowStatistics() {
    final total = _workflows.length;
    final completed = _workflows
        .where((w) => w.overallStatus == WorkflowStatus.completed)
        .length;
    final inProgress = _workflows
        .where((w) => w.overallStatus == WorkflowStatus.inProgress)
        .length;
    final urgent = _workflows.where((w) => w.isUrgent).length;

    return {
      'total': total,
      'completed': completed,
      'inProgress': inProgress,
      'urgent': urgent,
      'completionRate': total > 0 ? (completed / total * 100) : 0.0,
    };
  }

  // Initialize with mock data
  void initializeMockData() {
    if (_workflows.isNotEmpty) return;

    // Create sample workflows
    createWorkflow(
      patientId: 'patient_001',
      patientName: 'John Doe',
      condition: 'Cardiac Assessment',
      primaryDoctorId: 'doc_001',
      primaryDoctorName: 'Dr. Sarah Johnson',
      isUrgent: false,
    );

    createWorkflow(
      patientId: 'patient_002',
      patientName: 'Jane Smith',
      condition: 'Knee Surgery',
      primaryDoctorId: 'doc_002',
      primaryDoctorName: 'Dr. Michael Chen',
      isUrgent: true,
    );

    createWorkflow(
      patientId: 'patient_003',
      patientName: 'Robert Wilson',
      condition: 'Diabetes Management',
      primaryDoctorId: 'doc_003',
      primaryDoctorName: 'Dr. Emily Davis',
      includeSurgery: false,
      isUrgent: false,
    );
  }

  // Get stage icon
  IconData getStageIcon(StageType type) {
    switch (type) {
      case StageType.consultation:
        return Icons.medical_services;
      case StageType.diagnosticTest:
        return Icons.science;
      case StageType.labTest:
        return Icons.biotech;
      case StageType.imaging:
        return Icons.medical_information;
      case StageType.procedure:
        return Icons.healing;
      case StageType.surgery:
        return Icons.local_hospital;
      case StageType.followUp:
        return Icons.follow_the_signs;
      default:
        return Icons.medical_services;
    }
  }

  // Get stage color
  Color getStageColor(StageType type) {
    switch (type) {
      case StageType.consultation:
        return Colors.blue;
      case StageType.diagnosticTest:
      case StageType.labTest:
        return Colors.green;
      case StageType.imaging:
        return Colors.purple;
      case StageType.procedure:
      case StageType.surgery:
        return Colors.red;
      case StageType.followUp:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Get status color
  Color getStatusColor(WorkflowStatus status) {
    switch (status) {
      case WorkflowStatus.pending:
        return Colors.grey;
      case WorkflowStatus.inProgress:
        return Colors.blue;
      case WorkflowStatus.completed:
        return Colors.green;
      case WorkflowStatus.cancelled:
        return Colors.red;
      case WorkflowStatus.onHold:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
