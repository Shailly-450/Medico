import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/journey_stage.dart';

class JourneyTrackerViewModel extends BaseViewModel {
  List<MedicalJourney> _journeys = [];
  MedicalJourney? _selectedJourney;
  bool _isLoading = false;
  String? _errorMessage;

  List<MedicalJourney> get journeys => _journeys;
  MedicalJourney? get selectedJourney => _selectedJourney;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isBusy => busy;

  @override
  void init() {
    super.init();
    _loadJourneys();
  }

  Future<void> _loadJourneys() async {
    setBusy(true);
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Mock data for demonstration
      _journeys = _generateMockJourneys();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load journeys: ${e.toString()}';
    } finally {
      setBusy(false);
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectJourney(MedicalJourney journey) {
    _selectedJourney = journey;
    notifyListeners();
  }

  Future<void> updateStageStatus(
    String journeyId, 
    String stageId, 
    JourneyStatus status
  ) async {
    try {
      final journeyIndex = _journeys.indexWhere((j) => j.id == journeyId);
      if (journeyIndex == -1) return;

      final journey = _journeys[journeyIndex];
      final stageIndex = journey.stages.indexWhere((s) => s.id == stageId);
      if (stageIndex == -1) return;

      final updatedStage = journey.stages[stageIndex].copyWith(
        status: status,
        startDate: status == JourneyStatus.inProgress 
            ? DateTime.now() 
            : journey.stages[stageIndex].startDate,
        completedDate: status == JourneyStatus.completed 
            ? DateTime.now() 
            : journey.stages[stageIndex].completedDate,
      );

      final updatedStages = List<JourneyStage>.from(journey.stages);
      updatedStages[stageIndex] = updatedStage;

      final updatedJourney = MedicalJourney(
        id: journey.id,
        patientId: journey.patientId,
        title: journey.title,
        description: journey.description,
        createdAt: journey.createdAt,
        completedAt: journey.completedAt,
        stages: updatedStages,
        doctorId: journey.doctorId,
        hospitalId: journey.hospitalId,
        metadata: journey.metadata,
      );

      _journeys[journeyIndex] = updatedJourney;
      
      if (_selectedJourney?.id == journeyId) {
        _selectedJourney = updatedJourney;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update stage status: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> addNoteToStage(
    String journeyId, 
    String stageId, 
    String note
  ) async {
    try {
      final journeyIndex = _journeys.indexWhere((j) => j.id == journeyId);
      if (journeyIndex == -1) return;

      final journey = _journeys[journeyIndex];
      final stageIndex = journey.stages.indexWhere((s) => s.id == stageId);
      if (stageIndex == -1) return;

      final updatedStage = journey.stages[stageIndex].copyWith(
        notes: note,
      );

      final updatedStages = List<JourneyStage>.from(journey.stages);
      updatedStages[stageIndex] = updatedStage;

      final updatedJourney = MedicalJourney(
        id: journey.id,
        patientId: journey.patientId,
        title: journey.title,
        description: journey.description,
        createdAt: journey.createdAt,
        completedAt: journey.completedAt,
        stages: updatedStages,
        doctorId: journey.doctorId,
        hospitalId: journey.hospitalId,
        metadata: journey.metadata,
      );

      _journeys[journeyIndex] = updatedJourney;
      
      if (_selectedJourney?.id == journeyId) {
        _selectedJourney = updatedJourney;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add note: ${e.toString()}';
      notifyListeners();
    }
  }

  List<MedicalJourney> _generateMockJourneys() {
    return [
      MedicalJourney(
        id: 'journey_1',
        patientId: 'patient_1',
        title: 'Cardiac Surgery Journey',
        description: 'Complete cardiac surgery treatment plan',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        stages: [
          JourneyStage(
            id: 'stage_1',
            type: JourneyStageType.consult,
            title: 'Initial Consultation',
            description: 'Meet with cardiologist for initial assessment',
            status: JourneyStatus.completed,
            startDate: DateTime.now().subtract(const Duration(days: 28)),
            completedDate: DateTime.now().subtract(const Duration(days: 25)),
            notes: 'Patient shows symptoms of coronary artery disease. Recommended further testing.',
          ),
          JourneyStage(
            id: 'stage_2',
            type: JourneyStageType.test,
            title: 'Cardiac Tests',
            description: 'Complete blood work, ECG, and stress test',
            status: JourneyStatus.inProgress,
            startDate: DateTime.now().subtract(const Duration(days: 20)),
            notes: 'Blood work completed. ECG scheduled for tomorrow.',
          ),
          JourneyStage(
            id: 'stage_3',
            type: JourneyStageType.surgery,
            title: 'Coronary Bypass Surgery',
            description: 'Surgical procedure to improve blood flow to heart',
            status: JourneyStatus.notStarted,
          ),
        ],
        doctorId: 'doctor_1',
        hospitalId: 'hospital_1',
      ),
      MedicalJourney(
        id: 'journey_2',
        patientId: 'patient_1',
        title: 'Orthopedic Treatment',
        description: 'Knee replacement surgery journey',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        completedAt: DateTime.now().subtract(const Duration(days: 10)),
        stages: [
          JourneyStage(
            id: 'stage_4',
            type: JourneyStageType.consult,
            title: 'Orthopedic Consultation',
            description: 'Initial consultation with orthopedic surgeon',
            status: JourneyStatus.completed,
            startDate: DateTime.now().subtract(const Duration(days: 55)),
            completedDate: DateTime.now().subtract(const Duration(days: 52)),
            notes: 'Severe osteoarthritis confirmed. Surgery recommended.',
          ),
          JourneyStage(
            id: 'stage_5',
            type: JourneyStageType.test,
            title: 'Pre-surgery Tests',
            description: 'Complete pre-operative testing and clearance',
            status: JourneyStatus.completed,
            startDate: DateTime.now().subtract(const Duration(days: 45)),
            completedDate: DateTime.now().subtract(const Duration(days: 42)),
            notes: 'All tests passed. Patient cleared for surgery.',
          ),
          JourneyStage(
            id: 'stage_6',
            type: JourneyStageType.surgery,
            title: 'Knee Replacement Surgery',
            description: 'Total knee replacement procedure',
            status: JourneyStatus.completed,
            startDate: DateTime.now().subtract(const Duration(days: 15)),
            completedDate: DateTime.now().subtract(const Duration(days: 12)),
            notes: 'Surgery successful. Patient recovering well.',
          ),
        ],
        doctorId: 'doctor_2',
        hospitalId: 'hospital_2',
      ),
      MedicalJourney(
        id: 'journey_3',
        patientId: 'patient_1',
        title: 'Dental Treatment',
        description: 'Comprehensive dental care plan',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        stages: [
          JourneyStage(
            id: 'stage_7',
            type: JourneyStageType.consult,
            title: 'Dental Consultation',
            description: 'Initial dental examination and treatment plan',
            status: JourneyStatus.completed,
            startDate: DateTime.now().subtract(const Duration(days: 8)),
            completedDate: DateTime.now().subtract(const Duration(days: 6)),
            notes: 'Multiple cavities detected. Root canal needed.',
          ),
          JourneyStage(
            id: 'stage_8',
            type: JourneyStageType.test,
            title: 'Dental X-rays',
            description: 'Complete dental imaging and assessment',
            status: JourneyStatus.notStarted,
          ),
          JourneyStage(
            id: 'stage_9',
            type: JourneyStageType.surgery,
            title: 'Root Canal Treatment',
            description: 'Endodontic treatment for infected tooth',
            status: JourneyStatus.notStarted,
          ),
        ],
        doctorId: 'doctor_3',
        hospitalId: 'hospital_3',
      ),
    ];
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> updateStage(
    String journeyId,
    JourneyStage updatedStage,
  ) async {
    try {
      final journeyIndex = _journeys.indexWhere((j) => j.id == journeyId);
      if (journeyIndex == -1) return;

      final journey = _journeys[journeyIndex];
      final stageIndex = journey.stages.indexWhere((s) => s.id == updatedStage.id);
      if (stageIndex == -1) return;

      final updatedStages = List<JourneyStage>.from(journey.stages);
      updatedStages[stageIndex] = updatedStage;

      final updatedJourney = MedicalJourney(
        id: journey.id,
        patientId: journey.patientId,
        title: journey.title,
        description: journey.description,
        createdAt: journey.createdAt,
        completedAt: journey.completedAt,
        stages: updatedStages,
        doctorId: journey.doctorId,
        hospitalId: journey.hospitalId,
        metadata: journey.metadata,
      );

      _journeys[journeyIndex] = updatedJourney;
      
      if (_selectedJourney?.id == journeyId) {
        _selectedJourney = updatedJourney;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update stage: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> deleteStage(
    String journeyId,
    String stageId,
  ) async {
    try {
      final journeyIndex = _journeys.indexWhere((j) => j.id == journeyId);
      if (journeyIndex == -1) return;

      final journey = _journeys[journeyIndex];
      final updatedStages = journey.stages.where((s) => s.id != stageId).toList();

      final updatedJourney = MedicalJourney(
        id: journey.id,
        patientId: journey.patientId,
        title: journey.title,
        description: journey.description,
        createdAt: journey.createdAt,
        completedAt: journey.completedAt,
        stages: updatedStages,
        doctorId: journey.doctorId,
        hospitalId: journey.hospitalId,
        metadata: journey.metadata,
      );

      _journeys[journeyIndex] = updatedJourney;
      
      if (_selectedJourney?.id == journeyId) {
        _selectedJourney = updatedJourney;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete stage: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> reorderStages(
    String journeyId,
    List<JourneyStage> reorderedStages,
  ) async {
    try {
      final journeyIndex = _journeys.indexWhere((j) => j.id == journeyId);
      if (journeyIndex == -1) return;

      final journey = _journeys[journeyIndex];

      final updatedJourney = MedicalJourney(
        id: journey.id,
        patientId: journey.patientId,
        title: journey.title,
        description: journey.description,
        createdAt: journey.createdAt,
        completedAt: journey.completedAt,
        stages: reorderedStages,
        doctorId: journey.doctorId,
        hospitalId: journey.hospitalId,
        metadata: journey.metadata,
      );

      _journeys[journeyIndex] = updatedJourney;
      
      if (_selectedJourney?.id == journeyId) {
        _selectedJourney = updatedJourney;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to reorder stages: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> addNewStage(
    String journeyId,
    JourneyStage newStage,
  ) async {
    try {
      final journeyIndex = _journeys.indexWhere((j) => j.id == journeyId);
      if (journeyIndex == -1) return;

      final journey = _journeys[journeyIndex];
      final updatedStages = List<JourneyStage>.from(journey.stages)..add(newStage);

      final updatedJourney = MedicalJourney(
        id: journey.id,
        patientId: journey.patientId,
        title: journey.title,
        description: journey.description,
        createdAt: journey.createdAt,
        completedAt: journey.completedAt,
        stages: updatedStages,
        doctorId: journey.doctorId,
        hospitalId: journey.hospitalId,
        metadata: journey.metadata,
      );

      _journeys[journeyIndex] = updatedJourney;
      
      if (_selectedJourney?.id == journeyId) {
        _selectedJourney = updatedJourney;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add new stage: ${e.toString()}';
      notifyListeners();
    }
  }
} 