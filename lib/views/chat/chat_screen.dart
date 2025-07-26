import 'package:flutter/material.dart';
import '../../core/views/base_view.dart';
import '../../viewmodels/chat_view_model.dart';
import '../../core/theme/app_colors.dart';
import '../../models/chat_message.dart';
import 'widgets/message_bubble.dart';
import 'widgets/chat_input.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  final ChatConversation conversation;

  const ChatScreen({Key? key, required this.conversation}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<ChatViewModel>(
      viewModelBuilder: () => ChatViewModel(),
      builder: (context, model, child) {
        // Load messages when screen opens
        if (model.currentConversationId != widget.conversation.id) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            model.loadMessages(widget.conversation.id);
          });
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: _buildAppBar(context, model),
          body: Column(
            children: [
              Expanded(child: _buildMessagesList(model)),
              _buildTypingIndicator(model),
              ChatInput(
                controller: _messageController,
                onSendMessage: (message) => _sendMessage(model, message),
                onAttachmentPressed: () =>
                    _showAttachmentOptions(context, model),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ChatViewModel model) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          // Doctor Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: widget.conversation.doctorAvatar != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      widget.conversation.doctorAvatar!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person, color: Colors.white),
                    ),
                  )
                : const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.conversation.doctorName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.conversation.doctorSpecialty,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.video_call),
          onPressed: () => _startVideoCall(context),
          tooltip: 'Video Call',
        ),
        IconButton(
          icon: const Icon(Icons.call),
          onPressed: () => _startVoiceCall(context),
          tooltip: 'Voice Call',
        ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'info',
              child: Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 8),
                  Text('Doctor Info'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'appointment',
              child: Row(
                children: [
                  Icon(Icons.calendar_today),
                  SizedBox(width: 8),
                  Text('Book Appointment'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.clear_all),
                  SizedBox(width: 8),
                  Text('Clear Chat'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessagesList(ChatViewModel model) {
    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (model.messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: model.messages.length,
      itemBuilder: (context, index) {
        final message = model.messages[index];
        final isLastMessage = index == model.messages.length - 1;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: MessageBubble(
            message: message,
            showTime: isLastMessage || _shouldShowTime(model.messages, index),
            context: context,
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator(ChatViewModel model) {
    if (!model.isTyping) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                _buildTypingDot(1),
                _buildTypingDot(2),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${widget.conversation.doctorName} is typing...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.grey[600]?.withOpacity(value),
            shape: BoxShape.circle,
          ),
        );
      },
      onEnd: () {
        // Restart animation
        if (mounted) setState(() {});
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to ${widget.conversation.doctorName}',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _sendMessage(ChatViewModel model, String message) {
    if (message.trim().isEmpty) return;

    model.sendMessage(message);
    _messageController.clear();

    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showAttachmentOptions(BuildContext context, ChatViewModel model) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image, color: Colors.green),
              title: const Text('Send Image'),
              onTap: () {
                Navigator.pop(context);
                _sendImage(model);
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file, color: Colors.blue),
              title: const Text('Send File'),
              onTap: () {
                Navigator.pop(context);
                _sendFile(model);
              },
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.deepPurple),
              title: const Text('Send Report'),
              onTap: () {
                Navigator.pop(context);
                _sendReport(model);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.orange),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto(model);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.red),
              title: const Text('Send Location'),
              onTap: () {
                Navigator.pop(context);
                _sendLocation(model);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sendImage(ChatViewModel model) {
    // TODO: Implement image sending
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image sending feature coming soon!')),
    );
  }

  void _sendFile(ChatViewModel model) {
    // TODO: Implement file sending
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File sending feature coming soon!')),
    );
  }

  void _sendReport(ChatViewModel model) async {
    // Pick PDF or image file
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Choose PDF'),
              onTap: () async {
                Navigator.pop(context, 'pdf');
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Choose Image'),
              onTap: () async {
                Navigator.pop(context, 'image');
              },
            ),
          ],
        ),
      ),
    );
    if (result == null) return;
    File? file;
    String? fileName;
    String? fileType;
    if (result == 'pdf') {
      final picked = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (picked != null && picked.files.single.path != null) {
        file = File(picked.files.single.path!);
        fileName = picked.files.single.name;
        fileType = 'pdf';
      }
    } else if (result == 'image') {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        file = File(picked.path);
        fileName = picked.name;
        fileType = 'image';
      }
    }
    if (file != null && fileName != null && fileType != null) {
      model.sendMessage(
        fileName,
        type: MessageType.file,
        metadata: {
          'filePath': file.path,
          'fileName': fileName,
          'fileType': fileType,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No file selected'), backgroundColor: Colors.orange),
      );
    }
  }

  void _takePhoto(ChatViewModel model) {
    // TODO: Implement photo taking
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo taking feature coming soon!')),
    );
  }

  void _sendLocation(ChatViewModel model) {
    // TODO: Implement location sending
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location sharing feature coming soon!')),
    );
  }

  void _startVideoCall(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Starting video call with ${widget.conversation.doctorName}...',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _startVoiceCall(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Starting voice call with ${widget.conversation.doctorName}...',
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'info':
        _showDoctorInfo(context);
        break;
      case 'appointment':
        _bookAppointment(context);
        break;
      case 'clear':
        _clearChat(context);
        break;
    }
  }

  void _showDoctorInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.conversation.doctorName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Specialty: ${widget.conversation.doctorSpecialty}'),
            const SizedBox(height: 8),
            Text('Experience: 15+ years'),
            const SizedBox(height: 8),
            Text('Languages: English, Arabic'),
            const SizedBox(height: 8),
            Text('Available: Mon-Fri, 9 AM - 6 PM'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _bookAppointment(BuildContext context) {
    Navigator.pop(context); // Close menu
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Booking appointment with ${widget.conversation.doctorName}...',
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _clearChat(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text(
          'Are you sure you want to clear all messages? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement clear chat functionality
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Chat cleared')));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  bool _shouldShowTime(List<ChatMessage> messages, int index) {
    if (index == 0) return true;

    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];

    final timeDifference = currentMessage.timestamp.difference(
      previousMessage.timestamp,
    );
    return timeDifference.inMinutes > 5;
  }
}
