import 'package:monie/features/ai_chat/domain/entities/chat_message.dart';
import 'package:monie/features/ai_chat/domain/repositories/ai_chat_repository.dart';

class SendChatMessageUseCase {
  final AIChatRepository repository;

  SendChatMessageUseCase({required this.repository});

  Future<ChatMessage> call({
    required String userId,
    required String message,
  }) async {
    // 1. Lấy context tài chính mới nhất trước khi chat
    final context = await repository.getFinancialContext(userId);
    
    // 2. Gửi tin nhắn kèm context
    return repository.sendMessage(
      message: message,
      context: context,
    );
  }
}
