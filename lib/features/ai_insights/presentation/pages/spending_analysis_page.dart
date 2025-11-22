import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monie/core/utils/formatters.dart';
import 'package:monie/di/injection.dart';
import 'package:monie/features/ai_insights/presentation/bloc/spending_pattern_bloc.dart';
import 'package:monie/features/ai_insights/presentation/bloc/spending_pattern_event.dart';
import 'package:monie/features/ai_insights/presentation/bloc/spending_pattern_state.dart';
import 'package:monie/features/ai_insights/presentation/widgets/ai_insight_card.dart';
import 'package:monie/features/ai_insights/presentation/widgets/category_breakdown_chart.dart';
import 'package:monie/features/ai_insights/presentation/widgets/financial_health_gauge.dart';
import 'package:monie/features/ai_insights/presentation/widgets/pattern_summary_card.dart';
import 'package:monie/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:monie/features/authentication/presentation/bloc/auth_state.dart';

class SpendingAnalysisPage extends StatelessWidget {
  const SpendingAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SpendingPatternBloc>(),
      child: const _SpendingAnalysisView(),
    );
  }
}

class _SpendingAnalysisView extends StatefulWidget {
  const _SpendingAnalysisView();

  @override
  State<_SpendingAnalysisView> createState() => _SpendingAnalysisViewState();
}

class _SpendingAnalysisViewState extends State<_SpendingAnalysisView> {
  int _selectedMonths = 3;

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  void _loadAnalysis() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<SpendingPatternBloc>().add(
            AnalyzeSpendingPatternEvent(
              userId: authState.user.id,
              monthsBack: _selectedMonths,
            ),
          );
    }
  }

  void _refreshAnalysis() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<SpendingPatternBloc>().add(
            RefreshSpendingPatternEvent(
              userId: authState.user.id,
              monthsBack: _selectedMonths,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAnalysis,
            tooltip: 'Refresh Analysis',
          ),
        ],
      ),
      body: BlocBuilder<SpendingPatternBloc, SpendingPatternState>(
        builder: (context, state) {
          if (state is SpendingPatternLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing your spending patterns...'),
                  SizedBox(height: 8),
                  Text(
                    'This may take a few moments',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          if (state is SpendingPatternError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadAnalysis,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (state is SpendingPatternLoaded) {
            final pattern = state.pattern;

            return RefreshIndicator(
              onRefresh: () async => _refreshAnalysis(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period Selector
                    _buildPeriodSelector(),
                    const SizedBox(height: 16),

                    // Cache indicator
                    if (state.isFromCache)
                      Builder(
                        builder: (context) {
                          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                          return Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.blue.withOpacity(0.2)
                                  : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.cached,
                                  size: 16,
                                  color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Showing cached analysis',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 16),

                    // Financial Health Score
                    if (pattern.financialHealthScore != null)
                      FinancialHealthGauge(score: pattern.financialHealthScore!),
                    const SizedBox(height: 24),

                    // AI Summary Card
                    if (pattern.aiSummary != null)
                      AIInsightCard(
                        title: 'AI Analysis Summary',
                        content: pattern.aiSummary!,
                        icon: Icons.psychology,
                      ),
                    const SizedBox(height: 16),

                    // Pattern Summary
                    PatternSummaryCard(pattern: pattern),
                    const SizedBox(height: 16),

                    // Category Breakdown Chart
                    CategoryBreakdownChart(
                      categoryBreakdown: pattern.categoryBreakdown,
                    ),
                    const SizedBox(height: 16),

                    // Spending Trend
                    if (pattern.spendingTrend != null)
                      _buildTrendCard(pattern.spendingTrend!),
                    const SizedBox(height: 16),

                    // Unusual Patterns
                    if (pattern.unusualPatterns.isNotEmpty)
                      _buildUnusualPatternsCard(pattern.unusualPatterns),
                    const SizedBox(height: 16),

                    // Recurring Expenses
                    if (pattern.recurringExpenses.isNotEmpty)
                      _buildRecurringExpensesCard(pattern.recurringExpenses),
                  ],
                ),
              ),
            );
          }

          return const Center(
            child: Text('No data available'),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analysis Period',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1 Month')),
                ButtonSegment(value: 3, label: Text('3 Months')),
                ButtonSegment(value: 6, label: Text('6 Months')),
              ],
              selected: {_selectedMonths},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() {
                  _selectedMonths = newSelection.first;
                });
                _loadAnalysis();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendCard(String trend) {
    IconData icon;
    Color color;
    String message;

    switch (trend.toLowerCase()) {
      case 'increasing':
        icon = Icons.trending_up;
        color = Colors.red;
        message = 'Your spending is increasing';
        break;
      case 'decreasing':
        icon = Icons.trending_down;
        color = Colors.green;
        message = 'Your spending is decreasing';
        break;
      default:
        icon = Icons.trending_flat;
        color = Colors.blue;
        message = 'Your spending is stable';
    }

    return Card(
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(
          'Spending Trend',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(message),
      ),
    );
  }

  Widget _buildUnusualPatternsCard(List<String> patterns) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Unusual Patterns Detected',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...patterns.map((pattern) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(child: Text(pattern)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurringExpensesCard(List recurringExpenses) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.repeat, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Recurring Expenses',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recurringExpenses.map((expense) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    child: Text(expense.frequency[0].toUpperCase()),
                  ),
                  title: Text(expense.merchantName),
                  subtitle: Text(
                    '${expense.frequency} • ${expense.occurrences} times',
                  ),
                  trailing: Text(
                    Formatters.formatCurrency(expense.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
