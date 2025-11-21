// lib/features/predictions/data/datasources/prediction_analyzer.dart

import 'dart:math';
import 'package:injectable/injectable.dart';
import 'package:monie/features/transactions/domain/entities/transaction.dart';

@injectable
class PredictionAnalyzer {
  /// Analyze historical data and prepare for prediction
  Map<String, dynamic> analyzeHistoricalData({
    required List<Transaction> transactions,
    required DateTime targetStartDate,
    required DateTime targetEndDate,
  }) {
    // Filter only expenses
    final expenses = transactions
        .where((t) => t.amount < 0)
        .toList();

    if (expenses.isEmpty) {
      return _getEmptyAnalysis();
    }

    // Group by month
    final monthlyTotals = _groupByMonth(expenses);
    
    // Calculate statistics
    final average = _calculateAverage(monthlyTotals);
    final variability = _calculateStandardDeviation(monthlyTotals, average);
    
    // Category analysis
    final categoryAverages = _calculateCategoryAverages(expenses);
    final categoryCounts = _countCategoryOccurrences(expenses);
    
    // Time-based patterns
    final dayOfWeekPatterns = _analyzeDayOfWeekPatterns(expenses);
    final monthlyGrowthRate = _calculateGrowthRate(monthlyTotals);
    
    // Seasonal factors
    final seasonalFactors = _calculateSeasonalFactors(
      monthlyTotals,
      targetStartDate.month,
    );

    // Upcoming events (bills, holidays)
    final upcomingEvents = _detectUpcomingEvents(
      expenses,
      targetStartDate,
      targetEndDate,
    );

    return {
      'average': average,
      'variability': variability,
      'dataPoints': monthlyTotals.length,
      'categoryAverages': categoryAverages,
      'categoryCounts': categoryCounts,
      'dayOfWeekPatterns': dayOfWeekPatterns,
      'growthRate': monthlyGrowthRate,
      'seasonalFactor': seasonalFactors,
      'upcomingEvents': upcomingEvents,
      'monthlyTotals': monthlyTotals,
      'lastMonthTotal': monthlyTotals.isNotEmpty ? monthlyTotals.last : 0.0,
      'confidence': _calculateDataConfidence(
        dataPoints: monthlyTotals.length,
        variability: variability,
        average: average,
      ),
    };
  }

  /// Group transactions by month
  List<double> _groupByMonth(List<Transaction> expenses) {
    final monthlyMap = <String, double>{};

    for (var expense in expenses) {
      final monthKey = '${expense.date.year}-${expense.date.month}';
      monthlyMap[monthKey] = (monthlyMap[monthKey] ?? 0) + expense.amount.abs();
    }

    return monthlyMap.values.toList()..sort();
  }

