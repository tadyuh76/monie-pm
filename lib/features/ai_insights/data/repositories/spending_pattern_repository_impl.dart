import 'package:injectable/injectable.dart';
import 'package:monie/core/services/gemini_service.dart';
import 'package:monie/features/ai_insights/data/datasources/spending_pattern_analyzer.dart';
import 'package:monie/features/ai_insights/data/models/spending_pattern_model.dart';
import 'package:monie/features/ai_insights/domain/entities/spending_pattern.dart';
import 'package:monie/features/ai_insights/domain/repositories/spending_pattern_repository.dart';
import 'package:monie/features/transactions/domain/repositories/transaction_repository.dart';

@Injectable(as: SpendingPatternRepository)
class SpendingPatternRepositoryImpl implements SpendingPatternRepository {
  final TransactionRepository transactionRepository;
  final SpendingPatternAnalyzer analyzer;
  final GeminiService geminiService;

  // In-memory cache (could be replaced with database)
  final Map<String, SpendingPattern> _cache = {};

  SpendingPatternRepositoryImpl({
    required this.transactionRepository,
    required this.analyzer,
    required this.geminiService,
  });

  @override
  Future<SpendingPattern> analyzeSpendingPattern({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Step 1: Fetch transactions from repository
      final transactions = await transactionRepository.getTransactionsByDateRange(
        startDate,
        endDate,
      );

      // Step 2: Perform local analysis
      final analysisData = analyzer.analyzeTransactions(
        transactions: transactions,
        startDate: startDate,
        endDate: endDate,
      );

      // Step 3: Get AI insights from Gemini
      final aiResponse = await geminiService.analyzeSpendingPatterns(
        spendingData: analysisData,
      );

      // Step 4: Build SpendingPattern entity
      final rawData = analysisData['rawData'] as Map<String, dynamic>;
      final recurringExpenses = (analysisData['recurringExpenses'] as List)
          .map((e) => RecurringExpenseModel.fromJson(e))
          .toList();

      final pattern = SpendingPattern(
        patternId: _generatePatternId(userId, startDate, endDate),
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        totalSpending: analysisData['totalSpending'],
        categoryBreakdown: Map<String, double>.from(
          rawData['categoryBreakdownMap'],
        ),
        topCategory: aiResponse['topCategory'],
        avgDailySpending: analysisData['avgDailySpending'],
        peakDayOfWeek: rawData['peakDayOfWeek'],
        peakHour: analysisData['peakHour'],
        recurringExpenses: recurringExpenses,
        aiSummary: aiResponse['summary'],
        spendingTrend: aiResponse['spendingTrend'],
        unusualPatterns: List<String>.from(aiResponse['unusualPatterns'] ?? []),
        financialHealthScore: aiResponse['financialHealthScore'],
        analyzedAt: DateTime.now(),
      );

      return pattern;
    } catch (e) {
      throw Exception('Failed to analyze spending pattern: $e');
    }
  }

  @override
  Future<SpendingPattern?> getCachedPattern({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final key = _generateCacheKey(userId, startDate, endDate);
    return _cache[key];
  }

  @override
  Future<void> savePattern(SpendingPattern pattern) async {
    final key = _generateCacheKey(
      pattern.userId,
      pattern.startDate,
      pattern.endDate,
    );
    _cache[key] = pattern;

    // TODO: Save to Supabase database for persistence
    // This would require creating a spending_patterns table
  }

  String _generatePatternId(String userId, DateTime start, DateTime end) {
    return '${userId}_${start.millisecondsSinceEpoch}_${end.millisecondsSinceEpoch}';
  }

  String _generateCacheKey(String userId, DateTime start, DateTime end) {
    return '${userId}_${start.toIso8601String()}_${end.toIso8601String()}';
  }
}
