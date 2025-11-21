import 'package:monie/features/ai_insights/domain/entities/spending_pattern.dart';

/// Repository interface for spending pattern analysis
abstract class SpendingPatternRepository {
  /// Analyze spending patterns for a user within a date range
  /// Uses both local analysis and AI insights from Gemini
  Future<SpendingPattern> analyzeSpendingPattern({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get cached spending pattern analysis
  Future<SpendingPattern?> getCachedPattern({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Save analyzed pattern to cache/database
  Future<void> savePattern(SpendingPattern pattern);
}
