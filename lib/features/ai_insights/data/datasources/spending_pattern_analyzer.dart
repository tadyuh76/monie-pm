import 'package:injectable/injectable.dart';
import 'package:monie/features/transactions/domain/entities/transaction.dart';

/// Local analyzer for spending patterns
/// Performs statistical analysis before sending to AI
@injectable
class SpendingPatternAnalyzer {
  /// Analyze transactions to extract patterns
  Map<String, dynamic> analyzeTransactions({
    required List<Transaction> transactions,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    // Filter out income transactions (keep only expenses)
    final expenses = transactions.where((t) => t.amount < 0).toList();

    if (expenses.isEmpty) {
      return _emptyAnalysis(startDate, endDate);
    }

    // Calculate basic metrics
    final totalSpending = expenses.fold(0.0, (sum, t) => sum + t.amount.abs());
    final totalDays = endDate.difference(startDate).inDays + 1;
    final avgDailySpending = totalSpending / totalDays;

    // Category breakdown
    final categoryBreakdown = _calculateCategoryBreakdown(expenses);

    // Find top category
    final topCategory = categoryBreakdown.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Temporal analysis
    final peakDayOfWeek = _findPeakDayOfWeek(expenses);
    final peakHour = _findPeakHour(expenses);

    // Detect recurring expenses
    final recurringExpenses = _detectRecurringExpenses(expenses);

    // Compare with previous period (if we have data)
    final previousPeriodComparison = _comparePreviousPeriod(
      currentExpenses: expenses,
      startDate: startDate,
      endDate: endDate,
    );

    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalDays': totalDays,
      'totalSpending': totalSpending,
      'avgDailySpending': avgDailySpending,
      'transactionCount': expenses.length,
      'categoryBreakdown': categoryBreakdown,
      'topCategory': topCategory,
      'peakDay': _dayOfWeekName(peakDayOfWeek),
      'peakHour': peakHour,
      'recurringExpenses': recurringExpenses,
      'previousPeriodComparison': previousPeriodComparison,
      'rawData': {
        'peakDayOfWeek': peakDayOfWeek,
        'categoryBreakdownMap': categoryBreakdown,
      },
    };
  }

  Map<String, double> _calculateCategoryBreakdown(
    List<Transaction> transactions,
  ) {
    final breakdown = <String, double>{};

    for (var transaction in transactions) {
      final category = transaction.categoryName ?? 'Uncategorized';
      breakdown[category] = (breakdown[category] ?? 0) + transaction.amount.abs();
    }

    return breakdown;
  }

  int _findPeakDayOfWeek(List<Transaction> transactions) {
    final dayTotals = <int, double>{};

    for (var transaction in transactions) {
      final dayOfWeek = transaction.date.weekday - 1; // 0=Monday, 6=Sunday
      dayTotals[dayOfWeek] = (dayTotals[dayOfWeek] ?? 0) + transaction.amount.abs();
    }

    if (dayTotals.isEmpty) return 0;

    return dayTotals.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  int _findPeakHour(List<Transaction> transactions) {
    final hourTotals = <int, double>{};

    for (var transaction in transactions) {
      final hour = transaction.date.hour;
      hourTotals[hour] = (hourTotals[hour] ?? 0) + transaction.amount.abs();
    }

    if (hourTotals.isEmpty) return 12; // Default to noon

    return hourTotals.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  List<Map<String, dynamic>> _detectRecurringExpenses(
    List<Transaction> transactions,
  ) {
    // Group by title/description (merchant name)
    final groupedByMerchant = <String, List<Transaction>>{};

    for (var transaction in transactions) {
      final merchant = transaction.title;
      groupedByMerchant.putIfAbsent(merchant, () => []).add(transaction);
    }

    final recurring = <Map<String, dynamic>>[];

    // Check for recurring patterns (3+ occurrences)
    groupedByMerchant.forEach((merchant, txns) {
      if (txns.length >= 3) {
        // Calculate average amount
        final avgAmount = txns.fold(0.0, (sum, t) => sum + t.amount.abs()) / txns.length;

        // Determine frequency
        final dates = txns.map((t) => t.date).toList()..sort();
        final avgDaysBetween = _calculateAverageDaysBetween(dates);
        
        String frequency;
        if (avgDaysBetween <= 2) {
          frequency = 'daily';
        } else if (avgDaysBetween <= 9) {
          frequency = 'weekly';
        } else if (avgDaysBetween <= 35) {
          frequency = 'monthly';
        } else {
          return; // Not recurring enough
        }

        recurring.add({
          'merchantName': merchant,
          'amount': avgAmount,
          'frequency': frequency,
          'lastOccurrence': dates.last.toIso8601String(),
          'occurrences': txns.length,
        });
      }
    });

    return recurring;
  }

  double _calculateAverageDaysBetween(List<DateTime> sortedDates) {
    if (sortedDates.length < 2) return 0;

    final differences = <int>[];
    for (var i = 1; i < sortedDates.length; i++) {
      differences.add(sortedDates[i].difference(sortedDates[i - 1]).inDays);
    }

    return differences.reduce((a, b) => a + b) / differences.length;
  }

  Map<String, dynamic>? _comparePreviousPeriod({
    required List<Transaction> currentExpenses,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    // This would need access to previous period transactions
    // For now, return null (can be implemented later)
    return null;
  }

  Map<String, dynamic> _emptyAnalysis(DateTime startDate, DateTime endDate) {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalDays': endDate.difference(startDate).inDays + 1,
      'totalSpending': 0.0,
      'avgDailySpending': 0.0,
      'transactionCount': 0,
      'categoryBreakdown': <String, double>{},
      'topCategory': null,
      'peakDay': 'N/A',
      'peakHour': 12,
      'recurringExpenses': [],
      'previousPeriodComparison': null,
      'rawData': {
        'peakDayOfWeek': 0,
        'categoryBreakdownMap': <String, double>{},
      },
    };
  }

  String _dayOfWeekName(int dayOfWeek) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dayOfWeek];
  }
}
