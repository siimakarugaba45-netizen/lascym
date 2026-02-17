class Message {
  final String id;
  final String content;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final String? replyToId;
  final String? replyToContent;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    this.replyToId,
    this.replyToContent,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': timestamp.toIso8601String(),
      'replyToId': replyToId,
      'replyToContent': replyToContent,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      replyToId: map['replyToId'],
      replyToContent: map['replyToContent'],
    );
  }
}
