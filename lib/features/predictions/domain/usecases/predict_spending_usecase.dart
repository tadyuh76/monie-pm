// lib/features/predictions/domain/usecases/predict_spending_usecase.dart

import 'package:injectable/injectable.dart';
import 'package:monie/features/predictions/domain/entities/spending_prediction.dart';
import 'package:monie/features/predictions/domain/repositories/prediction_repository.dart';

@injectable
class PredictSpendingUseCase {
  final PredictionRepository repository;

  PredictSpendingUseCase(this.repository);

  Future<SpendingPrediction> call({
    required String userId,
    required DateTime targetStartDate,
    required DateTime targetEndDate,
    required double budget,
    int monthsOfHistory = 6,
    bool useCache = true,
  }) async {
    // Check cache first
    if (useCache) {
      final cachedPrediction = await repository.getCachedPrediction(
        userId: userId,
        targetStartDate: targetStartDate,
        targetEndDate: targetEndDate,
      );

      // Use cache if less than 24 hours old
      if (cachedPrediction != null &&
          DateTime.now().difference(cachedPrediction.predictionDate).inHours < 24) {
        return cachedPrediction;
      }
    }

    // Generate new prediction
    final prediction = await repository.predictSpending(
      userId: userId,
      targetStartDate: targetStartDate,
      targetEndDate: targetEndDate,
      budget: budget,
      monthsOfHistory: monthsOfHistory,
    );

    // Save to cache
    await repository.savePrediction(prediction);

    return prediction;
  }

  /// Quick helper for next month prediction
  Future<SpendingPrediction> predictNextMonth({
    required String userId,
    required double budget,
    bool useCache = true,
  }) async {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final monthEnd = DateTime(now.year, now.month + 2, 0);

    return call(
      userId: userId,
      targetStartDate: nextMonth,
      targetEndDate: monthEnd,
      budget: budget,
      monthsOfHistory: 6,
      useCache: useCache,
    );
  }

  /// Predict next week
  Future<SpendingPrediction> predictNextWeek({
    required String userId,
    required double budget,
    bool useCache = true,
  }) async {
    final now = DateTime.now();
    final nextMonday = now.add(Duration(days: 8 - now.weekday));
    final sunday = nextMonday.add(const Duration(days: 6));

    return call(
      userId: userId,
      targetStartDate: nextMonday,
      targetEndDate: sunday,
      budget: budget,
      monthsOfHistory: 3, // Shorter history for short-term
      useCache: useCache,
    );
  }

  /// Predict next quarter
  Future<SpendingPrediction> predictNextQuarter({
    required String userId,
    required double budget,
    bool useCache = true,
  }) async {
    final now = DateTime.now();
    final currentQuarter = ((now.month - 1) / 3).floor();
    final nextQuarterStart = DateTime(now.year, (currentQuarter + 1) * 3 + 1, 1);
    final quarterEnd = DateTime(now.year, (currentQuarter + 2) * 3 + 1, 0);

    return call(
      userId: userId,
      targetStartDate: nextQuarterStart,
      targetEndDate: quarterEnd,
      budget: budget,
      monthsOfHistory: 12, // More history for long-term
      useCache: useCache,
    );
  }
}
