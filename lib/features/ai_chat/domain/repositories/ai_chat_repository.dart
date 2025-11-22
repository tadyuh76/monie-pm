import 'package:monie/features/ai_chat/domain/entities/chat_message.dart';
import 'package:monie/features/ai_chat/domain/entities/financial_context.dart';

abstract class AIChatRepository {
  /// Lấy context tài chính mới nhất của user
  Future<FinancialContext> getFinancialContext(String userId);

  /// Gửi tin nhắn tới AI và nhận phản hồi
  Future<ChatMessage> sendMessage({
    required String message,
    required FinancialContext context,
  });
  
  /// Reset phiên chat (nếu cần)
  void resetSession();
}
