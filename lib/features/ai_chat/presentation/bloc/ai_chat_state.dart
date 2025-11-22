import 'package:monie/features/ai_chat/domain/entities/chat_message.dart';

enum AIChatStatus { initial, loading, success, failure }

class AIChatState {
  final AIChatStatus status;
  final List<ChatMessage> messages;
  final String? errorMessage;

  // Helper getter để check loading cho UI
  bool get isLoading => status == AIChatStatus.loading;

  const AIChatState({
    this.status = AIChatStatus.initial,
    this.messages = const [],
    this.errorMessage,
  });

  AIChatState copyWith({
    AIChatStatus? status,
    List<ChatMessage>? messages,
    String? errorMessage,
  }) {
    return AIChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
