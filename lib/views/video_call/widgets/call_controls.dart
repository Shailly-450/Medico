import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CallControls extends StatelessWidget {
  final bool isMuted;
  final bool isCameraOff;
  final bool isSpeakerOn;
  final bool isRecording;
  final bool isScreenSharing;
  final VoidCallback onMuteToggle;
  final VoidCallback onCameraToggle;
  final VoidCallback onSpeakerToggle;
  final VoidCallback onRecordingToggle;
  final VoidCallback onScreenShareToggle;
  final VoidCallback onEndCall;
  final VoidCallback onMoreOptions;

  const CallControls({
    Key? key,
    required this.isMuted,
    required this.isCameraOff,
    required this.isSpeakerOn,
    required this.isRecording,
    required this.isScreenSharing,
    required this.onMuteToggle,
    required this.onCameraToggle,
    required this.onSpeakerToggle,
    required this.onRecordingToggle,
    required this.onScreenShareToggle,
    required this.onEndCall,
    required this.onMoreOptions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
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
      child: Column(
        children: [
          // Secondary controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: isMuted ? Icons.mic_off : Icons.mic,
                label: isMuted ? 'Unmute' : 'Mute',
                isActive: isMuted,
                onTap: onMuteToggle,
              ),
              _buildControlButton(
                icon: isCameraOff ? Icons.videocam_off : Icons.videocam,
                label: isCameraOff ? 'Camera On' : 'Camera Off',
                isActive: isCameraOff,
                onTap: onCameraToggle,
              ),
              _buildControlButton(
                icon: isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                label: isSpeakerOn ? 'Speaker' : 'Earpiece',
                isActive: isSpeakerOn,
                onTap: onSpeakerToggle,
              ),
              _buildControlButton(
                icon: isRecording ? Icons.stop : Icons.fiber_manual_record,
                label: isRecording ? 'Stop Recording' : 'Record',
                isActive: isRecording,
                onTap: onRecordingToggle,
                color: isRecording ? Colors.red : null,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Main call controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Screen share
              _buildControlButton(
                icon: isScreenSharing
                    ? Icons.stop_screen_share
                    : Icons.screen_share,
                label: isScreenSharing ? 'Stop Share' : 'Share Screen',
                isActive: isScreenSharing,
                onTap: onScreenShareToggle,
              ),

              // End call button
              GestureDetector(
                onTap: onEndCall,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.call_end,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),

              // More options
              _buildControlButton(
                icon: Icons.more_vert,
                label: 'More',
                onTap: onMoreOptions,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive
                  ? (color ?? AppColors.primary)
                  : Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
