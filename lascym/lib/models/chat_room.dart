import 'message.dart';

class ChatRoom {
  final String id;
  final String name;
  final List<String> participantIds;
  final List<String> participantNames;
  final Message? lastMessage;
  final DateTime? lastMessageTime;

  ChatRoom({
    required this.id,
    required this.name,
    required this.participantIds,
    required this.participantNames,
    this.lastMessage,
    this.lastMessageTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'participantIds': participantIds,
      'participantNames': participantNames,
      'lastMessage': lastMessage?.toMap(),
      'lastMessageTime': lastMessageTime?.toIso8601String(),
    };
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      participantIds: List<String>.from(map['participantIds'] ?? []),
      participantNames: List<String>.from(map['participantNames'] ?? []),
      lastMessage: map['lastMessage'] != null
          ? Message.fromMap(map['lastMessage'])
          : null,
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.parse(map['lastMessageTime'])
          : null,
    );
  }
}
