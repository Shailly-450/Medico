import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:intl/intl.dart';
import '../../core/services/ai_symptom_service.dart';
import '../../models/ai_symptom_chat.dart';
import '../../core/theme/app_colors.dart';

class AISymptomChatScreen extends StatefulWidget {
  final String? sessionId;
  final String patientId;

  const AISymptomChatScreen({
    Key? key,
    this.sessionId,
    this.patientId = 'patient_001',
  }) : super(key: key);

  @override
  State<AISymptomChatScreen> createState() => _AISymptomChatScreenState();
}

class _AISymptomChatScreenState extends State<AISymptomChatScreen> {
  final AISymptomService _aiService = AISymptomService();
  AIConsultationSession? _currentSession;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Chat users
  late ChatUser _user;
  late ChatUser _ai;

  @override
  void initState() {
    super.initState();
    _initializeUsers();
    _initializeSession();
  }

  void _initializeUsers() {
    _user = ChatUser(
      id: '1',
      firstName: 'You',
      lastName: '',
      profileImage: null,
    );

    _ai = ChatUser(
      id: '2',
      firstName: 'AI Health',
      lastName: 'Assistant',
      profileImage: null,
    );
  }

  Future<void> _initializeSession() async {
    setState(() => _isLoading = true);

    try {
      if (widget.sessionId != null) {
        _currentSession = _aiService.getSession(widget.sessionId!);
      }

      if (_currentSession == null) {
        _currentSession = await _aiService.startConsultation(widget.patientId);
      }

      _convertToChatMessages();
    } catch (e) {
      _showErrorSnackBar('Failed to initialize chat session');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onSendMessage(ChatMessage message) async {
    // Add user message to the end (bottom)
    setState(() {
      _messages.add(message);
      _isLoading = true;
    });

    try {
      final response = await _aiService.sendMessage(
        _currentSession!.id,
        message.text,
      );

      // Update session and convert messages
      _currentSession = _aiService.getSession(_currentSession!.id);
      _convertToChatMessages();
    } catch (e) {
      _showErrorSnackBar('Failed to send message');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _convertToChatMessages() {
    // Convert messages in chronological order (oldest first)
    _messages = _currentSession!.messages.map((msg) {
      return ChatMessage(
        text: msg.content,
        user: msg.type == MessageType.user ? _user : _ai,
        createdAt: msg.timestamp,
        customProperties: msg.metadata,
      );
    }).toList();

    setState(() {});
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _messages.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing AI Health Assistant...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: DashChat(
        currentUser: _user,
        onSend: _onSendMessage,
        messages:
            _messages.reversed.toList(), // Reverse to show latest at bottom
        messageOptions: MessageOptions(
          currentUserContainerColor: AppColors.primary,
          currentUserTextColor: Colors.white,
          containerColor: Colors.grey[100]!,
          textColor: AppColors.textPrimary,
          borderRadius: 12,
          messagePadding: const EdgeInsets.all(12),
          maxWidth: MediaQuery.of(context).size.width * 0.8,
          showTime: true,
          timeFormat: DateFormat('HH:mm'),
          avatarBuilder: (user, onPressAvatar, onLongPressAvatar) {
            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: user.id == _ai.id
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                user.id == _ai.id ? Icons.smart_toy : Icons.person,
                color:
                    user.id == _ai.id ? AppColors.primary : AppColors.secondary,
                size: 20,
              ),
            );
          },
        ),
        inputOptions: InputOptions(
          inputDecoration: InputDecoration(
            hintText: 'Describe your symptoms or ask questions...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          sendButtonBuilder: (onSend) {
            return Container(
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(25),
              ),
              child: IconButton(
                onPressed: onSend,
                icon: const Icon(Icons.send, color: Colors.white),
              ),
            );
          },
        ),
        typingUsers: _isLoading ? [_ai] : [],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Health Assistant',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (_currentSession != null)
            Text(
              'Session: ${_currentSession!.duration.inMinutes}m',
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
        ],
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        if (_currentSession != null)
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'new_session':
                  _startNewSession();
                  break;
                case 'view_history':
                  _showSessionHistory();
                  break;
                case 'end_session':
                  _endCurrentSession();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new_session',
                child: Row(
                  children: [
                    Icon(Icons.add, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('New Session'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'view_history',
                child: Row(
                  children: [
                    Icon(Icons.history, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('View History'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'end_session',
                child: Row(
                  children: [
                    Icon(Icons.stop, color: Colors.red),
                    SizedBox(width: 8),
                    Text('End Session'),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _startNewSession() async {
    setState(() => _isLoading = true);
    try {
      _currentSession = await _aiService.startConsultation(widget.patientId);
      _convertToChatMessages();
    } catch (e) {
      _showErrorSnackBar('Failed to start new session');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSessionHistory() {
    // TODO: Navigate to session history screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session history feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _endCurrentSession() async {
    if (_currentSession != null) {
      await _aiService.endConsultation(_currentSession!.id);
      Navigator.pop(context);
    }
  }
}

// Extension to get lastOrNull
extension ListExtension<T> on List<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
