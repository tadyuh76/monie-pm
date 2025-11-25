// lib/features/predictions/data/repositories/prediction_repository_impl.dart
import 'package:injectable/injectable.dart';
import 'package:monie/core/services/gemini_service.dart';
import 'package:monie/features/predictions/data/datasources/prediction_analyzer.dart';
import 'package:monie/features/predictions/data/models/spending_prediction_model.dart';
import 'package:monie/features/predictions/domain/entities/spending_prediction.dart';
import 'package:monie/features/predictions/domain/repositories/prediction_repository.dart';
import 'package:monie/features/transactions/domain/repositories/transaction_repository.dart';

@Injectable(as: PredictionRepository)
class PredictionRepositoryImpl implements PredictionRepository {
  final TransactionRepository transactionRepository;
  final PredictionAnalyzer analyzer;
  final GeminiService geminiService;

  final Map<String, SpendingPrediction> _cache = {};

  PredictionRepositoryImpl({
    required this.transactionRepository,
    required this.analyzer,
    required this.geminiService,
  });

  @override
  Future<SpendingPrediction> predictSpending({
    required String userId,
    required DateTime targetStartDate,
    required DateTime targetEndDate,
    required double budget,
    required int monthsOfHistory,
  }) async {
    try {
      print('🔵 Step 1: Fetching historical transactions...');
      
      // Calculate history period
      final historyStartDate = DateTime(
        targetStartDate.year,
        targetStartDate.month - monthsOfHistory,
        targetStartDate.day,
      );
      
      // Fetch historical transactions
      final transactions = await transactionRepository.getTransactionsByDateRange(
        userId,
        historyStartDate,
        DateTime.now(),
      );
      
      print('✅ Found ${transactions.length} historical transactions');

      if (transactions.isEmpty) {
        return _getDefaultPrediction(
          userId: userId,
          targetStartDate: targetStartDate,
          targetEndDate: targetEndDate,
          budget: budget,
        );
      }

      print('🔵 Step 2: Analyzing historical data...');
      
      // Analyze historical patterns
      final historicalData = analyzer.analyzeHistoricalData(
        transactions: transactions,
        targetStartDate: targetStartDate,
        targetEndDate: targetEndDate,
      );
      
      print('✅ Historical analysis complete');
      print('   - Average: \$${historicalData['average'].toStringAsFixed(2)}');
      print('   - Variability: ${historicalData['variability'].toStringAsFixed(2)}');
      print('   - Data points: ${historicalData['dataPoints']}');

      print('🔵 Step 3: Generating AI prediction...');
      
      // Generate AI prediction
      final geminiResponse = await _getPredictionFromGemini(
        historicalData: historicalData,
        targetStartDate: targetStartDate,
        targetEndDate: targetEndDate,
        budget: budget,
      );
      
      print('✅ AI prediction generated');

      // Build prediction entity
      final prediction = SpendingPredictionModel.fromGeminiResponse(
        userId: userId,
        targetStartDate: targetStartDate,
        targetEndDate: targetEndDate,
        budget: budget,
        geminiResponse: geminiResponse,
        historicalData: historicalData,
      );

      print('✅ Prediction complete');
      print('   - Predicted: \$${prediction.predictedTotal.toStringAsFixed(2)}');
      print('   - Confidence: ${(prediction.confidence * 100).toInt()}%');
      print('   - Over budget: ${prediction.isOverBudget}');

      return prediction;
    } catch (e, stackTrace) {
      print('❌ Error in predictSpending: $e');
      print('Stack trace: $stackTrace');
      
      // Return fallback prediction on error
      return _getFallbackPrediction(
        userId: userId,
        targetStartDate: targetStartDate,
        targetEndDate: targetEndDate,
        budget: budget,
        error: e.toString(),
      );
    }
  }

  /// Get prediction from Gemini AI
  Future<Map<String, dynamic>> _getPredictionFromGemini({
    required Map<String, dynamic> historicalData,
    required DateTime targetStartDate,
    required DateTime targetEndDate,
    required double budget,
  }) async {
    try {
      // ⭐ Call predictSpending() method (now exists in gemini_service.dart)
      return await geminiService.predictSpending(
        historicalData: historicalData,
        targetStartDate: targetStartDate,
        targetEndDate: targetEndDate,
        budget: budget,
      );
    } catch (e) {
      print('⚠️ Gemini prediction failed: $e');
      return _getMockPrediction(historicalData, budget);
    }
  }

