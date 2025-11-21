// lib/features/predictions/presentation/bloc/prediction_state.dart

import 'package:equatable/equatable.dart';
import 'package:monie/features/predictions/domain/entities/spending_prediction.dart';

abstract class PredictionState extends Equatable {
  const PredictionState();

  @override
  List<Object?> get props => [];
}

class PredictionInitial extends PredictionState {
  const PredictionInitial();
}

class PredictionLoading extends PredictionState {
  const PredictionLoading();
}

class PredictionLoaded extends PredictionState {
  final SpendingPrediction prediction;

  const PredictionLoaded({required this.prediction});

  @override
  List<Object?> get props => [prediction];
}

class PredictionError extends PredictionState {
  final String message;

  const PredictionError(this.message);

  @override
  List<Object?> get props => [message];
}
