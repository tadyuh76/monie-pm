import 'dart:convert';
import 'package:monie/core/services/gemini_service.dart';
import 'package:monie/features/ai_chat/data/models/chat_message_model.dart';
import 'package:google_generative_ai/google_generative_ai.dart'; // Để dùng type ChatSession nếu cần

class AIChatRemoteDataSource {
  final GeminiService _geminiService;
  ChatSession? _chatSession;

  AIChatRemoteDataSource({required GeminiService geminiService})
      : _geminiService = geminiService;

  Future<ChatMessageModel> sendMessage({
    required String message,
    required String systemContext,
  }) async {
    // Init session nếu chưa có
    _chatSession ??= _geminiService.startChatSession(systemContext: systemContext);

    try {
      // Gửi tin nhắn qua session của GeminiService
      // Lưu ý: Cần update GeminiService để expose method sendMessage trong session
      // Hoặc dùng _geminiService.model.startChat() trực tiếp ở đây nếu GeminiService chỉ expose model.
      
      // Giả sử GeminiService expose session:
      final response = await _chatSession!.sendMessage(Content.text(message));
      final rawText = response.text ?? '';

      // Parse Attachments (JSON embedded)
      String displayText = rawText;
      List<ChatAttachmentModel>? attachments;

      try {
        final jsonStart = rawText.indexOf('{');
        final jsonEnd = rawText.lastIndexOf('}');
        
        if (jsonStart != -1 && jsonEnd != -1) {
          final jsonStr = rawText.substring(jsonStart, jsonEnd + 1);
          final jsonData = jsonDecode(jsonStr);
          
          // Tách text và attachments
          if (jsonData.containsKey('text')) {
            displayText = jsonData['text'];
          }
          if (jsonData.containsKey('attachments')) {
            attachments = ChatMessageModel.parseAttachments(jsonData['attachments']);
          }
        }
      } catch (e) {
        // JSON parse fail, fallback to raw text
        print('JSON Parse Error in AI Chat: $e');
      }

      return ChatMessageModel(
        text: displayText,
        isUser: false,
        timestamp: DateTime.now(),
        attachments: attachments,
      );
    } catch (e) {
      _chatSession = null; // Reset session on error
      throw Exception('Failed to communicate with AI: $e');
    }
  }

  void resetSession() {
    _chatSession = null;
  }
}
