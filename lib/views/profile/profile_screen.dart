import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/family_member.dart';
import '../../viewmodels/family_members_view_model.dart';
import 'family_members_screen.dart';
import 'insurance_form_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final familyVM = context.watch<FamilyMembersViewModel>();
    final currentProfile = familyVM.currentProfile;
    final familyCount = familyVM.members.length;
    return Scaffold(
      backgroundColor: AppColors.paleBackground,
      appBar: AppBar(
        title: const Text('Profile'),
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
              // Profile Card
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: AppColors.primary.withOpacity(0.08), width: 1.5),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primary.withOpacity(0.08),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                    child: Row(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                          child: _ProfileAvatar(
                            key: ValueKey(currentProfile?.id),
                            name: currentProfile?.name,
                            imageUrl: currentProfile?.imageUrl,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
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
                            icon: const Icon(Icons.switch_account, color: AppColors.primary),
                            onPressed: () async {
                              final selected = await showModalBottomSheet<FamilyMember>(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                builder: (ctx) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Container(
                                            width: 40,
                                            height: 4,
                                            margin: const EdgeInsets.only(bottom: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: Text('Switch Profile', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                        ),
                                        const Divider(height: 20),
                                        ...familyVM.members.asMap().entries.map((entry) {
                                          final member = entry.value;
                                          final isActive = member.id == currentProfile?.id;
                                          final isMain = entry.key == 0;
                                          return Material(
                                            color: isActive ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(12),
                                              onTap: () => Navigator.pop(ctx, member),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                                child: Row(
                                                  children: [
                                                    _ProfileAvatar(
                                                      name: member.name,
                                                      imageUrl: member.imageUrl,
                                                      radius: 22,
                                                    ),
                                                    const SizedBox(width: 14),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                member.name,
                                                                style: textTheme.bodyLarge?.copyWith(
                                                                  fontWeight: FontWeight.w600,
                                                                  color: AppColors.textPrimary,
                                                                ),
                                                              ),
                                                              if (isMain)
                                                                Container(
                                                                  margin: const EdgeInsets.only(left: 8),
                                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                                  decoration: BoxDecoration(
                                                                    color: AppColors.primary.withOpacity(0.12),
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                  child: Text('You', style: textTheme.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                                                ),
                                                            ],
                                                          ),
                                                          Text(
                                                            member.role,
                                                            style: textTheme.bodySmall?.copyWith(color: AppColors.primary),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (isActive)
                                                      const Icon(Icons.check_circle, color: AppColors.success),
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
              ),

              // General Section
              _SectionTitle(title: 'General'),
              _ProfileSectionCard(
                items: [
                  _ProfileItem(
                    icon: Icons.group,
                    title: 'Family Members',
                    trailing: Text('$familyCount', style: textTheme.bodyMedium?.copyWith(color: AppColors.primary)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FamilyMembersScreen()),
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
                    trailing: Text('Wallet', style: textTheme.bodyMedium?.copyWith(color: AppColors.primary)),
                    onTap: () {},
                  ),
                  _ProfileItem(
                    icon: Icons.verified_user,
                    title: 'Insurance',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const InsuranceFormScreen()),
                      );
                    },
                  ),
                  _ProfileItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {},
                  ),
                ],
              ),

              // Preferences Section
              _SectionTitle(title: 'Preferences'),
              _ProfileSectionCard(
                items: [
                  _ProfileItem(
                    icon: Icons.support_agent,
                    title: 'Help & Support',
                    onTap: () {},
                  ),
                  _ProfileItem(
                    icon: Icons.privacy_tip,
                    title: 'Privacy & Policy',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                  style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
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
  const _ProfileSectionCard({required this.items});
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
  const _ProfileAvatar({Key? key, this.name, this.imageUrl, this.radius = 32}) : super(key: key);

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
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withOpacity(0.15),
      child: Text(
        getInitials(),
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
} 