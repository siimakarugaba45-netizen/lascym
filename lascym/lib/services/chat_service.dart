import '../models/message.dart';
import '../models/chat_room.dart';

class ChatService {
  // Current user ID and name (in a real app, this would come from auth)
  static const String currentUserId = 'current_user';
  static const String currentUserName = 'Me';

  // Mock data for colleagues
  static final List<Map<String, String>> colleagues = [
    {'id': 'user_1', 'name': 'Alice Johnson'},
    {'id': 'user_2', 'name': 'Bob Smith'},
    {'id': 'user_3', 'name': 'Charlie Brown'},
    {'id': 'user_4', 'name': 'Diana Prince'},
    {'id': 'user_5', 'name': 'Ethan Hunt'},
  ];

  // Mock chat rooms
  static final List<ChatRoom> chatRooms = [
    ChatRoom(
      id: 'room_1',
      name: 'Engineering Team',
      participantIds: ['current_user', 'user_1', 'user_2', 'user_3'],
      participantNames: ['Me', 'Alice Johnson', 'Bob Smith', 'Charlie Brown'],
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ChatRoom(
      id: 'room_2',
      name: 'Project Alpha',
      participantIds: ['current_user', 'user_1', 'user_4'],
      participantNames: ['Me', 'Alice Johnson', 'Diana Prince'],
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ChatRoom(
      id: 'room_3',
      name: 'General',
      participantIds: ['current_user', 'user_2', 'user_3', 'user_5'],
      participantNames: ['Me', 'Bob Smith', 'Charlie Brown', 'Ethan Hunt'],
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // Mock messages for each chat room
  static final Map<String, List<Message>> _messages = {
    'room_1': [
      Message(
        id: 'msg_1',
        content: 'Hey team, how is the project going?',
        senderId: 'user_1',
        senderName: 'Alice Johnson',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Message(
        id: 'msg_2',
        content: 'Going well! Just finished the backend integration.',
        senderId: 'user_2',
        senderName: 'Bob Smith',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      ),
      Message(
        id: 'msg_3',
        content: 'Great work Bob! I will start testing the API endpoints.',
        senderId: 'user_3',
        senderName: 'Charlie Brown',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      ),
      Message(
        id: 'msg_4',
        content: 'Let me know if you need any help with the frontend.',
        senderId: 'user_1',
        senderName: 'Alice Johnson',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Message(
        id: 'msg_5',
        content: 'Thanks Alice! Will do.',
        senderId: 'user_3',
        senderName: 'Charlie Brown',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Message(
        id: 'msg_6',
        content: 'Team meeting at 3 PM today. Please join!',
        senderId: 'user_1',
        senderName: 'Alice Johnson',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ],
    'room_2': [
      Message(
        id: 'msg_7',
        content: 'Hi everyone, ready for the sprint review?',
        senderId: 'user_4',
        senderName: 'Diana Prince',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Message(
        id: 'msg_8',
        content: 'Yes! I have prepared the demo slides.',
        senderId: 'user_1',
        senderName: 'Alice Johnson',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
      ),
      Message(
        id: 'msg_9',
        content: 'Looking forward to it!',
        senderId: currentUserId,
        senderName: currentUserName,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Message(
        id: 'msg_10',
        content: 'Great! See you all there.',
        senderId: 'user_4',
        senderName: 'Diana Prince',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ],
    'room_3': [
      Message(
        id: 'msg_11',
        content: 'Anyone up for lunch today?',
        senderId: 'user_2',
        senderName: 'Bob Smith',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      ),
      Message(
        id: 'msg_12',
        content: 'Count me in!',
        senderId: 'user_3',
        senderName: 'Charlie Brown',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      ),
      Message(
        id: 'msg_13',
        content: 'Same here!',
        senderId: 'user_5',
        senderName: 'Ethan Hunt',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      ),
    ],
  };

  // Get all chat rooms
  List<ChatRoom> getChatRooms() {
    return chatRooms;
  }

  // Get messages for a specific chat room
  List<Message> getMessages(String roomId) {
    return _messages[roomId] ?? [];
  }

  // Send a new message
  void sendMessage(String roomId, String content, {String? replyToId, String? replyToContent}) {
    final message = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      senderId: currentUserId,
      senderName: currentUserName,
      timestamp: DateTime.now(),
      replyToId: replyToId,
      replyToContent: replyToContent,
    );

    if (_messages.containsKey(roomId)) {
      _messages[roomId]!.add(message);
    } else {
      _messages[roomId] = [message];
    }
  }

  // Get a specific message by ID
  Message? getMessage(String roomId, String messageId) {
    final messages = _messages[roomId];
    if (messages == null) return null;
    
    try {
      return messages.firstWhere((msg) => msg.id == messageId);
    } catch (e) {
      return null;
    }
  }
}
