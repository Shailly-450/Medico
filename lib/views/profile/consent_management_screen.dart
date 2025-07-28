import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/consent.dart';
import '../../viewmodels/consent_view_model.dart';
import 'widgets/consent_card.dart';
import 'widgets/consent_detail_dialog.dart';
import 'widgets/consent_log_screen.dart';
import 'widgets/consent_settings_screen.dart';

class ConsentManagementScreen extends StatelessWidget {
  const ConsentManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Consent Management',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: const ConsentSettingsScreen(),
    );
  }
} 