import 'package:injectable/injectable.dart';
import 'package:monie/features/ai_insights/domain/entities/spending_pattern.dart';
import 'package:monie/features/ai_insights/domain/repositories/spending_pattern_repository.dart';

@injectable
class AnalyzeSpendingPatternUseCase {
  final SpendingPatternRepository repository;

  AnalyzeSpendingPatternUseCase(this.repository);

  /// Execute spending pattern analysis
  /// 
  /// [userId]: User to analyze
  /// [monthsBack]: Number of months to look back (default: 3)
  /// [useCache]: Try to use cached results if available
  Future<SpendingPattern> call({
    required String userId,
    int monthsBack = 3,
    bool useCache = true,
  }) async {
    // Calculate date range
    final endDate = DateTime.now();
    final startDate = DateTime(
      endDate.year,
      endDate.month - monthsBack,
      endDate.day,
    );

    // Validation: minimum 1 month of data
    if (monthsBack < 1) {
      throw ArgumentError('monthsBack must be at least 1');
    }

    // Try to get cached result first
    if (useCache) {
      final cachedPattern = await repository.getCachedPattern(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      // Return cached if less than 24 hours old
      if (cachedPattern != null) {
        final hoursSinceAnalysis = DateTime.now()
            .difference(cachedPattern.analyzedAt)
            .inHours;

        if (hoursSinceAnalysis < 24) {
          return cachedPattern;
        }
      }
    }

    // Perform fresh analysis
    final pattern = await repository.analyzeSpendingPattern(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    // Save to cache
    await repository.savePattern(pattern);

    return pattern;
  }
}
