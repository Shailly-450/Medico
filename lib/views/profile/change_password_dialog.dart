import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/profile_view_model.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({Key? key}) : super(key: key);

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  bool _showCurrent = false;
  bool _showNew = false;
  bool _isSubmitting = false;

  // Password requirements
  bool get hasMinLength => _newController.text.length >= 8;
  bool get hasUppercase => _newController.text.contains(RegExp(r'[A-Z]'));
  bool get hasLowercase => _newController.text.contains(RegExp(r'[a-z]'));
  bool get hasNumber => _newController.text.contains(RegExp(r'[0-9]'));
  bool get hasSpecial => _newController.text.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

  bool get isStrong => hasMinLength && hasUppercase && hasLowercase && hasNumber && hasSpecial;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.lock, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Change Password', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text('Enter your current password to change your password', style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Current Password
            Text('Current Password', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            TextField(
              controller: _currentController,
              obscureText: !_showCurrent,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.paleBackground,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: Icon(_showCurrent ? Icons.visibility : Icons.visibility_off, color: AppColors.primary),
                  onPressed: () => setState(() => _showCurrent = !_showCurrent),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // New Password
            Text('New Password', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            TextField(
              controller: _newController,
              obscureText: !_showNew,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.paleBackground,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: Icon(_showNew ? Icons.visibility : Icons.visibility_off, color: AppColors.primary),
                  onPressed: () => setState(() => _showNew = !_showNew),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Password requirements
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PasswordRequirement(text: '8 characters', met: hasMinLength),
                _PasswordRequirement(text: 'Uppercase', met: hasUppercase),
                _PasswordRequirement(text: 'Lowercase', met: hasLowercase),
                _PasswordRequirement(text: 'Numbers', met: hasNumber),
                _PasswordRequirement(text: 'Special characters', met: hasSpecial),
              ],
            ),
            const SizedBox(height: 24),
            // Apply changes button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: isStrong && !_isSubmitting ? _submit : null,
                child: _isSubmitting
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Apply changes', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    setState(() => _isSubmitting = true);
    final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
    final oldPwd = _currentController.text.trim();
    final newPwd = _newController.text.trim();
    final result = await profileVM.changePassword(oldPwd, newPwd);
    setState(() => _isSubmitting = false);
    if (!mounted) return;
    if (result['success'] == true) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to change password')),
      );
    }
  }
}

class _PasswordRequirement extends StatelessWidget {
  final String text;
  final bool met;
  const _PasswordRequirement({required this.text, required this.met});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: met ? AppColors.primary.withOpacity(0.08) : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: met ? AppColors.primary : Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(met ? Icons.check_circle : Icons.radio_button_unchecked, size: 16, color: met ? AppColors.primary : Colors.grey),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 13, color: met ? AppColors.primary : Colors.grey)),
        ],
      ),
    );
  }
} 