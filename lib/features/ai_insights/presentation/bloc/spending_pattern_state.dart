import 'package:equatable/equatable.dart';
import 'package:monie/features/ai_insights/domain/entities/spending_pattern.dart';

abstract class SpendingPatternState extends Equatable {
  const SpendingPatternState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SpendingPatternInitial extends SpendingPatternState {}

/// Loading state
class SpendingPatternLoading extends SpendingPatternState {}

/// Success state with pattern
class SpendingPatternLoaded extends SpendingPatternState {
  final SpendingPattern pattern;
  final bool isFromCache;

  const SpendingPatternLoaded({
    required this.pattern,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [pattern, isFromCache];
}

/// Error state
class SpendingPatternError extends SpendingPatternState {
  final String message;

  const SpendingPatternError(this.message);

  @override
  List<Object?> get props => [message];
}