  /// Mock prediction when Gemini is unavailable
  Map<String, dynamic> _getMockPrediction(
    Map<String, dynamic> historicalData,
    double budget,
  ) {
    final average = historicalData['average'] as double;
    final growthRate = historicalData['growthRate'] as double;
    final seasonalFactor = historicalData['seasonalFactor'] as double;
    final categoryAverages = historicalData['categoryAverages'] as Map<String, double>;

    // Simple prediction: average * (1 + growth) * seasonal
    final predicted = average * (1 + growthRate) * seasonalFactor;
    
    // Calculate confidence based on data quality
    final confidence = historicalData['confidence'] as double;

    return {
      'predictedTotal': predicted,
      'confidence': confidence,
      'categoryPredictions': categoryAverages,
      'reasoning': 'Prediction based on ${historicalData['dataPoints']} months of data. '
          'Average monthly spending: \$${average.toStringAsFixed(2)}. '
          'Growth rate: ${(growthRate * 100).toStringAsFixed(1)}%. '
          'Seasonal adjustment: ${seasonalFactor.toStringAsFixed(2)}x.',
      'trend': growthRate > 0.05 ? 'increasing' : growthRate < -0.05 ? 'decreasing' : 'stable',
      'warnings': predicted > budget
          ? ['Predicted spending exceeds budget by \$${(predicted - budget).toStringAsFixed(2)}']
          : [],
      'recommendations': [
        'Track daily expenses to stay within budget',
        'Review spending in top categories',
        'Set up alerts for large transactions',
      ],
    };
  }

  /// Default prediction for new users with no data
  SpendingPrediction _getDefaultPrediction({
    required String userId,
    required DateTime targetStartDate,
    required DateTime targetEndDate,
    required double budget,
  }) {
    return SpendingPredictionModel(
      predictionId: '${userId}_default',
      userId: userId,
      predictionDate: DateTime.now(),
      targetStartDate: targetStartDate,
      targetEndDate: targetEndDate,
      predictedTotal: budget * 0.8, // Conservative estimate
      confidence: 0.3, // Low confidence
      budget: budget,
      categoryPredictions: [],
      reasoning: 'Insufficient historical data. Prediction based on budget estimate.',
      warnings: ['Not enough transaction history for accurate prediction'],
      recommendations: [
        'Add more transactions to improve predictions',
        'Set a monthly budget to track spending',
        'Review predictions after 3 months of data',
      ],
      spendingTrend: 'stable',
      historicalAverage: 0.0,
      variability: 0.0,
      dataPointsUsed: 0,
    );
  }

  /// Fallback prediction when errors occur
  SpendingPrediction _getFallbackPrediction({
    required String userId,
    required DateTime targetStartDate,
    required DateTime targetEndDate,
    required double budget,
    required String error,
  }) {
    return SpendingPredictionModel(
      predictionId: '${userId}_fallback',
      userId: userId,
      predictionDate: DateTime.now(),
      targetStartDate: targetStartDate,
      targetEndDate: targetEndDate,
      predictedTotal: budget,
      confidence: 0.5,
      budget: budget,
      categoryPredictions: [],
      reasoning: 'Prediction unavailable due to error. Using budget as estimate.',
      warnings: ['Prediction service temporarily unavailable'],
      recommendations: [
        'Try again later',
        'Check your internet connection',
        'Contact support if issue persists',
      ],
      spendingTrend: 'stable',
      historicalAverage: budget,
      variability: 0.0,
      dataPointsUsed: 0,
    );
  }

  @override
  Future<SpendingPrediction?> getCachedPrediction({
    required String userId,
    required DateTime targetStartDate,
    required DateTime targetEndDate,
  }) async {
    final key = _generateCacheKey(userId, targetStartDate, targetEndDate);
    return _cache[key];
  }

  @override
  Future<void> savePrediction(SpendingPrediction prediction) async {
    final key = _generateCacheKey(
      prediction.userId,
      prediction.targetStartDate,
      prediction.targetEndDate,
    );
    _cache[key] = prediction;
  }

  @override
  Future<void> clearExpiredPredictions() async {
    final now = DateTime.now();
    _cache.removeWhere((key, prediction) {
      // Remove if older than 24 hours or target date passed
      return now.difference(prediction.predictionDate).inHours > 24 ||
          now.isAfter(prediction.targetEndDate);
    });
  }

  String _generateCacheKey(String userId, DateTime start, DateTime end) {
    return '${userId}_${start.toIso8601String()}_${end.toIso8601String()}';
  }
}
