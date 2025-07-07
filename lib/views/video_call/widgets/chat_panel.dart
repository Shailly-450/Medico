import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ChatPanel extends StatefulWidget {
  final bool isOpen;
  final Animation<Offset> slideAnimation;
  final VoidCallback onClose;
  final List<Map<String, dynamic>> messages;
  final Function(String) onSendMessage;

  const ChatPanel({
    Key? key,
    required this.isOpen,
    required this.slideAnimation,
    required this.onClose,
    required this.messages,
    required this.onSendMessage,
  }) : super(key: key);

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      bottom: 0,
      right: 0,
      width: 300,
      child: SlideTransition(
        position: widget.slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(-2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Chat header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.chat, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'Chat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: widget.onClose,
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Chat messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.messages.length,
                  itemBuilder: (context, index) {
                    final message = widget.messages[index];
                    final isDoctor = message['sender'] == 'doctor';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: isDoctor
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.end,
                        children: [
                          if (isDoctor) ...[
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.medical_services,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDoctor
                                    ? Colors.grey[100]
                                    : AppColors.primary,
                                borderRadius:
                                    BorderRadius.circular(16).copyWith(
                                  bottomLeft: isDoctor
                                      ? const Radius.circular(4)
                                      : const Radius.circular(16),
                                  bottomRight: isDoctor
                                      ? const Radius.circular(16)
                                      : const Radius.circular(4),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message['message'],
                                    style: TextStyle(
                                      color: isDoctor
                                          ? Colors.black87
                                          : Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTime(message['time']),
                                    style: TextStyle(
                                      color: isDoctor
                                          ? Colors.grey[600]
                                          : Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!isDoctor) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Chat input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        maxLines: null,
                        onSubmitted: (text) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send),
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      widget.onSendMessage(_messageController.text.trim());
      _messageController.clear();

      // Scroll to bottom after sending message
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
