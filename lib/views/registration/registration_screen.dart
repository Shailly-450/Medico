import 'package:flutter/material.dart';
import '../../core/views/base_view.dart';
import '../../viewmodels/registration_view_model.dart';
import 'steps/phone_number_step.dart';
import 'steps/otp_verification_step.dart';
import 'steps/create_account_step.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<RegistrationViewModel>(
      viewModelBuilder: () => RegistrationViewModel(),
      builder: (context, model, child) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    if (model.currentStep > 0)
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: model.previousStep,
                      ),
                    const Spacer(),
                    Text(
                      'Step ${model.currentStep + 1} of 3',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    const SizedBox(width: 48), // For balance with back button
                  ],
                ),
              ),
              
              // Steps
              Expanded(
                child: PageView(
                  controller: model.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    PhoneNumberStep(
                      onContinue: () => model.nextStep(context),
                      registrationData: model.registrationData,
                    ),
                    OtpVerificationStep(
                      onContinue: () => model.nextStep(context),
                      registrationData: model.registrationData,
                    ),
                    CreateAccountStep(
                      onContinue: () => model.nextStep(context),
                      registrationData: model.registrationData,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 