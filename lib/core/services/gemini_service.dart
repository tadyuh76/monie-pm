import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';

/// Service for interacting with Google Gemini API
@singleton
class GeminiService {
  late final GenerativeModel _model;
  late final String _apiKey;

  GeminiService() {
    _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    
    if (_apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }

    // Initialize Gemini Flash 2.5 model
    _model = GenerativeModel(
      model: 'gemini-2.5-flash', // Gemini Flash 2.5
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8192,
      ),
      safetySettings: [
        SafetySetting(
          HarmCategory.harassment,
          HarmBlockThreshold.medium,
        ),
        SafetySetting(
          HarmCategory.hateSpeech,
          HarmBlockThreshold.medium,
        ),
      ],
    );
  }

  /// Generate content from text prompt
  Future<String> generateContent(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini API');
      }

      return response.text!;
    } catch (e) {
      throw Exception('Failed to generate content: $e');
    }
  }

  /// Generate structured JSON response
  /// Returns parsed Map from JSON response
  Future<Map<String, dynamic>> generateStructuredContent({
    required String prompt,
    required String expectedFormat,
  }) async {
    try {
      final enhancedPrompt = '''
$prompt

IMPORTANT: Respond ONLY with valid JSON in this exact format:
$expectedFormat

Do not include any explanation, markdown formatting, or code blocks. 
Just the raw JSON object.
''';

      final response = await generateContent(enhancedPrompt);
      
      // Clean response (remove markdown code blocks if present)
      String cleanedResponse = response.trim();
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse
            .replaceFirst('```json', '')
            .replaceFirst('```', '')
            .trim();
      } else if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse
            .replaceFirst('```', '')
            .replaceFirst('```', '')
            .trim();
      }

      // Parse JSON
      final jsonResponse = jsonDecode(cleanedResponse) as Map<String, dynamic>;
      return jsonResponse;
    } catch (e) {
      throw Exception('Failed to generate structured content: $e');
    }
  }

  /// Analyze spending patterns with AI
  Future<Map<String, dynamic>> analyzeSpendingPatterns({
    required Map<String, dynamic> spendingData,
  }) async {
    final prompt = _buildSpendingAnalysisPrompt(spendingData);
    
    final expectedFormat = '''
{
  "summary": "2-3 sentence overview of spending patterns",
  "topCategory": "category with highest spending",
  "spendingTrend": "increasing|decreasing|stable",
  "unusualPatterns": ["pattern 1", "pattern 2"],
  "recommendations": ["recommendation 1", "recommendation 2", "recommendation 3"],
  "financialHealthScore": 75,
  "insights": {
    "bestPerformingArea": "area where user is doing well",
    "areasForImprovement": ["area 1", "area 2"],
    "seasonalObservations": "seasonal spending notes"
  }
}
''';

    return await generateStructuredContent(
      prompt: prompt,
      expectedFormat: expectedFormat,
    );
  }

  /// Build prompt for spending analysis
  String _buildSpendingAnalysisPrompt(Map<String, dynamic> data) {
    return '''
You are a financial analyst AI. Analyze the following spending data and provide insights:

**Analysis Period:**
- Start Date: ${data['startDate']}
- End Date: ${data['endDate']}
- Total Days: ${data['totalDays']}

**Spending Summary:**
- Total Spending: \$${data['totalSpending']}
- Average Daily Spending: \$${data['avgDailySpending']}
- Number of Transactions: ${data['transactionCount']}

**Category Breakdown:**
${_formatCategoryBreakdown(data['categoryBreakdown'] as Map<String, dynamic>)}

**Temporal Patterns:**
- Peak Spending Day: ${data['peakDay']}
- Most Active Hour: ${data['peakHour']}h

**Recurring Expenses:**
${_formatRecurringExpenses(data['recurringExpenses'] as List)}

**Previous Period Comparison:**
${data['previousPeriodComparison'] != null ? '- Previous Period Spending: \$${data['previousPeriodComparison']['totalSpending']}\n- Change: ${data['previousPeriodComparison']['percentChange']}%' : 'No previous data available'}

Provide a comprehensive analysis focusing on:
1. Overall financial health assessment
2. Spending patterns and trends
3. Areas of concern or unusual activity
4. Actionable recommendations for improvement
5. Positive behaviors to maintain
''';
  }

  String _formatCategoryBreakdown(Map<String, dynamic> breakdown) {
    final buffer = StringBuffer();
    final entries = breakdown.entries.toList()
      ..sort((a, b) => (b.value as double).compareTo(a.value as double));

    for (var i = 0; i < entries.length && i < 10; i++) {
      final entry = entries[i];
      final percentage = ((entry.value as double) / 
          breakdown.values.fold(0.0, (sum, val) => sum + (val as double))) * 100;
      buffer.writeln('- ${entry.key}: \$${entry.value} (${percentage.toStringAsFixed(1)}%)');
    }

    return buffer.toString();
  }

  String _formatRecurringExpenses(List expenses) {
    if (expenses.isEmpty) return '- None detected';

    final buffer = StringBuffer();
    for (var expense in expenses) {
      buffer.writeln('- ${expense['merchantName']}: \$${expense['amount']} (${expense['frequency']})');
    }
    return buffer.toString();
  }
  /// Predict spending patterns (for Predictions feature)
  Future<Map<String, dynamic>> predictSpending({
    required Map<String, dynamic> historicalData,
    required DateTime targetStartDate,
    required DateTime targetEndDate,
    required double budget,
  }) async {
    final monthlyTotals = historicalData['monthlyTotals'] as List<double>? ?? [];
    final categoryAverages = historicalData['categoryAverages'] as Map<String, dynamic>? ?? {};
    final growthRate = historicalData['growthRate'] as double? ?? 0.0;
    final average = historicalData['average'] as double? ?? 0.0;
    final seasonalFactor = historicalData['seasonalFactor'] as double? ?? 1.0;

    final prompt = '''
  You are a financial forecasting AI. Predict spending for the upcoming period.

  **Historical Data:**
  - Monthly totals (last ${monthlyTotals.length} months): ${monthlyTotals.map((v) => '\$${v.toStringAsFixed(0)}').join(', ')}
  - Average monthly: \$${average.toStringAsFixed(2)}
  - Growth rate: ${(growthRate * 100).toStringAsFixed(1)}%
  - Seasonal factor: ${seasonalFactor.toStringAsFixed(2)}x

  **Target Period:**
  - Start: ${targetStartDate.toString().split(' ')[0]}
  - End: ${targetEndDate.toString().split(' ')[0]}
  - Budget: \$${budget.toStringAsFixed(2)}

  **Category Averages:**
  ${categoryAverages.entries.map((e) => '- ${e.key}: \$${(e.value as num).toStringAsFixed(2)}').join('\n')}

  Task: Predict total spending and category breakdown.
  ''';

    final expectedFormat = '''
  {
    "predictedTotal": ${(average * (1 + growthRate) * seasonalFactor).toStringAsFixed(0)},
    "confidence": 0.75,
    "categoryPredictions": {
      "Food": 500,
      "Transport": 200,
      "Shopping": 150,
      "Entertainment": 100,
      "Bills": 150,
      "Healthcare": 50,
      "Others": 50
    },
    "reasoning": "Based on historical data and trends",
    "trend": "stable",
    "warnings": [],
    "recommendations": ["Monitor spending", "Set alerts", "Review categories"]
  }
  ''';

    try {
      // Use generateStructuredContent() which handles JSON properly
      return await generateStructuredContent(
        prompt: prompt,
        expectedFormat: expectedFormat,
      );
    } catch (e) {
      print('⚠️ Gemini prediction failed: $e');
      // Return fallback
      return _getMockPrediction(historicalData, budget);
    }
  }

  /// Mock prediction for fallback
  Map<String, dynamic> _getMockPrediction(
    Map<String, dynamic> historicalData,
    double budget,
  ) {
    final average = historicalData['average'] as double? ?? budget * 0.8;
    final growthRate = historicalData['growthRate'] as double? ?? 0.0;
    final seasonalFactor = historicalData['seasonalFactor'] as double? ?? 1.0;
    final categoryAverages = historicalData['categoryAverages'] as Map<String, dynamic>? ?? {};

    final predicted = average * (1 + growthRate) * seasonalFactor;

    return {
      'predictedTotal': predicted,
      'confidence': 0.65,
      'categoryPredictions': categoryAverages.isNotEmpty 
          ? categoryAverages.map((k, v) => MapEntry(k, (v as num).toDouble()))
          : {
              'Food': predicted * 0.35,
              'Transport': predicted * 0.20,
              'Shopping': predicted * 0.15,
              'Entertainment': predicted * 0.10,
              'Bills': predicted * 0.15,
              'Healthcare': predicted * 0.02,
              'Others': predicted * 0.03,
            },
      'reasoning': 'Forecast based on ${historicalData['dataPoints'] ?? 0} months of data. AI service using fallback calculation.',
      'trend': growthRate > 0.05 ? 'increasing' : growthRate < -0.05 ? 'decreasing' : 'stable',
      'warnings': predicted > budget 
          ? ['Predicted spending (\$${predicted.toStringAsFixed(0)}) exceeds budget']
          : [],
      'recommendations': [
        'Monitor daily expenses',
        'Review top spending categories',
        'Set up spending alerts',
      ],
    };
  }
}
