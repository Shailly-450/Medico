import 'package:flutter/foundation.dart';
import '../models/insurance.dart';
import '../core/services/insurance_service.dart';
import '../core/services/insurance_filters_service.dart';
import '../core/services/auth_service.dart';
import '../core/viewmodels/base_view_model.dart';
import 'dart:io';

class InsuranceViewModel extends BaseViewModel {
  final _service = InsuranceService();
  List<Insurance> _insurances = [];
  Map<String, dynamic> _availableFilters = {};
  List<String> _insuranceProviders = [];

  List<Insurance> get insurances => _insurances;
  Map<String, dynamic> get availableFilters => _availableFilters;
  List<String> get insuranceProviders => _insuranceProviders;

  // Filter getters
  List<Insurance> get validInsurances =>
      _insurances.where((i) => i.isValid).toList();

  List<Insurance> get expiredInsurances =>
      _insurances.where((i) => !i.isValid).toList();

  List<Insurance> get expiringSoonInsurances =>
      _insurances.where((i) => i.isExpiringSoon).toList();

  // Initialize with data
  @override
  void init() {
    loadInsurances();
    loadInsuranceFilters();
  }

  Future<void> loadInsurances() async {
    try {
      setBusy(true);
      clearError();

      print('Fetching insurances...');
      _insurances = await _service.getInsurances();
      print('Fetched ${_insurances.length} insurances');
    } catch (e) {
      print('Error fetching insurances: $e');
      setError('Failed to load insurances: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<Insurance?> createInsurance({
    required String insuranceProvider,
    required String policyNumber,
    required String policyHolderName,
    required DateTime validFrom,
    required DateTime validTo,
    File? insuranceCardFile,
  }) async {
    try {
      setBusy(true);
      clearError();

      String? insuranceCardUrl;
      if (insuranceCardFile != null) {
        insuranceCardUrl = await _service.uploadInsuranceCard(
          insuranceCardFile,
        );
      }

      final userId = AuthService.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final insurance = await _service.createInsurance(
        userId: userId,
        insuranceProvider: insuranceProvider,
        policyNumber: policyNumber,
        policyHolderName: policyHolderName,
        validFrom: validFrom,
        validTo: validTo,
        insuranceCard: insuranceCardUrl,
      );

      _insurances.add(insurance);
      notifyListeners();
      return insurance;
    } catch (e) {
      setError('Failed to create insurance: $e');
      return null;
    } finally {
      setBusy(false);
    }
  }

  Future<bool> deleteInsurance(String insuranceId) async {
    try {
      setBusy(true);
      clearError();

      await _service.deleteInsurance(insuranceId);
      _insurances.removeWhere((i) => i.id == insuranceId);
      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to delete insurance: $e');
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<Insurance?> updateInsurance({
    required String insuranceId,
    String? insuranceProvider,
    String? policyNumber,
    String? policyHolderName,
    DateTime? validFrom,
    DateTime? validTo,
    File? insuranceCardFile,
  }) async {
    try {
      setBusy(true);
      clearError();

      String? insuranceCardUrl;
      if (insuranceCardFile != null) {
        insuranceCardUrl = await _service.uploadInsuranceCard(
          insuranceCardFile,
        );
      }

      final insurance = await _service.updateInsurance(
        insuranceId: insuranceId,
        insuranceProvider: insuranceProvider,
        policyNumber: policyNumber,
        policyHolderName: policyHolderName,
        validFrom: validFrom,
        validTo: validTo,
        insuranceCard: insuranceCardUrl,
      );

      final index = _insurances.indexWhere((i) => i.id == insuranceId);
      if (index != -1) {
        _insurances[index] = insurance;
      }

      notifyListeners();
      return insurance;
    } catch (e) {
      setError('Failed to update insurance: $e');
      return null;
    } finally {
      setBusy(false);
    }
  }

  Future<void> loadInsuranceFilters() async {
    try {
      _availableFilters = await InsuranceFiltersService.getInsuranceFilters();
      _insuranceProviders = await InsuranceFiltersService.getInsuranceProviders();
      notifyListeners();
    } catch (e) {
      print('Error loading insurance filters: $e');
    }
  }

  Future<Insurance?> getInsuranceById(String insuranceId) async {
    try {
      setBusy(true);
      clearError();

      final insurance = await _service.getInsuranceById(insuranceId);
      return insurance;
    } catch (e) {
      setError('Failed to fetch insurance: $e');
      return null;
    } finally {
      setBusy(false);
    }
  }
}
