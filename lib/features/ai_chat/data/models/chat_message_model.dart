import 'package:monie/features/ai_chat/domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.text,
    required super.isUser,
    required super.timestamp,
    super.attachments,
  });

  // Helper để parse JSON attachments từ AI response
  static List<ChatAttachmentModel>? parseAttachments(List<dynamic>? jsonList) {
    if (jsonList == null) return null;
    return jsonList.map((e) => ChatAttachmentModel.fromJson(e)).toList();
  }
}

class ChatAttachmentModel extends ChatAttachment {
  const ChatAttachmentModel({
    required super.type,
    required super.data,
  });

  factory ChatAttachmentModel.fromJson(Map<String, dynamic> json) {
    return ChatAttachmentModel(
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>,
    );
  }
}
