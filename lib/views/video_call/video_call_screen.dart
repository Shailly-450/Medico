import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/call_controls.dart';
import 'widgets/chat_panel.dart';
import 'widgets/incoming_call_overlay.dart';
import 'widgets/screen_sharing_overlay.dart';
import 'widgets/screen_sharing_dialog.dart';
import 'widgets/screen_sharing_content_viewer.dart';
import 'screen_sharing_full_screen.dart';

class VideoCallScreen extends StatefulWidget {
  final String doctorName;
  final String doctorSpecialty;
  final String? doctorImage;

  const VideoCallScreen({
    Key? key,
    required this.doctorName,
    required this.doctorSpecialty,
    this.doctorImage,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen>
    with TickerProviderStateMixin {
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;
  bool _isChatOpen = false;
  bool _isRecording = false;
  bool _isScreenSharing = false;
  String? _screenSharingType;
  String? _screenSharingTitle;
  bool _isCallConnected = false;
  bool _isIncomingCall = true;

  late AnimationController _slideAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  final List<Map<String, dynamic>> _chatMessages = [];

  @override
  void initState() {
    super.initState();
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimationController.repeat(reverse: true);

    // Simulate call connection after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isIncomingCall = false;
          _isCallConnected = true;
        });
        _pulseAnimationController.stop();
      }
    });

    // Add some sample chat messages
    _chatMessages.addAll([
      {
        'sender': 'doctor',
        'message': 'Hello! How are you feeling today?',
        'time': DateTime.now().subtract(const Duration(minutes: 2)),
      },
      {
        'sender': 'patient',
        'message': 'I\'m doing better, thank you doctor.',
        'time': DateTime.now().subtract(const Duration(minutes: 1)),
      },
    ]);
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main video view (remote user)
          _buildMainVideoView(),

          // Local video view (user's camera)
          _buildLocalVideoView(),

          // Top bar with doctor info and call status
          _buildTopBar(),

          // Call controls
          if (!_isIncomingCall)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CallControls(
                isMuted: _isMuted,
                isCameraOff: _isCameraOff,
                isSpeakerOn: _isSpeakerOn,
                isRecording: _isRecording,
                isScreenSharing: _isScreenSharing,
                onMuteToggle: () => setState(() => _isMuted = !_isMuted),
                onCameraToggle: () =>
                    setState(() => _isCameraOff = !_isCameraOff),
                onSpeakerToggle: () =>
                    setState(() => _isSpeakerOn = !_isSpeakerOn),
                onRecordingToggle: () =>
                    setState(() => _isRecording = !_isRecording),
                onScreenShareToggle: _handleScreenSharing,
                onEndCall: _showEndCallDialog,
                onMoreOptions: _showMoreOptions,
              ),
            ),

          // Screen sharing overlay
          if (_isScreenSharing)
            ScreenSharingOverlay(
              isActive: _isScreenSharing,
              onStopSharing: _stopScreenSharing,
              onTapToFullScreen: _openScreenSharingFullScreen,
              sharedContentTitle: _screenSharingTitle,
            ),

          // Chat panel
          if (_isChatOpen)
            ChatPanel(
              isOpen: _isChatOpen,
              slideAnimation: _slideAnimation,
              onClose: () {
                setState(() {
                  _isChatOpen = false;
                });
                _slideAnimationController.reverse();
              },
              messages: _chatMessages,
              onSendMessage: _sendMessage,
            ),

          // Incoming call overlay
          if (_isIncomingCall)
            IncomingCallOverlay(
              doctorName: widget.doctorName,
              doctorSpecialty: widget.doctorSpecialty,
              doctorImage: widget.doctorImage,
              onAccept: () {
                setState(() {
                  _isIncomingCall = false;
                  _isCallConnected = true;
                });
                _pulseAnimationController.stop();
              },
              onDecline: () => Navigator.pop(context),
            ),
        ],
      ),
    );
  }

  Widget _buildMainVideoView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        image: widget.doctorImage != null
            ? DecorationImage(
                image: NetworkImage(widget.doctorImage!),
                fit: BoxFit.cover,
                opacity: 0.3,
              )
            : null,
      ),
      child: _isCallConnected
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videocam_off,
                    size: 64,
                    color: Colors.white54,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Doctor\'s camera is off',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Connecting...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLocalVideoView() {
    return Positioned(
      top: 100,
      right: 20,
      child: Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: _isCameraOff
              ? Container(
                  color: Colors.black,
                  child: const Icon(
                    Icons.videocam_off,
                    color: Colors.white54,
                    size: 32,
                  ),
                )
              : Container(
                  color: Colors.grey[700],
                  child: const Icon(
                    Icons.person,
                    color: Colors.white54,
                    size: 48,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            // Back button
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const SizedBox(width: 12),

            // Doctor info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.doctorName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.doctorSpecialty,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Call status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isCallConnected ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isCallConnected ? 'Connected' : 'Connecting...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Chat button
            if (!_isIncomingCall)
              IconButton(
                onPressed: () {
                  setState(() {
                    _isChatOpen = !_isChatOpen;
                  });
                  if (_isChatOpen) {
                    _slideAnimationController.forward();
                  } else {
                    _slideAnimationController.reverse();
                  }
                },
                icon: Icon(
                  _isChatOpen ? Icons.chat_bubble : Icons.chat_bubble_outline,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showEndCallDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Call'),
        content: const Text('Are you sure you want to end this call?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // End call
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('End Call'),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement photo capture
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Photo capture feature coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.record_voice_over),
              title: const Text('Voice Message'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement voice message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Voice message feature coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notes),
              title: const Text('Add Notes'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement notes
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notes feature coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Call Settings'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement call settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Call settings feature coming soon!')),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _sendMessage(String message) {
    setState(() {
      _chatMessages.add({
        'sender': 'patient',
        'message': message,
        'time': DateTime.now(),
      });
    });
  }

  void _handleScreenSharing() {
    if (_isScreenSharing) {
      _stopScreenSharing();
    } else {
      _showScreenSharingDialog();
    }
  }

  void _stopScreenSharing() {
    setState(() {
      _isScreenSharing = false;
      _screenSharingType = null;
      _screenSharingTitle = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Screen sharing stopped'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showScreenSharingDialog() {
    showDialog(
      context: context,
      builder: (context) => ScreenSharingDialog(
        onShareSelected: (String shareType) {
          _startScreenSharing(shareType);
        },
      ),
    );
  }

  void _startScreenSharing(String shareType) {
    setState(() {
      _isScreenSharing = true;
      _screenSharingType = shareType;
      _screenSharingTitle = _getShareTypeTitle(shareType);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Started sharing: ${_getShareTypeTitle(shareType)}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _getShareTypeTitle(String shareType) {
    switch (shareType) {
      case 'entire_screen':
        return 'Entire Screen';
      case 'photo_gallery':
        return 'Photo Gallery';
      case 'documents':
        return 'Documents';
      case 'camera':
        return 'Live Camera';
      case 'health_records':
        return 'Health Records';
      default:
        return 'Screen Content';
    }
  }

  void _openScreenSharingFullScreen() {
    if (_isScreenSharing && _screenSharingType != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScreenSharingFullScreen(
            contentType: _screenSharingType!,
            contentTitle: _screenSharingTitle,
            onClose: () => Navigator.pop(context),
          ),
        ),
      );
    }
  }
}
