// lib/features/predictions/domain/entities/spending_prediction.dart

import 'package:equatable/equatable.dart';
import 'package:monie/features/predictions/domain/entities/category_prediction.dart';

class SpendingPrediction extends Equatable {
  final String predictionId;
  final String userId;
  final DateTime predictionDate;
  final DateTime targetStartDate;
  final DateTime targetEndDate;
  
  // Prediction values
  final double predictedTotal;
  final double confidence; // 0.0 - 1.0
  final double budget; // User's budget for comparison
  
  // Category breakdown
  final List<CategoryPrediction> categoryPredictions;
  
  // AI insights
  final String reasoning;
  final List<String> warnings;
  final List<String> recommendations;
  final String spendingTrend; // 'increasing', 'decreasing', 'stable'
  
  // Historical context
  final double historicalAverage;
  final double variability; // Standard deviation
  final int dataPointsUsed;

  const SpendingPrediction({
    required this.predictionId,
    required this.userId,
    required this.predictionDate,
    required this.targetStartDate,
    required this.targetEndDate,
    required this.predictedTotal,
    required this.confidence,
    required this.budget,
    required this.categoryPredictions,
    required this.reasoning,
    required this.warnings,
    required this.recommendations,
    required this.spendingTrend,
    required this.historicalAverage,
    required this.variability,
    required this.dataPointsUsed,
  });

  bool get isOverBudget => predictedTotal > budget;
  
  double get budgetUtilization => (predictedTotal / budget).clamp(0.0, 2.0);
  
  String get confidenceLevel {
    if (confidence >= 0.8) return 'High';
    if (confidence >= 0.6) return 'Medium';
    return 'Low';
  }

  @override
  List<Object?> get props => [
        predictionId,
        userId,
        predictionDate,
        targetStartDate,
        targetEndDate,
        predictedTotal,
        confidence,
        budget,
        categoryPredictions,
        reasoning,
        warnings,
        recommendations,
        spendingTrend,
        historicalAverage,
        variability,
        dataPointsUsed,
      ];
}
