// lib/features/predictions/data/models/category_prediction_model.dart

import 'package:monie/features/predictions/domain/entities/category_prediction.dart';

class CategoryPredictionModel extends CategoryPrediction {
  const CategoryPredictionModel({
    required super.categoryName,
    required super.predictedAmount,
    required super.historicalAverage,
    required super.confidence,
    required super.trend,
    super.warning,
  });

  factory CategoryPredictionModel.fromJson(Map<String, dynamic> json) {
    return CategoryPredictionModel(
      categoryName: json['category_name'],
      predictedAmount: (json['predicted_amount'] as num).toDouble(),
      historicalAverage: (json['historical_average'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      trend: json['trend'],
      warning: json['warning'],
    );
  }

  factory CategoryPredictionModel.fromGeminiResponse({
    required String categoryName,
    required double predictedAmount,
    required double historicalAverage,
  }) {
    // Calculate trend
    final change = predictedAmount - historicalAverage;
    final changePercent = historicalAverage > 0 
        ? (change / historicalAverage) * 100 
        : 0.0;

    String trend;
    if (changePercent > 10) {
      trend = 'increasing';
    } else if (changePercent < -10) {
      trend = 'decreasing';
    } else {
      trend = 'stable';
    }

    // Calculate confidence based on stability
    final confidence = historicalAverage > 0
        ? (1 - (change.abs() / historicalAverage).clamp(0, 1)) * 0.8 + 0.2
        : 0.5;

    // Generate warning if significant increase
    String? warning;
    if (changePercent > 30) {
      warning = 'Predicted ${changePercent.toStringAsFixed(0)}% increase in $categoryName';
    }

    return CategoryPredictionModel(
      categoryName: categoryName,
      predictedAmount: predictedAmount,
      historicalAverage: historicalAverage,
      confidence: confidence,
      trend: trend,
      warning: warning,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_name': categoryName,
      'predicted_amount': predictedAmount,
      'historical_average': historicalAverage,
      'confidence': confidence,
      'trend': trend,
      'warning': warning,
    };
  }
}
