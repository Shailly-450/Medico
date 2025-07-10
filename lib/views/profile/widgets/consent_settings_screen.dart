import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/consent.dart';
import '../../../viewmodels/consent_view_model.dart';

class ConsentSettingsScreen extends StatefulWidget {
  const ConsentSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ConsentSettingsScreen> createState() => _ConsentSettingsScreenState();
}

class _ConsentSettingsScreenState extends State<ConsentSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ConsentViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final settings = viewModel.consentSettings;
        if (settings == null) {
          return const Center(
            child: Text('No settings available'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSettingsSection(
                'Essential Services',
                [
                  _buildSettingItem(
                    'Notifications',
                    'Receive important health updates and reminders',
                    Icons.notifications,
                    settings.allowNotifications,
                    (value) => _updateSetting('notifications', value, viewModel),
                    isRequired: true,
                  ),
                  _buildSettingItem(
                    'Location Services',
                    'Find nearby hospitals and clinics',
                    Icons.location_on,
                    settings.allowLocationServices,
                    (value) => _updateSetting('location', value, viewModel),
                  ),
                  _buildSettingItem(
                    'Biometric Authentication',
                    'Use fingerprint or face ID for secure login',
                    Icons.fingerprint,
                    settings.allowBiometricAuth,
                    (value) => _updateSetting('biometric', value, viewModel),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSettingsSection(
                'Health & Privacy',
                [
                  _buildSettingItem(
                    'Health Data Processing',
                    'Process your medical records and health information',
                    Icons.health_and_safety,
                    true, // Always true for health data
                    null, // Cannot be changed
                    isRequired: true,
                    isDisabled: true,
                  ),
                  _buildSettingItem(
                    'Emergency Contacts',
                    'Share information with emergency contacts',
                    Icons.emergency,
                    settings.allowEmergencyContacts,
                    (value) => _updateSetting('emergency', value, viewModel),
                  ),
                  _buildSettingItem(
                    'Family Member Access',
                    'Allow family members to view your health records',
                    Icons.family_restroom,
                    settings.allowFamilyMemberAccess,
                    (value) => _updateSetting('family', value, viewModel),
                  ),
                  _buildSettingItem(
                    'Cloud Storage',
                    'Store your data securely in the cloud',
                    Icons.cloud,
                    settings.allowCloudStorage,
                    (value) => _updateSetting('cloud', value, viewModel),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSettingsSection(
                'Analytics & Improvement',
                [
                  _buildSettingItem(
                    'Analytics',
                    'Help us improve our services with usage data',
                    Icons.analytics,
                    settings.allowAnalytics,
                    (value) => _updateSetting('analytics', value, viewModel),
                  ),
                  _buildSettingItem(
                    'Research Participation',
                    'Contribute to medical research (anonymized)',
                    Icons.science,
                    settings.allowResearchParticipation,
                    (value) => _updateSetting('research', value, viewModel),
                  ),
                  _buildSettingItem(
                    'Personalized Content',
                    'Receive personalized health recommendations',
                    Icons.person,
                    settings.allowPersonalizedContent,
                    (value) => _updateSetting('personalized', value, viewModel),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSettingsSection(
                'Marketing & Communications',
                [
                  _buildSettingItem(
                    'Marketing Communications',
                    'Receive promotional emails and offers',
                    Icons.campaign,
                    settings.allowMarketing,
                    (value) => _updateSetting('marketing', value, viewModel),
                  ),
                  _buildSettingItem(
                    'Third-Party Services',
                    'Share data with trusted service providers',
                    Icons.business,
                    settings.allowThirdPartyServices,
                    (value) => _updateSetting('thirdParty', value, viewModel),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildLastUpdatedInfo(settings),
              const SizedBox(height: 32),
              _buildExportButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.privacy_tip,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Privacy Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Control how your data is used and shared',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textBlack,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    String title,
    String description,
    IconData icon,
    bool value,
    Function(bool)? onChanged, {
    bool isRequired = false,
    bool isDisabled = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                    if (isRequired)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Required',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: isDisabled ? null : onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdatedInfo(ConsentSettings settings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Last Updated',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                '${settings.lastUpdated.day}/${settings.lastUpdated.month}/${settings.lastUpdated.year} at ${settings.lastUpdated.hour}:${settings.lastUpdated.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (settings.updatedBy != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Updated by ${settings.updatedBy}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _exportSettings(),
        icon: const Icon(Icons.download),
        label: const Text('Export Privacy Settings'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _updateSetting(String setting, bool value, ConsentViewModel viewModel) {
    final currentSettings = viewModel.consentSettings;
    if (currentSettings == null) return;

    ConsentSettings newSettings;
    switch (setting) {
      case 'notifications':
        newSettings = currentSettings.copyWith(allowNotifications: value);
        break;
      case 'location':
        newSettings = currentSettings.copyWith(allowLocationServices: value);
        break;
      case 'biometric':
        newSettings = currentSettings.copyWith(allowBiometricAuth: value);
        break;
      case 'emergency':
        newSettings = currentSettings.copyWith(allowEmergencyContacts: value);
        break;
      case 'family':
        newSettings = currentSettings.copyWith(allowFamilyMemberAccess: value);
        break;
      case 'cloud':
        newSettings = currentSettings.copyWith(allowCloudStorage: value);
        break;
      case 'analytics':
        newSettings = currentSettings.copyWith(allowAnalytics: value);
        break;
      case 'research':
        newSettings = currentSettings.copyWith(allowResearchParticipation: value);
        break;
      case 'personalized':
        newSettings = currentSettings.copyWith(allowPersonalizedContent: value);
        break;
      case 'marketing':
        newSettings = currentSettings.copyWith(allowMarketing: value);
        break;
      case 'thirdParty':
        newSettings = currentSettings.copyWith(allowThirdPartyServices: value);
        break;
      default:
        return;
    }

    viewModel.updateConsentSettings(newSettings);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Privacy setting updated'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _exportSettings() {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Export feature coming soon!'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
} 