// lib/features/predictions/domain/entities/category_prediction.dart

import 'package:equatable/equatable.dart';

class CategoryPrediction extends Equatable {
  final String categoryName;
  final double predictedAmount;
  final double historicalAverage;
  final double confidence;
  final String trend; // 'increasing', 'decreasing', 'stable'
  final String? warning; // Null if no warning
  
  const CategoryPrediction({
    required this.categoryName,
    required this.predictedAmount,
    required this.historicalAverage,
    required this.confidence,
    required this.trend,
    this.warning,
  });

  double get changePercentage {
    if (historicalAverage == 0) return 0;
    return ((predictedAmount - historicalAverage) / historicalAverage) * 100;
  }

  bool get hasSignificantChange => changePercentage.abs() > 15;

  @override
  List<Object?> get props => [
        categoryName,
        predictedAmount,
        historicalAverage,
        confidence,
        trend,
        warning,
      ];
}
