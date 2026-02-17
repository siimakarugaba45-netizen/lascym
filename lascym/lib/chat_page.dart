import 'package:flutter/material.dart';
import 'models/message.dart';
import 'models/chat_room.dart';
import 'services/chat_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatRoom> _chatRooms = [];
  ChatRoom? _selectedChatRoom;
  List<Message> _messages = [];
  Message? _replyToMessage;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  void _loadChatRooms() {
    setState(() {
      _chatRooms = _chatService.getChatRooms();
    });
  }

  void _loadMessages(String roomId) {
    setState(() {
      _selectedChatRoom = _chatRooms.firstWhere((room) => room.id == roomId);
      _messages = _chatService.getMessages(roomId);
      _replyToMessage = null;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
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

  void _sendMessage() {
    if (_controller.text.isNotEmpty && _selectedChatRoom != null) {
      _chatService.sendMessage(
        _selectedChatRoom!.id,
        _controller.text,
        replyToId: _replyToMessage?.id,
        replyToContent: _replyToMessage?.content,
      );
      setState(() {
        _messages = _chatService.getMessages(_selectedChatRoom!.id);
        _controller.clear();
        _replyToMessage = null;
      });
      _scrollToBottom();
    }
  }

  void _setReplyTo(Message message) {
    setState(() {
      _replyToMessage = message;
    });
  }

  void _cancelReply() {
    setState(() {
      _replyToMessage = null;
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedChatRoom?.name ?? 'Select Chat'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _selectedChatRoom == null
          ? _buildChatRoomList()
          : _buildChatView(),
    );
  }

  Widget _buildChatRoomList() {
    return ListView.builder(
      itemCount: _chatRooms.length,
      itemBuilder: (context, index) {
        final room = _chatRooms[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.deepPurple,
            child: Text(
              room.name[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(room.name),
          subtitle: Text(
            '${room.participantNames.length} participants',
            style: TextStyle(color: Colors.grey[600]),
          ),
          trailing: room.lastMessageTime != null
              ? Text(
                  _formatTime(room.lastMessageTime!),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                )
              : null,
          onTap: () => _loadMessages(room.id),
        );
      },
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        // Back button and chat room info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: Colors.grey[200],
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedChatRoom = null;
                    _messages = [];
                  });
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedChatRoom!.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _selectedChatRoom!.participantNames.join(', '),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Messages list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final isCurrentUser = message.senderId == ChatService.currentUserId;
              return _buildMessageBubble(message, isCurrentUser);
            },
          ),
        ),
        
        // Reply preview
        if (_replyToMessage != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[200],
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  color: Colors.deepPurple,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Replying to ${_replyToMessage!.senderName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _replyToMessage!.content,
                        style: TextStyle(color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: _cancelReply,
                ),
              ],
            ),
          ),
        
        // Message input
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(Message message, bool isCurrentUser) {
    return GestureDetector(
      onLongPress: () => _showMessageOptions(message),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment:
              isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isCurrentUser) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[400],
                child: Text(
                  message.senderName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCurrentUser ? Colors.deepPurple : Colors.grey[300],
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
                    bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isCurrentUser)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          message.senderName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.deepPurple[700],
                          ),
                        ),
                      ),
                    if (message.replyToContent != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isCurrentUser
                              ? Colors.deepPurple[300]
                              : Colors.grey[400],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Replying to message',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isCurrentUser
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                            Text(
                              message.replyToContent!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isCurrentUser
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isCurrentUser ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: isCurrentUser ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(Message message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(context);
                _setReplyTo(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
