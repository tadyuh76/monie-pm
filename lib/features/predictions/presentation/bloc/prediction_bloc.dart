// lib/features/predictions/presentation/bloc/prediction_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:monie/features/predictions/domain/usecases/predict_spending_usecase.dart';
import 'package:monie/features/predictions/presentation/bloc/prediction_event.dart';
import 'package:monie/features/predictions/presentation/bloc/prediction_state.dart';

@injectable
class PredictionBloc extends Bloc<PredictionEvent, PredictionState> {
  final PredictSpendingUseCase predictSpendingUseCase;

  PredictionBloc({
    required this.predictSpendingUseCase,
  }) : super(const PredictionInitial()) {
    on<PredictNextMonthEvent>(_onPredictNextMonth);
    on<PredictNextWeekEvent>(_onPredictNextWeek);
    on<PredictNextQuarterEvent>(_onPredictNextQuarter);
    on<PredictCustomPeriodEvent>(_onPredictCustomPeriod);
    on<RefreshPredictionEvent>(_onRefreshPrediction);
  }

  Future<void> _onPredictNextMonth(
    PredictNextMonthEvent event,
    Emitter<PredictionState> emit,
  ) async {
    emit(const PredictionLoading());

    try {
      final prediction = await predictSpendingUseCase.predictNextMonth(
        userId: event.userId,
        budget: event.budget,
        useCache: !event.forceRefresh,
      );

      emit(PredictionLoaded(prediction: prediction));
    } catch (e) {
      emit(PredictionError(e.toString()));
    }
  }

  Future<void> _onPredictNextWeek(
    PredictNextWeekEvent event,
    Emitter<PredictionState> emit,
  ) async {
    emit(const PredictionLoading());

    try {
      final prediction = await predictSpendingUseCase.predictNextWeek(
        userId: event.userId,
        budget: event.budget,
      );

      emit(PredictionLoaded(prediction: prediction));
    } catch (e) {
      emit(PredictionError(e.toString()));
    }
  }

  Future<void> _onPredictNextQuarter(
    PredictNextQuarterEvent event,
    Emitter<PredictionState> emit,
  ) async {
    emit(const PredictionLoading());

    try {
      final prediction = await predictSpendingUseCase.predictNextQuarter(
        userId: event.userId,
        budget: event.budget,
      );

      emit(PredictionLoaded(prediction: prediction));
    } catch (e) {
      emit(PredictionError(e.toString()));
    }
  }

  Future<void> _onPredictCustomPeriod(
    PredictCustomPeriodEvent event,
    Emitter<PredictionState> emit,
  ) async {
    emit(const PredictionLoading());

    try {
      final prediction = await predictSpendingUseCase(
        userId: event.userId,
        targetStartDate: event.startDate,
        targetEndDate: event.endDate,
        budget: event.budget,
      );

      emit(PredictionLoaded(prediction: prediction));
    } catch (e) {
      emit(PredictionError(e.toString()));
    }
  }

  Future<void> _onRefreshPrediction(
    RefreshPredictionEvent event,
    Emitter<PredictionState> emit,
  ) async {
    if (state is PredictionLoaded) {
      final currentPrediction = (state as PredictionLoaded).prediction;
      
      emit(const PredictionLoading());

      try {
        final prediction = await predictSpendingUseCase(
          userId: currentPrediction.userId,
          targetStartDate: currentPrediction.targetStartDate,
          targetEndDate: currentPrediction.targetEndDate,
          budget: currentPrediction.budget,
          useCache: false,
        );

        emit(PredictionLoaded(prediction: prediction));
      } catch (e) {
        emit(PredictionError(e.toString()));
      }
    }
  }
}
