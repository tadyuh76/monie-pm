import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:monie/features/ai_insights/domain/usecases/analyze_spending_pattern_usecase.dart';
import 'package:monie/features/ai_insights/presentation/bloc/spending_pattern_event.dart';
import 'package:monie/features/ai_insights/presentation/bloc/spending_pattern_state.dart';

@injectable
class SpendingPatternBloc extends Bloc<SpendingPatternEvent, SpendingPatternState> {
  final AnalyzeSpendingPatternUseCase analyzeSpendingPattern;

  SpendingPatternBloc({
    required this.analyzeSpendingPattern,
  }) : super(SpendingPatternInitial()) {
    on<AnalyzeSpendingPatternEvent>(_onAnalyzeSpendingPattern);
    on<RefreshSpendingPatternEvent>(_onRefreshSpendingPattern);
  }

  Future<void> _onAnalyzeSpendingPattern(
    AnalyzeSpendingPatternEvent event,
    Emitter<SpendingPatternState> emit,
  ) async {
    emit(SpendingPatternLoading());

    try {
      final pattern = await analyzeSpendingPattern(
        userId: event.userId,
        monthsBack: event.monthsBack,
        useCache: event.useCache,
      );

      emit(SpendingPatternLoaded(
        pattern: pattern,
        isFromCache: event.useCache,
      ));
    } catch (e) {
      emit(SpendingPatternError(e.toString()));
    }
  }

  Future<void> _onRefreshSpendingPattern(
    RefreshSpendingPatternEvent event,
    Emitter<SpendingPatternState> emit,
  ) async {
    emit(SpendingPatternLoading());

    try {
      final pattern = await analyzeSpendingPattern(
        userId: event.userId,
        monthsBack: event.monthsBack,
        useCache: false, // Force refresh
      );

      emit(SpendingPatternLoaded(
        pattern: pattern,
        isFromCache: false,
      ));
    } catch (e) {
      emit(SpendingPatternError(e.toString()));
    }
  }
}