  /// Calculate average spending
  double _calculateAverage(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Calculate standard deviation
  double _calculateStandardDeviation(List<double> values, double mean) {
    if (values.length < 2) return 0.0;

    final variance = values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / values.length;
    return sqrt(variance);
  }

  /// Calculate average spending per category
  Map<String, double> _calculateCategoryAverages(List<Transaction> expenses) {
    final categoryTotals = <String, double>{};
    final categoryCounts = <String, int>{};

    for (var expense in expenses) {
      final category = expense.categoryName ?? 'Uncategorized';
      categoryTotals[category] = (categoryTotals[category] ?? 0) + expense.amount.abs();
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    // Get unique months
    final months = expenses.map((e) => '${e.date.year}-${e.date.month}').toSet().length;
    final divisor = months > 0 ? months : 1;

    return categoryTotals.map((key, value) => MapEntry(key, value / divisor));
  }

  /// Count category occurrences
  Map<String, int> _countCategoryOccurrences(List<Transaction> expenses) {
    final counts = <String, int>{};
    for (var expense in expenses) {
      final category = expense.categoryName ?? 'Uncategorized';
      counts[category] = (counts[category] ?? 0) + 1;
    }
    return counts;
  }

  /// Analyze day of week spending patterns
  Map<int, double> _analyzeDayOfWeekPatterns(List<Transaction> expenses) {
    final dayTotals = <int, double>{};
    final dayCounts = <int, int>{};

    for (var expense in expenses) {
      final day = expense.date.weekday;
      dayTotals[day] = (dayTotals[day] ?? 0) + expense.amount.abs();
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }

    // Calculate average per day
    return dayTotals.map((key, value) {
      final count = dayCounts[key] ?? 1;
      return MapEntry(key, value / count);
    });
  }

  /// Calculate monthly growth rate
  double _calculateGrowthRate(List<double> monthlyTotals) {
    if (monthlyTotals.length < 2) return 0.0;

    final recent3Months = monthlyTotals.length >= 3
        ? monthlyTotals.sublist(monthlyTotals.length - 3)
        : monthlyTotals;

    if (recent3Months.length < 2) return 0.0;

    final firstHalf = recent3Months.sublist(0, recent3Months.length ~/ 2);
    final secondHalf = recent3Months.sublist(recent3Months.length ~/ 2);

    final firstAvg = _calculateAverage(firstHalf);
    final secondAvg = _calculateAverage(secondHalf);

    if (firstAvg == 0) return 0.0;

    return (secondAvg - firstAvg) / firstAvg;
  }

  /// Calculate seasonal adjustment factor
  double _calculateSeasonalFactors(List<double> monthlyTotals, int targetMonth) {
    // Simple seasonal factors (can be refined with more data)
    const seasonalFactors = {
      1: 1.1,  // January - New year, resolutions
      2: 0.95, // February - Short month
      3: 1.0,  // March
      4: 1.0,  // April
      5: 1.05, // May
      6: 1.1,  // June - Summer vacation
      7: 1.15, // July - Peak vacation
      8: 1.1,  // August
      9: 1.0,  // September
      10: 1.05, // October
      11: 1.1,  // November - Thanksgiving
      12: 1.25, // December - Holidays
    };

    return seasonalFactors[targetMonth] ?? 1.0;
  }

  /// Detect upcoming recurring events
  List<Map<String, dynamic>> _detectUpcomingEvents(
    List<Transaction> expenses,
    DateTime targetStart,
    DateTime targetEnd,
  ) {
    final events = <Map<String, dynamic>>[];

    // Detect monthly recurring bills
    final recurring = <String, List<Transaction>>{};
    for (var expense in expenses) {
      if (expense.isRecurring) {
        final key = expense.title;
        recurring[key] = (recurring[key] ?? [])..add(expense);
      }
    }

    // Add recurring bills that should occur in target period
    for (var entry in recurring.entries) {
      if (entry.value.length >= 2) {
        final avgAmount = _calculateAverage(
          entry.value.map((t) => t.amount.abs()).toList(),
        );

        events.add({
          'name': entry.key,
          'amount': avgAmount,
          'type': 'recurring',
          'confidence': 0.9,
        });
      }
    }

    return events;
  }

  /// Calculate confidence based on data quality
  double _calculateDataConfidence({
    required int dataPoints,
    required double variability,
    required double average,
  }) {
    // More data points = higher confidence
    final dataFactor = min(dataPoints / 6, 1.0); // Max at 6 months

    // Lower variability = higher confidence
    final stabilityFactor = average > 0
        ? 1 - min(variability / average, 1.0)
        : 0.5;

    return (dataFactor * 0.6 + stabilityFactor * 0.4).clamp(0.0, 1.0);
  }

  Map<String, dynamic> _getEmptyAnalysis() {
    return {
      'average': 0.0,
      'variability': 0.0,
      'dataPoints': 0,
      'categoryAverages': <String, double>{},
      'categoryCounts': <String, int>{},
      'dayOfWeekPatterns': <int, double>{},
      'growthRate': 0.0,
      'seasonalFactor': 1.0,
      'upcomingEvents': [],
      'monthlyTotals': [],
      'lastMonthTotal': 0.0,
      'confidence': 0.0,
    };
  }
}
