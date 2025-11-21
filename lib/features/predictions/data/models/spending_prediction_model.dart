// lib/features/predictions/data/models/spending_prediction_model.dart

import 'package:monie/features/predictions/data/models/category_prediction_model.dart';
import 'package:monie/features/predictions/domain/entities/spending_prediction.dart';

class SpendingPredictionModel extends SpendingPrediction {
  const SpendingPredictionModel({
    required super.predictionId,
    required super.userId,
    required super.predictionDate,
    required super.targetStartDate,
    required super.targetEndDate,
    required super.predictedTotal,
    required super.confidence,
    required super.budget,
    required super.categoryPredictions,
    required super.reasoning,
    required super.warnings,
    required super.recommendations,
    required super.spendingTrend,
    required super.historicalAverage,
    required super.variability,
    required super.dataPointsUsed,
  });

  /// Create from JSON (database/cache)
  factory SpendingPredictionModel.fromJson(Map<String, dynamic> json) {
    return SpendingPredictionModel(
      predictionId: json['prediction_id'],
      userId: json['user_id'],
      predictionDate: DateTime.parse(json['prediction_date']),
      targetStartDate: DateTime.parse(json['target_start_date']),
      targetEndDate: DateTime.parse(json['target_end_date']),
      predictedTotal: (json['predicted_total'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      budget: (json['budget'] as num).toDouble(),
      categoryPredictions: (json['category_predictions'] as List)
          .map((e) => CategoryPredictionModel.fromJson(e))
          .toList(),
      reasoning: json['reasoning'],
      warnings: List<String>.from(json['warnings'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      spendingTrend: json['spending_trend'],
      historicalAverage: (json['historical_average'] as num).toDouble(),
      variability: (json['variability'] as num).toDouble(),
      dataPointsUsed: json['data_points_used'],
    );
  }

  /// Create from Gemini AI response
  factory SpendingPredictionModel.fromGeminiResponse({
    required String userId,
    required DateTime targetStartDate,
    required DateTime targetEndDate,
    required double budget,
    required Map<String, dynamic> geminiResponse,
    required Map<String, dynamic> historicalData,
  }) {
    return SpendingPredictionModel(
      predictionId: _generatePredictionId(userId, targetStartDate),
      userId: userId,
      predictionDate: DateTime.now(),
      targetStartDate: targetStartDate,
      targetEndDate: targetEndDate,
      predictedTotal: (geminiResponse['predictedTotal'] as num).toDouble(),
      confidence: (geminiResponse['confidence'] as num).toDouble(),
      budget: budget,
      categoryPredictions: (geminiResponse['categoryPredictions'] as Map)
          .entries
          .map((e) => CategoryPredictionModel.fromGeminiResponse(
                categoryName: e.key,
                predictedAmount: (e.value as num).toDouble(),
                historicalAverage: historicalData['categoryAverages'][e.key] ?? 0.0,
              ))
          .toList(),
      reasoning: geminiResponse['reasoning'] ?? '',
      warnings: List<String>.from(geminiResponse['warnings'] ?? []),
      recommendations: List<String>.from(geminiResponse['recommendations'] ?? []),
      spendingTrend: geminiResponse['trend'] ?? 'stable',
      historicalAverage: (historicalData['average'] as num).toDouble(),
      variability: (historicalData['variability'] as num).toDouble(),
      dataPointsUsed: historicalData['dataPoints'] as int,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'prediction_id': predictionId,
      'user_id': userId,
      'prediction_date': predictionDate.toIso8601String(),
      'target_start_date': targetStartDate.toIso8601String(),
      'target_end_date': targetEndDate.toIso8601String(),
      'predicted_total': predictedTotal,
      'confidence': confidence,
      'budget': budget,
      'category_predictions': categoryPredictions
          .map((e) => (e as CategoryPredictionModel).toJson())
          .toList(),
      'reasoning': reasoning,
      'warnings': warnings,
      'recommendations': recommendations,
      'spending_trend': spendingTrend,
      'historical_average': historicalAverage,
      'variability': variability,
      'data_points_used': dataPointsUsed,
    };
  }

  static String _generatePredictionId(String userId, DateTime targetDate) {
    return '${userId}_${targetDate.millisecondsSinceEpoch}';
  }
}
