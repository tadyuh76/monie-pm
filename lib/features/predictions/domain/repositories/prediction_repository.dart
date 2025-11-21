// lib/features/predictions/domain/repositories/prediction_repository.dart

import 'package:monie/features/predictions/domain/entities/spending_prediction.dart';

abstract class PredictionRepository {
  /// Predict spending for next period
  Future<SpendingPrediction> predictSpending({
    required String userId,
    required DateTime targetStartDate,
    required DateTime targetEndDate,
    required double budget,
    required int monthsOfHistory,
  });

  /// Get cached prediction if available
  Future<SpendingPrediction?> getCachedPrediction({
    required String userId,
    required DateTime targetStartDate,
    required DateTime targetEndDate,
  });

  /// Save prediction to cache
  Future<void> savePrediction(SpendingPrediction prediction);

  /// Clear expired predictions from cache
  Future<void> clearExpiredPredictions();
}
