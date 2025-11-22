// lib/features/home/presentation/widgets/forecast_summary_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monie/core/themes/app_colors.dart';
import 'package:monie/di/injection.dart';
import 'package:monie/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:monie/features/authentication/presentation/bloc/auth_state.dart';
import 'package:monie/features/budgets/domain/repositories/budget_repository.dart';
import 'package:monie/features/predictions/presentation/bloc/prediction_bloc.dart';
import 'package:monie/features/predictions/presentation/bloc/prediction_event.dart';
import 'package:monie/features/predictions/presentation/bloc/prediction_state.dart';
import 'package:monie/features/predictions/presentation/pages/spending_forecast_page.dart';

class ForecastSummaryWidget extends StatefulWidget {
  const ForecastSummaryWidget({super.key});

  @override
  State<ForecastSummaryWidget> createState() => _ForecastSummaryWidgetState();
}

class _ForecastSummaryWidgetState extends State<ForecastSummaryWidget> {
  late final PredictionBloc _predictionBloc;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _predictionBloc = sl<PredictionBloc>();
    
    // Load prediction with real budget after widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPredictionWithBudget();
    });
  }

  Future<void> _loadPredictionWithBudget() async {
    if (_isInitialized) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    try {
      // ⭐ Fetch real budget from database
      final budgetRepository = sl<BudgetRepository>();
      final activeBudgets = await budgetRepository.getActiveBudgets();

      double totalBudget = 2000.0; // Default
      if (activeBudgets.isNotEmpty) {
        totalBudget = activeBudgets.fold<double>(
          0.0,
          (sum, budget) => sum + budget.amount,
        );
        print('💰 [FORECAST SUMMARY] Total budget: \$${totalBudget.toStringAsFixed(0)}');
      }

      // ⭐ Trigger prediction with real budget
      if (mounted) {
        _predictionBloc.add(
          PredictNextMonthEvent(
            userId: authState.user.id,
            budget: totalBudget,
          ),
        );
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('❌ [FORECAST SUMMARY] Failed to load budget: $e');
      // Fallback to default
      if (mounted) {
        final authState = context.read<AuthBloc>().state;
        if (authState is Authenticated) {
          _predictionBloc.add(
            PredictNextMonthEvent(
              userId: authState.user.id,
              budget: 2000.0,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _predictionBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _predictionBloc,
      child: const _ForecastSummaryContent(),
    );
  }
}

// ⭐ Rest of the widget remains the same
class _ForecastSummaryContent extends StatelessWidget {
  const _ForecastSummaryContent();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<PredictionBloc, PredictionState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SpendingForecastPage(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: !isDarkMode
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [const Color(0xFF2E4756), const Color(0xFF1E3344)]
                    : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF3D5A6B)
                            : const Color(0xFFA5D6A7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.trending_up,
                        color: isDarkMode ? Colors.greenAccent : Colors.green,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Next Month Forecast',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    if (state is PredictionLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Content based on state
                if (state is PredictionLoading) ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Analyzing spending patterns...'),
                    ),
                  ),
                ] else if (state is PredictionLoaded) ...[
                  _buildPredictionSummary(
                    context,
                    state.prediction,
                    isDarkMode,
                    textTheme,
                  ),
                ] else if (state is PredictionError) ...[
                  _buildErrorCard(context, isDarkMode, textTheme),
                ],
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Tap to view detailed forecast →',
                    style: TextStyle(
                      color: isDarkMode ? Colors.greenAccent : Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPredictionSummary(
    BuildContext context,
    prediction,
    bool isDarkMode,
    TextTheme textTheme,
  ) {
    final isOverBudget = prediction.isOverBudget;
    final utilization = (prediction.budgetUtilization * 100).toInt();

    return Column(
      children: [
        // Main numbers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Predicted',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${prediction.predictedTotal.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isOverBudget ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Budget',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${prediction.budget.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Progress bar
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$utilization% of budget',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                if (isOverBudget)
                  Text(
                    'Over by \$${(prediction.predictedTotal - prediction.budget).toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: prediction.budgetUtilization.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: isDarkMode
                    ? Colors.grey.shade800
                    : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(
                  isOverBudget ? Colors.red : Colors.green,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Confidence indicator
        Row(
          children: [
            Icon(
              Icons.shield_outlined,
              size: 16,
              color: _getConfidenceColor(prediction.confidence),
            ),
            const SizedBox(width: 6),
            Text(
              'Confidence: ${prediction.confidenceLevel}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _getConfidenceColor(prediction.confidence),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${(prediction.confidence * 100).toInt()}%)',
              style: TextStyle(
                fontSize: 11,
                color: isDarkMode ? Colors.white60 : Colors.black45,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorCard(
    BuildContext context,
    bool isDarkMode,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Forecast Unavailable',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tap to retry or view details',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.blue;
    if (confidence >= 0.4) return Colors.orange;
    return Colors.red;
  }
}
