import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ScreenSharingDialog extends StatelessWidget {
  final Function(String) onShareSelected;

  const ScreenSharingDialog({
    Key? key,
    required this.onShareSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.screen_share,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Share Screen',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Choose what you want to share with the doctor:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            // Sharing options
            _buildSharingOption(
              context,
              icon: Icons.screen_share,
              title: 'Entire Screen',
              subtitle: 'Share your complete screen',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                onShareSelected('entire_screen');
              },
            ),

            const SizedBox(height: 12),

            _buildSharingOption(
              context,
              icon: Icons.photo_library,
              title: 'Photo Gallery',
              subtitle: 'Share photos from your gallery',
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                onShareSelected('photo_gallery');
              },
            ),

            const SizedBox(height: 12),

            _buildSharingOption(
              context,
              icon: Icons.folder,
              title: 'Documents',
              subtitle: 'Share medical reports or documents',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                onShareSelected('documents');
              },
            ),

            const SizedBox(height: 12),

            _buildSharingOption(
              context,
              icon: Icons.camera_alt,
              title: 'Camera',
              subtitle: 'Share live camera feed',
              color: Colors.purple,
              onTap: () {
                Navigator.pop(context);
                onShareSelected('camera');
              },
            ),

            const SizedBox(height: 12),

            _buildSharingOption(
              context,
              icon: Icons.medical_information,
              title: 'Health Records',
              subtitle: 'Share your health records',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                onShareSelected('health_records');
              },
            ),

            const SizedBox(height: 20),

            // Info text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'The doctor will be able to see what you share. Make sure to close any sensitive information.',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSharingOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
