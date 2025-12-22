import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/core.dart';
import '../../../core/state/state.dart';
import 'chat_screen.dart';

class ChatsListScreen extends ConsumerStatefulWidget {
  const ChatsListScreen({super.key});

  @override
  ConsumerState<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends ConsumerState<ChatsListScreen> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  
  List<Map<String, dynamic>> _chats = [];
  bool _isLoading = true;
  Map<String, dynamic>? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadChats();
  }

  Future<void> _loadCurrentUser() async {
    _currentUser = await _authService.getUser();
  }

  Future<void> _loadChats() async {
    setState(() => _isLoading = true);
    try {
      final result = await _chatService.getChats();
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _chats = List<Map<String, dynamic>>.from(result['data']);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(isDarkMode)),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFff6f2d)))
                    : _chats.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadChats,
                            color: const Color(0xFFff6f2d),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _chats.length,
                              itemBuilder: (context, index) => _buildChatItem(_chats[index]),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Messages',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Start chatting with landlords about apartments',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat) {
    final otherUser = _getOtherUser(chat);
    final apartment = chat['apartment'];
    final lastMessage = chat['last_message'];
    final lastMessageTime = lastMessage != null 
        ? DateTime.tryParse(lastMessage['created_at'] ?? '') 
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFFff6f2d),
          child: Text(
            (otherUser?['first_name']?.toString().substring(0, 1).toUpperCase() ?? 'U'),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        title: Text(
          '${otherUser?['first_name'] ?? ''} ${otherUser?['last_name'] ?? ''}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              apartment?['title'] ?? 'Apartment',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
            ),
            if (lastMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                lastMessage['message'] ?? '',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: lastMessageTime != null
            ? Text(
                _formatTime(lastMessageTime),
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
              )
            : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                chatId: chat['id'].toString(),
                otherUserName: '${otherUser?['first_name'] ?? ''} ${otherUser?['last_name'] ?? ''}',
                apartmentTitle: apartment?['title'] ?? 'Apartment',
              ),
            ),
          );
        },
      ),
    );
  }

  Map<String, dynamic>? _getOtherUser(Map<String, dynamic> chat) {
    final tenant = chat['tenant'];
    final landlord = chat['landlord'];
    final currentUserId = _currentUser?['id'].toString();
    
    if (tenant?['id'].toString() == currentUserId) {
      return landlord;
    } else {
      return tenant;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}