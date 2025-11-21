import 'package:equatable/equatable.dart';

/// Entity representing spending pattern analysis results
class SpendingPattern extends Equatable {
  /// Unique identifier for this analysis
  final String? patternId;
  
  /// User ID this pattern belongs to
  final String userId;
  
  /// Analysis period start date
  final DateTime startDate;
  
  /// Analysis period end date
  final DateTime endDate;
  
  /// Total spending in the period
  final double totalSpending;
  
  /// Category breakdown: Map<categoryName, amount>
  final Map<String, double> categoryBreakdown;
  
  /// Most frequently used category
  final String? topCategory;
  
  /// Average daily spending
  final double avgDailySpending;
  
  /// Peak spending day of week (0=Monday, 6=Sunday)
  final int? peakDayOfWeek;
  
  /// Peak spending hour (0-23)
  final int? peakHour;
  
  /// Recurring expenses detected
  final List<RecurringExpense> recurringExpenses;
  
  /// AI-generated summary text
  final String? aiSummary;
  
  /// Spending trend: 'increasing', 'decreasing', 'stable'
  final String? spendingTrend;
  
  /// Unusual patterns detected
  final List<String> unusualPatterns;
  
  /// Financial health score (0-100)
  final int? financialHealthScore;
  
  /// Timestamp when analysis was performed
  final DateTime analyzedAt;

  const SpendingPattern({
    this.patternId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.totalSpending,
    required this.categoryBreakdown,
    this.topCategory,
    required this.avgDailySpending,
    this.peakDayOfWeek,
    this.peakHour,
    this.recurringExpenses = const [],
    this.aiSummary,
    this.spendingTrend,
    this.unusualPatterns = const [],
    this.financialHealthScore,
    required this.analyzedAt,
  });

  @override
  List<Object?> get props => [
        patternId,
        userId,
        startDate,
        endDate,
        totalSpending,
        categoryBreakdown,
        topCategory,
        avgDailySpending,
        peakDayOfWeek,
        peakHour,
        recurringExpenses,
        aiSummary,
        spendingTrend,
        unusualPatterns,
        financialHealthScore,
        analyzedAt,
      ];

  /// Create a copy with updated fields
  SpendingPattern copyWith({
    String? patternId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    double? totalSpending,
    Map<String, double>? categoryBreakdown,
    String? topCategory,
    double? avgDailySpending,
    int? peakDayOfWeek,
    int? peakHour,
    List<RecurringExpense>? recurringExpenses,
    String? aiSummary,
    String? spendingTrend,
    List<String>? unusualPatterns,
    int? financialHealthScore,
    DateTime? analyzedAt,
  }) {
    return SpendingPattern(
      patternId: patternId ?? this.patternId,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalSpending: totalSpending ?? this.totalSpending,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      topCategory: topCategory ?? this.topCategory,
      avgDailySpending: avgDailySpending ?? this.avgDailySpending,
      peakDayOfWeek: peakDayOfWeek ?? this.peakDayOfWeek,
      peakHour: peakHour ?? this.peakHour,
      recurringExpenses: recurringExpenses ?? this.recurringExpenses,
      aiSummary: aiSummary ?? this.aiSummary,
      spendingTrend: spendingTrend ?? this.spendingTrend,
      unusualPatterns: unusualPatterns ?? this.unusualPatterns,
      financialHealthScore: financialHealthScore ?? this.financialHealthScore,
      analyzedAt: analyzedAt ?? this.analyzedAt,
    );
  }
}

/// Entity for recurring expense detection
class RecurringExpense extends Equatable {
  final String merchantName;
  final double amount;
  final String frequency; // 'daily', 'weekly', 'monthly'
  final DateTime lastOccurrence;
  final int occurrences;

  const RecurringExpense({
    required this.merchantName,
    required this.amount,
    required this.frequency,
    required this.lastOccurrence,
    required this.occurrences,
  });

  @override
  List<Object?> get props => [
        merchantName,
        amount,
        frequency,
        lastOccurrence,
        occurrences,
      ];
}
