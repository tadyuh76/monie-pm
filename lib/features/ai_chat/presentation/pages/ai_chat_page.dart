import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monie/di/injection.dart'; // Service Locator
import 'package:monie/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:monie/features/ai_chat/presentation/bloc/ai_chat_bloc.dart';
import 'package:monie/features/ai_chat/presentation/bloc/ai_chat_event.dart';
import 'package:monie/features/ai_chat/presentation/bloc/ai_chat_state.dart';
import 'package:monie/features/ai_chat/presentation/widgets/chat_bubble.dart';
import 'package:monie/features/ai_chat/presentation/widgets/chat_input_field.dart';
import 'package:monie/features/ai_chat/presentation/widgets/typing_indicator.dart';
import 'package:monie/features/authentication/presentation/bloc/auth_state.dart';

class AIChatPage extends StatelessWidget {
  const AIChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Bloc
    return BlocProvider(
      create: (context) => AIChatBloc(
        sendChatMessageUseCase: sl(), // Lấy từ DI
      ),
      child: const _AIChatView(),
    );
  }
}

class _AIChatView extends StatelessWidget {
  const _AIChatView();

  @override
  Widget build(BuildContext context) {
    // Lấy userId từ AuthBloc (để gửi kèm request)
    final authState = context.read<AuthBloc>().state;
    final userId = (authState is Authenticated) ? authState.user.id : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Financial Assistant"),
        centerTitle: true,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // 1. Danh sách tin nhắn
          Expanded(
            child: BlocBuilder<AIChatBloc, AIChatState>(
              builder: (context, state) {
                if (state.messages.isEmpty && !state.isLoading) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  reverse: true, // Tin mới nhất ở dưới cùng
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: state.messages.length + (state.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Nếu đang loading và là item đầu tiên (index 0 vì reverse), hiện typing
                    if (state.isLoading && index == 0) {
                      return const TypingIndicator();
                    }
                    
                    // Tính lại index thật trong list messages
                    final msgIndex = state.isLoading ? index - 1 : index;
                    final message = state.messages[msgIndex];
                    
                    return ChatBubble(message: message);
                  },
                );
              },
            ),
          ),

          // 2. Thanh nhập liệu
          ChatInputField(
            onSend: (text) {
              context.read<AIChatBloc>().add(
                SendMessageEvent(message: text, userId: userId),
              );
            },
          ),
        ],
      ),
    );
  }

  // Gợi ý câu hỏi khi chưa có tin nhắn
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            "How can I help you today?",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          // Gợi ý
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildSuggestionChip(context, "Analyze my spending"),
              _buildSuggestionChip(context, "Am I over budget?"),
              _buildSuggestionChip(context, "Predict next month"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(BuildContext context, String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        final authState = context.read<AuthBloc>().state;
        final userId = (authState is Authenticated) ? authState.user.id : '';
        
        context.read<AIChatBloc>().add(
          SendMessageEvent(message: text, userId: userId),
        );
      },
    );
  }
}
