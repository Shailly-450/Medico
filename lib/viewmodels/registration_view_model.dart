import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/registration_data.dart';

class RegistrationViewModel extends BaseViewModel {
  final RegistrationData registrationData = RegistrationData();
  final PageController pageController = PageController();
  int currentStep = 0;

  void nextStep(BuildContext context) {
    if (currentStep < 2) {
      currentStep++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    } else {
      // Registration complete, navigate to home
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      currentStep--;
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
} 