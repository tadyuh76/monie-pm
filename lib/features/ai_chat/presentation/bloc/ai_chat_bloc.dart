import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monie/features/ai_chat/domain/entities/chat_message.dart';
import 'package:monie/features/ai_chat/domain/usecases/send_chat_message_usecase.dart';
import 'package:monie/features/ai_chat/presentation/bloc/ai_chat_event.dart';
import 'package:monie/features/ai_chat/presentation/bloc/ai_chat_state.dart';

class AIChatBloc extends Bloc<AIChatEvent, AIChatState> {
  final SendChatMessageUseCase sendChatMessageUseCase;

  AIChatBloc({required this.sendChatMessageUseCase}) : super(const AIChatState()) {
    on<SendMessageEvent>(_onSendMessage);
    on<ClearChatEvent>(_onClearChat);
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<AIChatState> emit,
  ) async {
    if (event.message.trim().isEmpty) return;

    // 1. Hiển thị ngay tin nhắn của User lên màn hình (Optimistic UI)
    final userMessage = ChatMessage(
      text: event.message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final currentMessages = List<ChatMessage>.from(state.messages);
    emit(state.copyWith(
      status: AIChatStatus.loading, // Để hiện typing indicator
      messages: [userMessage, ...currentMessages], // Thêm vào đầu list (reverse listview)
    ));

    try {
      // 2. Gọi UseCase để lấy phản hồi từ AI
      final aiResponse = await sendChatMessageUseCase.call(
        userId: event.userId,
        message: event.message,
      );

      // 3. Cập nhật tin nhắn AI vào list
      final updatedMessages = [aiResponse, ...state.messages];
      emit(state.copyWith(
        status: AIChatStatus.success,
        messages: updatedMessages,
      ));
    } catch (e) {
      // Xử lý lỗi nhưng vẫn giữ tin nhắn cũ
      emit(state.copyWith(
        status: AIChatStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onClearChat(ClearChatEvent event, Emitter<AIChatState> emit) {
    // Nếu có repo reset session thì gọi ở đây
    emit(const AIChatState(messages: []));
  }
}
