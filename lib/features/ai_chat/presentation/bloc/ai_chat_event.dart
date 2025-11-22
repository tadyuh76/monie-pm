abstract class AIChatEvent {}

/// Sự kiện gửi tin nhắn mới
class SendMessageEvent extends AIChatEvent {
  final String message;
  final String userId; // Trong thực tế, userId thường lấy từ AuthBloc/Session

  SendMessageEvent({required this.message, required this.userId});
}

/// (Optional) Sự kiện reset chat nếu muốn làm nút "Clear Chat"
class ClearChatEvent extends AIChatEvent {}
