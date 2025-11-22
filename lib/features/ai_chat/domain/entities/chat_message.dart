class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<ChatAttachment>? attachments;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.attachments,
  });
}

class ChatAttachment {
  final String type; // 'chart', 'card', etc.
  final Map<String, dynamic> data;

  const ChatAttachment({
    required this.type,
    required this.data,
  });
}
