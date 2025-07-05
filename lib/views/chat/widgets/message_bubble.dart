import 'package:flutter/material.dart';
import '../../../models/chat_message.dart';
import '../../../core/theme/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showTime;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.showTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: message.isFromPatient
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: message.isFromPatient
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!message.isFromPatient) ...[
              _buildAvatar(),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: _buildMessageContent(),
            ),
            if (message.isFromPatient) ...[
              const SizedBox(width: 8),
              _buildAvatar(),
            ],
          ],
        ),
        if (showTime) ...[
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(
              left: message.isFromPatient ? 0 : 50,
              right: message.isFromPatient ? 50 : 0,
            ),
            child: Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: message.isFromPatient
            ? AppColors.primary.withOpacity(0.1)
            : Colors.grey[300],
      ),
      child: message.senderAvatar != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                message.senderAvatar!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildAvatarIcon(),
              ),
            )
          : _buildAvatarIcon(),
    );
  }

  Widget _buildAvatarIcon() {
    return Icon(
      message.isFromPatient ? Icons.person : Icons.medical_services,
      size: 16,
      color: message.isFromPatient ? AppColors.primary : Colors.grey[600],
    );
  }

  Widget _buildMessageContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: message.isFromPatient ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20).copyWith(
          bottomLeft: message.isFromPatient
              ? const Radius.circular(20)
              : const Radius.circular(4),
          bottomRight: message.isFromPatient
              ? const Radius.circular(4)
              : const Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMessageText(),
          if (message.type != MessageType.text) ...[
            const SizedBox(height: 8),
            _buildMessageAttachment(),
          ],
          if (message.isFromPatient) ...[
            const SizedBox(height: 4),
            _buildMessageStatus(),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageText() {
    return Text(
      message.content,
      style: TextStyle(
        color: message.isFromPatient ? Colors.white : AppColors.textBlack,
        fontSize: 14,
      ),
    );
  }

  Widget _buildMessageAttachment() {
    switch (message.type) {
      case MessageType.image:
        return _buildImageAttachment();
      case MessageType.file:
        return _buildFileAttachment();
      case MessageType.prescription:
        return _buildPrescriptionAttachment();
      case MessageType.appointment:
        return _buildAppointmentAttachment();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildImageAttachment() {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.image, size: 32, color: Colors.grey),
      ),
    );
  }

  Widget _buildFileAttachment() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.attach_file, color: Colors.grey),
          const SizedBox(width: 8),
          const Text('Document.pdf', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPrescriptionAttachment() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.medication, color: Colors.blue),
          const SizedBox(width: 8),
          const Text('Prescription',
              style: TextStyle(fontSize: 12, color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildAppointmentAttachment() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, color: Colors.green),
          const SizedBox(width: 8),
          const Text('Appointment',
              style: TextStyle(fontSize: 12, color: Colors.green)),
        ],
      ),
    );
  }

  Widget _buildMessageStatus() {
    IconData statusIcon;
    Color statusColor;

    switch (message.status) {
      case MessageStatus.sent:
        statusIcon = Icons.check;
        statusColor = Colors.grey[400]!;
        break;
      case MessageStatus.delivered:
        statusIcon = Icons.done_all;
        statusColor = Colors.grey[400]!;
        break;
      case MessageStatus.read:
        statusIcon = Icons.done_all;
        statusColor = Colors.blue;
        break;
      case MessageStatus.failed:
        statusIcon = Icons.error;
        statusColor = Colors.red;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          statusIcon,
          size: 14,
          color: statusColor,
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday at ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month}/${time.year} at ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
