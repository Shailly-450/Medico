import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/screen_sharing_content_viewer.dart';

class ScreenSharingFullScreen extends StatelessWidget {
  final String contentType;
  final String? contentTitle;
  final VoidCallback onClose;

  const ScreenSharingFullScreen({
    Key? key,
    required this.contentType,
    this.contentTitle,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen content viewer
          ScreenSharingContentViewer(
            contentType: contentType,
            contentTitle: contentTitle,
            onClose: onClose,
          ),

          // Floating close button
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),

          // Bottom info bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.screen_share, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'SHARING',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sharing ${_getContentTypeTitle()} with doctor',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    'Tap to exit full screen',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getContentTypeTitle() {
    switch (contentType) {
      case 'entire_screen':
        return 'entire screen';
      case 'photo_gallery':
        return 'photo gallery';
      case 'documents':
        return 'documents';
      case 'camera':
        return 'live camera';
      case 'health_records':
        return 'health records';
      default:
        return 'content';
    }
  }
}
