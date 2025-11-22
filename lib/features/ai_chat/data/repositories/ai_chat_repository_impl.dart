import 'package:monie/features/ai_chat/domain/entities/chat_message.dart';
import 'package:monie/features/ai_chat/domain/entities/financial_context.dart';
import 'package:monie/features/ai_chat/domain/repositories/ai_chat_repository.dart';
import 'package:monie/features/ai_chat/data/datasources/ai_chat_remote_data_source.dart';
import 'package:monie/features/ai_chat/data/datasources/financial_context_builder.dart';

class AIChatRepositoryImpl implements AIChatRepository {
  final AIChatRemoteDataSource remoteDataSource;
  final FinancialContextBuilder contextBuilder;

  AIChatRepositoryImpl({
    required this.remoteDataSource,
    required this.contextBuilder,
  });

  @override
  Future<FinancialContext> getFinancialContext(String userId) {
    return contextBuilder.build(userId);
  }

  @override
  Future<ChatMessage> sendMessage({
    required String message,
    required FinancialContext context,
  }) async {
    return remoteDataSource.sendMessage(
      message: message,
      systemContext: context.toPromptContext(),
    );
  }

  @override
  void resetSession() {
    remoteDataSource.resetSession();
  }
}
