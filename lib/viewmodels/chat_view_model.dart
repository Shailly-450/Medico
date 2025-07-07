import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/chat_message.dart';
import '../models/doctor.dart';

class ChatViewModel extends BaseViewModel {
  List<ChatConversation> _conversations = [];
  List<ChatMessage> _messages = [];
  String _currentConversationId = '';
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isTyping = false;

  List<ChatConversation> get conversations => _getFilteredConversations();
  List<ChatMessage> get messages => _messages;
  String get currentConversationId => _currentConversationId;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;

  @override
  void init() {
    _loadConversations();
  }

  void _loadConversations() {
    setBusy(true);

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 800), () {
      _conversations = _getMockConversations();
      setBusy(false);
      notifyListeners();
    });
  }

  void loadMessages(String conversationId) {
    _currentConversationId = conversationId;
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _messages = _getMockMessages(conversationId);
      _isLoading = false;
      notifyListeners();
    });
  }

  void sendMessage(
    String content, {
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) {
    if (content.trim().isEmpty) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'patient_id', // In real app, get from auth
      senderName: 'Abdullah Alshahrani', // In real app, get from auth
      senderAvatar: null,
      receiverId: _getDoctorIdFromConversation(_currentConversationId),
      receiverName: _getDoctorNameFromConversation(_currentConversationId),
      receiverAvatar: null,
      content: content.trim(),
      type: type,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      isFromPatient: true,
      metadata: metadata,
    );

    _messages.add(message);
    _updateConversationLastMessage(_currentConversationId, content);
    notifyListeners();

    // Simulate doctor response after 2-5 seconds
    _simulateDoctorResponse();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setTyping(bool typing) {
    _isTyping = typing;
    notifyListeners();
  }

  List<ChatConversation> _getFilteredConversations() {
    if (_searchQuery.isEmpty) {
      return _conversations;
    }

    return _conversations.where((conversation) {
      return conversation.doctorName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          conversation.doctorSpecialty.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          conversation.lastMessage.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
    }).toList();
  }

  String _getDoctorIdFromConversation(String conversationId) {
    final conversation = _conversations.firstWhere(
      (conv) => conv.id == conversationId,
      orElse: () => ChatConversation(
        id: '',
        patientId: '',
        patientName: '',
        doctorId: '',
        doctorName: '',
        doctorSpecialty: '',
        lastMessageTime: DateTime.now(),
        lastMessage: '',
        unreadCount: 0,
        isActive: true,
        createdAt: DateTime.now(),
      ),
    );
    return conversation.doctorId;
  }

  String _getDoctorNameFromConversation(String conversationId) {
    final conversation = _conversations.firstWhere(
      (conv) => conv.id == conversationId,
      orElse: () => ChatConversation(
        id: '',
        patientId: '',
        patientName: '',
        doctorId: '',
        doctorName: '',
        doctorSpecialty: '',
        lastMessageTime: DateTime.now(),
        lastMessage: '',
        unreadCount: 0,
        isActive: true,
        createdAt: DateTime.now(),
      ),
    );
    return conversation.doctorName;
  }

  void _updateConversationLastMessage(String conversationId, String message) {
    final index = _conversations.indexWhere(
      (conv) => conv.id == conversationId,
    );
    if (index != -1) {
      final conversation = _conversations[index];
      _conversations[index] = ChatConversation(
        id: conversation.id,
        patientId: conversation.patientId,
        patientName: conversation.patientName,
        patientAvatar: conversation.patientAvatar,
        doctorId: conversation.doctorId,
        doctorName: conversation.doctorName,
        doctorAvatar: conversation.doctorAvatar,
        doctorSpecialty: conversation.doctorSpecialty,
        lastMessageTime: DateTime.now(),
        lastMessage: message,
        unreadCount: 0,
        isActive: conversation.isActive,
        createdAt: conversation.createdAt,
      );
    }
  }

  void _simulateDoctorResponse() {
    final responses = [
      'Thank you for your message. I\'ll review your concerns and get back to you shortly.',
      'I understand your symptoms. Let me schedule a follow-up appointment to discuss this further.',
      'Based on your description, I recommend continuing with the current treatment plan.',
      'Please monitor your symptoms and let me know if there are any changes.',
      'I\'ve reviewed your test results. Everything looks good, but let\'s keep monitoring.',
      'Thank you for the update. Your progress is excellent!',
      'I\'ll send you a prescription refill request to the pharmacy.',
      'Let\'s schedule a video consultation to discuss this in detail.',
    ];

    Future.delayed(Duration(seconds: 2 + (DateTime.now().millisecond % 3)), () {
      final randomResponse =
          responses[DateTime.now().millisecond % responses.length];

      final doctorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: _getDoctorIdFromConversation(_currentConversationId),
        senderName: _getDoctorNameFromConversation(_currentConversationId),
        senderAvatar: null,
        receiverId: 'patient_id',
        receiverName: 'Abdullah Alshahrani',
        receiverAvatar: null,
        content: randomResponse,
        type: MessageType.text,
        timestamp: DateTime.now(),
        status: MessageStatus.delivered,
        isFromPatient: false,
      );

      _messages.add(doctorMessage);
      _updateConversationLastMessage(_currentConversationId, randomResponse);
      notifyListeners();
    });
  }

  List<ChatConversation> _getMockConversations() {
    return [
      ChatConversation(
        id: 'conv_1',
        patientId: 'patient_1',
        patientName: 'Abdullah Alshahrani',
        patientAvatar: null,
        doctorId: 'doctor_1',
        doctorName: 'Dr. Sarah Johnson',
        doctorAvatar:
            'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=150',
        doctorSpecialty: 'Cardiology',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        lastMessage: 'Thank you for your message. I\'ll review your concerns.',
        unreadCount: 0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      ChatConversation(
        id: 'conv_2',
        patientId: 'patient_1',
        patientName: 'Abdullah Alshahrani',
        patientAvatar: null,
        doctorId: 'doctor_2',
        doctorName: 'Dr. Michael Chen',
        doctorAvatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        doctorSpecialty: 'Dentist',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        lastMessage: 'Your appointment is confirmed for tomorrow at 2 PM.',
        unreadCount: 1,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ChatConversation(
        id: 'conv_3',
        patientId: 'patient_1',
        patientName: 'Abdullah Alshahrani',
        patientAvatar: null,
        doctorId: 'doctor_3',
        doctorName: 'Dr. Emily Rodriguez',
        doctorAvatar:
            'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=150',
        doctorSpecialty: 'Dermatology',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        lastMessage: 'The treatment is working well. Continue as prescribed.',
        unreadCount: 0,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
      ChatConversation(
        id: 'conv_4',
        patientId: 'patient_1',
        patientName: 'Abdullah Alshahrani',
        patientAvatar: null,
        doctorId: 'doctor_4',
        doctorName: 'Dr. David Wilson',
        doctorAvatar:
            'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=150',
        doctorSpecialty: 'Neurologist',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 3)),
        lastMessage: 'Please schedule a follow-up appointment.',
        unreadCount: 0,
        isActive: false,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];
  }

  List<ChatMessage> _getMockMessages(String conversationId) {
    final baseTime = DateTime.now().subtract(const Duration(hours: 2));

    switch (conversationId) {
      case 'conv_1':
        return [
          ChatMessage(
            id: 'msg_1',
            senderId: 'patient_1',
            senderName: 'Abdullah Alshahrani',
            receiverId: 'doctor_1',
            receiverName: 'Dr. Sarah Johnson',
            content:
                'Hello Dr. Sarah, I have some concerns about my blood pressure medication.',
            type: MessageType.text,
            timestamp: baseTime,
            status: MessageStatus.read,
            isFromPatient: true,
          ),
          ChatMessage(
            id: 'msg_2',
            senderId: 'doctor_1',
            senderName: 'Dr. Sarah Johnson',
            receiverId: 'patient_1',
            receiverName: 'Abdullah Alshahrani',
            content:
                'Hello Abdullah, I\'m here to help. What specific concerns do you have?',
            type: MessageType.text,
            timestamp: baseTime.add(const Duration(minutes: 2)),
            status: MessageStatus.read,
            isFromPatient: false,
          ),
          ChatMessage(
            id: 'msg_3',
            senderId: 'patient_1',
            senderName: 'Abdullah Alshahrani',
            receiverId: 'doctor_1',
            receiverName: 'Dr. Sarah Johnson',
            content:
                'I\'ve been experiencing some dizziness in the morning. Should I be worried?',
            type: MessageType.text,
            timestamp: baseTime.add(const Duration(minutes: 5)),
            status: MessageStatus.read,
            isFromPatient: true,
          ),
          ChatMessage(
            id: 'msg_4',
            senderId: 'doctor_1',
            senderName: 'Dr. Sarah Johnson',
            receiverId: 'patient_1',
            receiverName: 'Abdullah Alshahrani',
            content:
                'Thank you for your message. I\'ll review your concerns and get back to you shortly.',
            type: MessageType.text,
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            status: MessageStatus.delivered,
            isFromPatient: false,
          ),
        ];

      case 'conv_2':
        return [
          ChatMessage(
            id: 'msg_5',
            senderId: 'doctor_2',
            senderName: 'Dr. Michael Chen',
            receiverId: 'patient_1',
            receiverName: 'Abdullah Alshahrani',
            content:
                'Your appointment is confirmed for tomorrow at 2 PM. Please arrive 15 minutes early.',
            type: MessageType.text,
            timestamp: baseTime,
            status: MessageStatus.delivered,
            isFromPatient: false,
          ),
        ];

      default:
        return [
          ChatMessage(
            id: 'msg_default',
            senderId: 'doctor_1',
            senderName: 'Doctor',
            receiverId: 'patient_1',
            receiverName: 'Abdullah Alshahrani',
            content: 'Hello! How can I help you today?',
            type: MessageType.text,
            timestamp: baseTime,
            status: MessageStatus.read,
            isFromPatient: false,
          ),
        ];
    }
  }

  String formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  String formatConversationTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
