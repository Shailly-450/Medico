import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'change_password_dialog.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/api_service.dart';
import '../../core/services/notification_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _pushNotifications = true;
  bool _appointmentReminders = true;
  bool _medicineReminders = true;
  bool _healthTips = true;
  bool _biometricAuth = false;
  bool _locationServices = true;

  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> _authenticateWithBiometrics() async {
    try {
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to enable biometrics',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return authenticated;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      backgroundColor: AppColors.paleBackground,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              // Notifications Section
              _SectionTitle(title: 'Notifications'),
              _SettingsSectionCard(
                items: [
                  _SettingsItem(
                    icon: Icons.notifications,
                    title: 'Push Notifications',
                    trailing: Switch(
                      value: _pushNotifications,
                      onChanged: (value) async {
                        setState(() => _pushNotifications = value);
                        await NotificationManager.instance.updateNotificationSettings({
                          'notifications_enabled': value,
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                  ),
                  _SettingsItem(
                    icon: Icons.email,
                    title: 'Email Notifications',
                    trailing: Switch(
                      value: _emailNotifications,
                      onChanged: (value) => setState(() => _emailNotifications = value),
                      activeColor: AppColors.primary,
                    ),
                  ),
                  _SettingsItem(
                    icon: Icons.sms,
                    title: 'SMS Notifications',
                    trailing: Switch(
                      value: _smsNotifications,
                      onChanged: (value) => setState(() => _smsNotifications = value),
                      activeColor: AppColors.primary,
                    ),
                  ),
                ],
              ),

              // Reminders Section
              _SectionTitle(title: 'Reminders'),
              _SettingsSectionCard(
                items: [
                  _SettingsItem(
                    icon: Icons.calendar_today,
                    title: 'Appointment Reminders',
                    subtitle: 'Get notified before appointments',
                    trailing: Switch(
                      value: _appointmentReminders,
                      onChanged: (value) => setState(() => _appointmentReminders = value),
                      activeColor: AppColors.primary,
                    ),
                  ),
                  _SettingsItem(
                    icon: Icons.medication,
                    title: 'Medicine Reminders',
                    subtitle: 'Reminders for medication doses',
                    trailing: Switch(
                      value: _medicineReminders,
                      onChanged: (value) => setState(() => _medicineReminders = value),
                      activeColor: AppColors.primary,
                    ),
                  ),
                  _SettingsItem(
                    icon: Icons.health_and_safety,
                    title: 'Health Tips',
                    subtitle: 'Daily health tips and recommendations',
                    trailing: Switch(
                      value: _healthTips,
                      onChanged: (value) => setState(() => _healthTips = value),
                      activeColor: AppColors.primary,
                    ),
                  ),
                ],
              ),

              // Privacy & Security Section
              _SectionTitle(title: 'Privacy & Security'),
              _SettingsSectionCard(
                items: [
                  _SettingsItem(
                    icon: Icons.fingerprint,
                    title: 'Biometric Authentication',
                    subtitle: 'Use fingerprint or face ID',
                    trailing: Switch(
                      value: _biometricAuth,
                      onChanged: (value) async {
                        final prefs = await SharedPreferences.getInstance();
                        final secureStorage = FlutterSecureStorage();
                        if (value) {
                          bool success = await _authenticateWithBiometrics();
                          if (success) {
                            setState(() => _biometricAuth = true);
                            await prefs.setBool('biometric_enabled', true);
                            // Store current session token/userId for biometric login
                            // Try to get from AuthService or ApiService
                            final token = AuthService.accessToken ?? ApiService.accessToken;
                            final userId = AuthService.currentUserId;
                            if (token != null && userId != null) {
                              await secureStorage.write(key: 'auth_token', value: token);
                              await secureStorage.write(key: 'user_id', value: userId);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Biometric authentication enabled!')),
                            );
                          } else {
                            setState(() => _biometricAuth = false);
                            await prefs.setBool('biometric_enabled', false);
                            await secureStorage.delete(key: 'auth_token');
                            await secureStorage.delete(key: 'user_id');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Biometric authentication failed or unavailable.')),
                            );
                          }
                        } else {
                          setState(() => _biometricAuth = false);
                          await prefs.setBool('biometric_enabled', false);
                          await secureStorage.delete(key: 'auth_token');
                          await secureStorage.delete(key: 'user_id');
                        }
                      },
                      activeColor: AppColors.primary,
                    ),
                  ),
                  _SettingsItem(
                    icon: Icons.location_on,
                    title: 'Location Services',
                    subtitle: 'Find nearby hospitals and clinics',
                    trailing: Switch(
                      value: _locationServices,
                      onChanged: (value) => setState(() => _locationServices = value),
                      activeColor: AppColors.primary,
                    ),
                  ),
                  _SettingsItem(
                    icon: Icons.security,
                    title: 'Privacy Settings',
                    onTap: () => _showPrivacySettings(context),
                  ),
                  _SettingsItem(
                    icon: Icons.lock,
                    title: 'Change Password',
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => const ChangePasswordDialog(),
                    ),
                  ),
                ],
              ),



              const SizedBox(height: 24),

              // Version
              Padding(
                padding: const EdgeInsets.only(bottom: 16, top: 4),
                child: Text(
                  'version 1.0.0',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Settings'),
        content: const Text('Privacy settings feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text('Password change feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 0, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _SettingsSectionCard extends StatelessWidget {
  final List<_SettingsItem> items;
  const _SettingsSectionCard({required this.items});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
            items[i],
          ]
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  
  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
      ),
      subtitle: subtitle != null ? Text(
        subtitle!,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
      ) : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
} 