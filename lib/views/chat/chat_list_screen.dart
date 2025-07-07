import 'package:flutter/material.dart';
import '../../core/views/base_view.dart';
import '../../viewmodels/chat_view_model.dart';
import '../../core/theme/app_colors.dart';
import '../../models/chat_message.dart';
import 'chat_screen.dart';
import 'widgets/conversation_card.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<ChatViewModel>(
      viewModelBuilder: () => ChatViewModel(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Chat with Doctors',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showSearchDialog(context, model),
              tooltip: 'Search',
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showOptionsDialog(context),
              tooltip: 'More Options',
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(model),
            Expanded(child: _buildConversationsList(context, model)),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showNewChatDialog(context, model),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.chat, color: Colors.white),
          tooltip: 'New Chat',
        ),
      ),
    );
  }

  Widget _buildSearchBar(ChatViewModel model) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: model.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: model.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () => model.setSearchQuery(''),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildConversationsList(BuildContext context, ChatViewModel model) {
    if (model.busy) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading conversations...'),
          ],
        ),
      );
    }

    if (model.conversations.isEmpty) {
      return _buildEmptyState(context, model);
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh conversations
        model.init();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: model.conversations.length,
        itemBuilder: (context, index) {
          final conversation = model.conversations[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ConversationCard(
              conversation: conversation,
              onTap: () => _navigateToChat(context, model, conversation),
              onLongPress: () =>
                  _showConversationOptions(context, conversation),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ChatViewModel model) {
    String message;
    IconData icon;

    if (model.searchQuery.isNotEmpty) {
      message = 'No conversations found for "${model.searchQuery}"';
      icon = Icons.search_off;
    } else {
      message = 'No conversations yet';
      icon = Icons.chat_bubble_outline;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          if (model.searchQuery.isEmpty)
            Text(
              'Start a conversation with your doctor',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          const SizedBox(height: 24),
          if (model.searchQuery.isEmpty)
            ElevatedButton.icon(
              onPressed: () => _showNewChatDialog(context, model),
              icon: const Icon(Icons.chat),
              label: const Text('Start New Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToChat(
    BuildContext context,
    ChatViewModel model,
    ChatConversation conversation,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(conversation: conversation),
      ),
    );
  }

  void _showSearchDialog(BuildContext context, ChatViewModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Conversations'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search by doctor name or specialty...',
            border: OutlineInputBorder(),
          ),
          onChanged: model.setSearchQuery,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showNewChatDialog(BuildContext context, ChatViewModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Chat'),
        content: const Text(
          'This feature will allow you to start a new conversation with any available doctor. Coming soon!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showConversationOptions(
    BuildContext context,
    ChatConversation conversation,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archive Conversation'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement archive functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Conversation archived')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Conversation',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, conversation);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ChatConversation conversation,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: Text(
          'Are you sure you want to delete the conversation with ${conversation.doctorName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conversation deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chat Options'),
        content: const Text('Additional chat features coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
