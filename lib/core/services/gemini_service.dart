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
        maxOutputTokens: 2048,
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
}
