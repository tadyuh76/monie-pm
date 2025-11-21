// lib/features/predictions/presentation/bloc/prediction_event.dart

import 'package:equatable/equatable.dart';

abstract class PredictionEvent extends Equatable {
  const PredictionEvent();

  @override
  List<Object?> get props => [];
}

/// Predict spending for next month
class PredictNextMonthEvent extends PredictionEvent {
  final String userId;
  final double budget;
  final bool forceRefresh;

  const PredictNextMonthEvent({
    required this.userId,
    required this.budget,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [userId, budget, forceRefresh];
}

/// Predict spending for next week
class PredictNextWeekEvent extends PredictionEvent {
  final String userId;
  final double budget;

  const PredictNextWeekEvent({
    required this.userId,
    required this.budget,
  });

  @override
  List<Object?> get props => [userId, budget];
}

/// Predict spending for next quarter
class PredictNextQuarterEvent extends PredictionEvent {
  final String userId;
  final double budget;

  const PredictNextQuarterEvent({
    required this.userId,
    required this.budget,
  });

  @override
  List<Object?> get props => [userId, budget];
}

/// Predict spending for custom period
class PredictCustomPeriodEvent extends PredictionEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;

  const PredictCustomPeriodEvent({
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.budget,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate, budget];
}

/// Refresh current prediction
class RefreshPredictionEvent extends PredictionEvent {
  const RefreshPredictionEvent();
}
