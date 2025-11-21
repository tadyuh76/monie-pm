import 'package:monie/features/ai_insights/domain/entities/spending_pattern.dart';

class SpendingPatternModel extends SpendingPattern {
  const SpendingPatternModel({
    super.patternId,
    required super.userId,
    required super.startDate,
    required super.endDate,
    required super.totalSpending,
    required super.categoryBreakdown,
    super.topCategory,
    required super.avgDailySpending,
    super.peakDayOfWeek,
    super.peakHour,
    super.recurringExpenses,
    super.aiSummary,
    super.spendingTrend,
    super.unusualPatterns,
    super.financialHealthScore,
    required super.analyzedAt,
  });

  /// Create from JSON (if storing in database)
  factory SpendingPatternModel.fromJson(Map<String, dynamic> json) {
    return SpendingPatternModel(
      patternId: json['pattern_id'],
      userId: json['user_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      totalSpending: (json['total_spending'] as num).toDouble(),
      categoryBreakdown: Map<String, double>.from(
        json['category_breakdown'].map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      topCategory: json['top_category'],
      avgDailySpending: (json['avg_daily_spending'] as num).toDouble(),
      peakDayOfWeek: json['peak_day_of_week'],
      peakHour: json['peak_hour'],
      recurringExpenses: (json['recurring_expenses'] as List?)
              ?.map((e) => RecurringExpenseModel.fromJson(e))
              .toList() ??
          [],
      aiSummary: json['ai_summary'],
      spendingTrend: json['spending_trend'],
      unusualPatterns: List<String>.from(json['unusual_patterns'] ?? []),
      financialHealthScore: json['financial_health_score'],
      analyzedAt: DateTime.parse(json['analyzed_at']),
    );
  }

  /// Convert to JSON (for storing in database)
  Map<String, dynamic> toJson() {
    return {
      'pattern_id': patternId,
      'user_id': userId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_spending': totalSpending,
      'category_breakdown': categoryBreakdown,
      'top_category': topCategory,
      'avg_daily_spending': avgDailySpending,
      'peak_day_of_week': peakDayOfWeek,
      'peak_hour': peakHour,
      'recurring_expenses': recurringExpenses
          .map((e) => RecurringExpenseModel.fromEntity(e).toJson())
          .toList(),
      'ai_summary': aiSummary,
      'spending_trend': spendingTrend,
      'unusual_patterns': unusualPatterns,
      'financial_health_score': financialHealthScore,
      'analyzed_at': analyzedAt.toIso8601String(),
    };
  }

  /// Create from Entity
  factory SpendingPatternModel.fromEntity(SpendingPattern entity) {
    return SpendingPatternModel(
      patternId: entity.patternId,
      userId: entity.userId,
      startDate: entity.startDate,
      endDate: entity.endDate,
      totalSpending: entity.totalSpending,
      categoryBreakdown: entity.categoryBreakdown,
      topCategory: entity.topCategory,
      avgDailySpending: entity.avgDailySpending,
      peakDayOfWeek: entity.peakDayOfWeek,
      peakHour: entity.peakHour,
      recurringExpenses: entity.recurringExpenses,
      aiSummary: entity.aiSummary,
      spendingTrend: entity.spendingTrend,
      unusualPatterns: entity.unusualPatterns,
      financialHealthScore: entity.financialHealthScore,
      analyzedAt: entity.analyzedAt,
    );
  }
}

class RecurringExpenseModel extends RecurringExpense {
  const RecurringExpenseModel({
    required super.merchantName,
    required super.amount,
    required super.frequency,
    required super.lastOccurrence,
    required super.occurrences,
  });

  factory RecurringExpenseModel.fromJson(Map<String, dynamic> json) {
    return RecurringExpenseModel(
      merchantName: json['merchant_name'],
      amount: (json['amount'] as num).toDouble(),
      frequency: json['frequency'],
      lastOccurrence: DateTime.parse(json['last_occurrence']),
      occurrences: json['occurrences'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchant_name': merchantName,
      'amount': amount,
      'frequency': frequency,
      'last_occurrence': lastOccurrence.toIso8601String(),
      'occurrences': occurrences,
    };
  }

  factory RecurringExpenseModel.fromEntity(RecurringExpense entity) {
    return RecurringExpenseModel(
      merchantName: entity.merchantName,
      amount: entity.amount,
      frequency: entity.frequency,
      lastOccurrence: entity.lastOccurrence,
      occurrences: entity.occurrences,
    );
  }
}
