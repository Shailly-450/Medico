import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/family_member.dart';
import '../../viewmodels/family_members_view_model.dart';
import 'family_members_screen.dart';
import 'insurance_form_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import 'privacy_policy_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme
        .of(context)
        .textTheme;
    final familyVM = context.watch<FamilyMembersViewModel>();
    final currentProfile = familyVM.currentProfile;
    final familyCount = familyVM.members.length;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5E8), // Light mint green
              Color(0xFFF0F8F0), // Very light sage
              Color(0xFFE6F3E6), // Soft green tint
              Color(0xFFF5F9F5), // Almost white with green tint
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                // Profile Card
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          blurRadius: 40,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 24),
                    child: Row(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          transitionBuilder: (child, anim) =>
                              FadeTransition(opacity: anim, child: child),
                          child: _ProfileAvatar(
                            key: ValueKey(currentProfile?.id),
                            name: currentProfile?.name,
                            imageUrl: currentProfile?.imageUrl,
                            useGreenGradient: true,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            transitionBuilder: (child, anim) =>
                                FadeTransition(opacity: anim, child: child),
                            child: Column(
                              key: ValueKey(currentProfile?.id),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentProfile?.name ?? '-',
                                  style: textTheme.titleLarge?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentProfile?.role ?? '-',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Tooltip(
                          message: 'Switch Profile',
                          child: IconButton(
                            icon: const Icon(
                                Icons.switch_account, color: AppColors.primary),
                            onPressed: () async {
                              final selected = await showModalBottomSheet<
                                  FamilyMember>(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                builder: (ctx) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 8),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Center(
                                          child: Container(
                                            width: 40,
                                            height: 4,
                                            margin: const EdgeInsets.only(
                                                bottom: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius: BorderRadius
                                                  .circular(2),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Text('Switch Profile',
                                              style: textTheme.titleMedium
                                                  ?.copyWith(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        const Divider(height: 20),
                                        ...familyVM.members
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          final member = entry.value;
                                          final isActive = member.id ==
                                              currentProfile?.id;
                                          final isMain = entry.key == 0;
                                          return Material(
                                            color: isActive ? AppColors.primary
                                                .withOpacity(0.08) : Colors
                                                .transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius
                                                  .circular(12),
                                              onTap: () =>
                                                  Navigator.pop(ctx, member),
                                              child: Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(vertical: 8,
                                                    horizontal: 8),
                                                child: Row(
                                                  children: [
                                                    _ProfileAvatar(
                                                      name: member.name,
                                                      imageUrl: member.imageUrl,
                                                      radius: 22,
                                                      useGreenGradient: true,
                                                    ),
                                                    const SizedBox(width: 14),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                member.name,
                                                                style: textTheme
                                                                    .bodyLarge
                                                                    ?.copyWith(
                                                                  fontWeight: FontWeight
                                                                      .w600,
                                                                  color: AppColors
                                                                      .textPrimary,
                                                                ),
                                                              ),
                                                              if (isMain)
                                                                Container(
                                                                  margin: const EdgeInsets
                                                                      .only(
                                                                      left: 8),
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal: 8,
                                                                      vertical: 2),
                                                                  decoration: BoxDecoration(
                                                                    color: AppColors
                                                                        .primary
                                                                        .withOpacity(
                                                                        0.12),
                                                                    borderRadius: BorderRadius
                                                                        .circular(
                                                                        8),
                                                                  ),
                                                                  child: Text(
                                                                      'You',
                                                                      style: textTheme
                                                                          .bodySmall
                                                                          ?.copyWith(
                                                                          color: AppColors
                                                                              .primary,
                                                                          fontWeight: FontWeight
                                                                              .bold)),
                                                                ),
                                                            ],
                                                          ),
                                                          Text(
                                                            member.role,
                                                            style: textTheme
                                                                .bodySmall
                                                                ?.copyWith(
                                                                color: AppColors
                                                                    .primary),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (isActive)
                                                      const Icon(
                                                          Icons.check_circle,
                                                          color: AppColors
                                                              .success),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                        const SizedBox(height: 12),
                                      ],
                                    ),
                                  );
                                },
                              );
                              if (selected != null) {
                                familyVM.switchProfile(selected);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // General Section
                _SectionTitle(title: 'General'),
                _ProfileSectionCard(
                  glass: true,
                  items: [
                    _ProfileItem(
                      icon: Icons.group,
                      title: 'Family Members',
                      trailing: Text('$familyCount',
                          style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (
                              _) => const FamilyMembersScreen()),
                        );
                      },
                    ),
                    _ProfileItem(
                      icon: Icons.description,
                      title: 'Prescriptions & Reports',
                      onTap: () {},
                    ),
                    _ProfileItem(
                      icon: Icons.account_balance_wallet,
                      title: 'Payment Methods',
                      trailing: Text('Wallet',
                          style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary)),
                      onTap: () {},
                    ),
                    _ProfileItem(
                      icon: Icons.verified_user,
                      title: 'Insurance',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (
                              _) => const InsuranceFormScreen()),
                        );
                      },
                    ),
                    _ProfileItem(
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (
                              _) => const SettingsScreen()),
                        );
                      },
                    ),
                  ],
                ),

                // Preferences Section
                _SectionTitle(title: 'Preferences'),
                _ProfileSectionCard(
                  glass: true,
                  items: [
                    _ProfileItem(
                      icon: Icons.support_agent,
                      title: 'Help & Support',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (
                              _) => const HelpSupportScreen()),
                        );
                      },
                    ),
                    _ProfileItem(
                      icon: Icons.privacy_tip,
                      title: 'Privacy & Policy',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (
                              _) => const PrivacyPolicyScreen()),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.85),
                        foregroundColor: AppColors.error,
                        shadowColor: Colors.red.withOpacity(0.08),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                              color: AppColors.error.withOpacity(0.18),
                              width: 1.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      onPressed: () {},
                    ),
                  ),
                ),

                // Version
                Padding(
                  padding: const EdgeInsets.only(bottom: 16, top: 4),
                  child: Text(
                    'version 1.0.0',
                    style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary),
                  ),
                ),
              ], // End of Column children
            ),
          ),
        ),
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

class _ProfileSectionCard extends StatelessWidget {
  final List<_ProfileItem> items;
  final bool glass;

  const _ProfileSectionCard({required this.items, this.glass = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: glass ? Colors.white.withOpacity(0.9) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: glass ? Border.all(
            color: Colors.white.withOpacity(0.3), width: 1.2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          if (glass)
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.08),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
        ],
      ),
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
class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _ProfileItem({
    required this.icon,
    required this.title,
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
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  final double radius;
  final bool useGreenGradient;
  const _ProfileAvatar({Key? key, this.name, this.imageUrl, this.radius = 32, this.useGreenGradient = false}) : super(key: key);

  String getInitials() {
    if (name == null || name!.trim().isEmpty) return '';
    final parts = name!.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl!),
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Container(),
      );
    }
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: useGreenGradient
            ? const LinearGradient(
                colors: [
                  Color(0xFF2E7D32),
                  Color(0xFF4CAF50),
                  Color(0xFF66BB6A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: useGreenGradient ? null : AppColors.primary.withOpacity(0.15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        getInitials(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.7,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
} 