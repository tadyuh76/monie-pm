import 'package:equatable/equatable.dart';

abstract class SpendingPatternEvent extends Equatable {
  const SpendingPatternEvent();

  @override
  List<Object?> get props => [];
}

/// Event to trigger spending pattern analysis
class AnalyzeSpendingPatternEvent extends SpendingPatternEvent {
  final String userId;
  final int monthsBack;
  final bool useCache;

  const AnalyzeSpendingPatternEvent({
    required this.userId,
    this.monthsBack = 3,
    this.useCache = true,
  });

  @override
  List<Object?> get props => [userId, monthsBack, useCache];
}

/// Event to refresh analysis (force no cache)
class RefreshSpendingPatternEvent extends SpendingPatternEvent {
  final String userId;
  final int monthsBack;

  const RefreshSpendingPatternEvent({
    required this.userId,
    this.monthsBack = 3,
  });

  @override
  List<Object?> get props => [userId, monthsBack];
}
