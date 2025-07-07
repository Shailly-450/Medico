import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ScreenSharingOverlay extends StatelessWidget {
  final bool isActive;
  final VoidCallback onStopSharing;
  final VoidCallback? onTapToFullScreen;
  final String? sharedContentTitle;

  const ScreenSharingOverlay({
    Key? key,
    required this.isActive,
    required this.onStopSharing,
    this.onTapToFullScreen,
    this.sharedContentTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isActive) return const SizedBox.shrink();

    return Positioned(
      top: 100,
      left: 20,
      child: GestureDetector(
        onTap: onTapToFullScreen,
        child: Container(
          width: 200,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: Stack(
            children: [
              // Screen content preview (placeholder)
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.screen_share,
                      color: Colors.white54,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Screen Sharing',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (sharedContentTitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        sharedContentTitle!,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Recording indicator
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Stop sharing button
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onStopSharing,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.stop,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
