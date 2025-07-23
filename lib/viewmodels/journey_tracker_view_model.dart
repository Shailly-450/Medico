import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/journey_stage.dart';
import '../core/services/medical_journey_service.dart';

class JourneyTrackerViewModel extends BaseViewModel {
  final MedicalJourneyService _service = MedicalJourneyService();
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
      final apiJourneys = await _service.getJourneys();
      _journeys = apiJourneys
          .map<MedicalJourney>((json) => MedicalJourney.fromJson(json))
          .toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load journeys: \n${e.toString()}';
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
    JourneyStatus status,
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
    String note,
  ) async {
    try {
      final journeyIndex = _journeys.indexWhere((j) => j.id == journeyId);
      if (journeyIndex == -1) return;

      final journey = _journeys[journeyIndex];
      final stageIndex = journey.stages.indexWhere((s) => s.id == stageId);
      if (stageIndex == -1) return;

      final updatedStage = journey.stages[stageIndex].copyWith(notes: note);

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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> updateStage(String journeyId, JourneyStage updatedStage) async {
    try {
      final journeyIndex = _journeys.indexWhere((j) => j.id == journeyId);
      if (journeyIndex == -1) return;

      final journey = _journeys[journeyIndex];
      final stageIndex = journey.stages.indexWhere(
        (s) => s.id == updatedStage.id,
      );
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

  Future<void> deleteStage(String journeyId, String stageId) async {
    try {
      final journeyIndex = _journeys.indexWhere((j) => j.id == journeyId);
      if (journeyIndex == -1) return;

      final journey = _journeys[journeyIndex];
      final updatedStages = journey.stages
          .where((s) => s.id != stageId)
          .toList();

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

  Future<void> addNewStage(String journeyId, JourneyStage newStage) async {
    try {
      final journeyIndex = _journeys.indexWhere((j) => j.id == journeyId);
      if (journeyIndex == -1) return;

      final journey = _journeys[journeyIndex];
      final updatedStages = List<JourneyStage>.from(journey.stages)
        ..add(newStage);

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
