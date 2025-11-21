// lib/features/predictions/presentation/pages/spending_forecast_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monie/core/themes/app_colors.dart';
import 'package:monie/di/injection.dart';
import 'package:monie/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:monie/features/authentication/presentation/bloc/auth_state.dart';
import 'package:monie/features/predictions/presentation/bloc/prediction_bloc.dart';
import 'package:monie/features/predictions/presentation/bloc/prediction_event.dart';
import 'package:monie/features/predictions/presentation/bloc/prediction_state.dart';
import 'package:monie/features/predictions/presentation/widgets/prediction_gauge_widget.dart';
import 'package:monie/features/predictions/presentation/widgets/category_forecast_chart.dart';
import 'package:monie/features/predictions/presentation/widgets/confidence_indicator.dart';

class SpendingForecastPage extends StatelessWidget {
  final double? initialBudget;

  const SpendingForecastPage({
    super.key,
    this.initialBudget,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = sl<PredictionBloc>();
        final authState = context.read<AuthBloc>().state;
        
        if (authState is Authenticated) {
          bloc.add(PredictNextMonthEvent(
            userId: authState.user.id,
            budget: initialBudget ?? 2000.0, // Default budget
          ));
        }
        
        return bloc;
      },
      child: const _SpendingForecastView(),
    );
  }
}

class _SpendingForecastView extends StatefulWidget {
  const _SpendingForecastView();

  @override
  State<_SpendingForecastView> createState() => _SpendingForecastViewState();
}

class _SpendingForecastViewState extends State<_SpendingForecastView> {
  String _selectedPeriod = 'month';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.cardDark : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Spending Forecast'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PredictionBloc>().add(const RefreshPredictionEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<PredictionBloc, PredictionState>(
        builder: (context, state) {
          if (state is PredictionLoading) {
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

          if (state is PredictionError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to generate forecast',
                      style: textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<PredictionBloc>().add(
                              const RefreshPredictionEvent(),
                            );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is PredictionLoaded) {
            final prediction = state.prediction;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<PredictionBloc>().add(const RefreshPredictionEvent());
                await Future.delayed(const Duration(seconds: 1));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period Selector
                    _buildPeriodSelector(context, isDarkMode),
                    const SizedBox(height: 24),

                    // Main Gauge
                    PredictionGaugeWidget(prediction: prediction),
                    const SizedBox(height: 24),

                    // Confidence Indicator
                    ConfidenceIndicator(prediction: prediction),
                    const SizedBox(height: 24),

                    // AI Reasoning
                    _buildReasoningCard(prediction, isDarkMode, textTheme),
                    const SizedBox(height: 24),

                    // Category Forecast
                    CategoryForecastChart(prediction: prediction),
                    const SizedBox(height: 24),

                    // Warnings (if any)
                    if (prediction.warnings.isNotEmpty)
                      _buildWarningsCard(prediction, isDarkMode, textTheme),

                    if (prediction.warnings.isNotEmpty)
                      const SizedBox(height: 24),

                    // Recommendations
                    _buildRecommendationsCard(prediction, isDarkMode, textTheme),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, bool isDarkMode) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: _buildPeriodButton(
                context,
                'Week',
                'week',
                Icons.calendar_view_week,
                isDarkMode,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPeriodButton(
                context,
                'Month',
                'month',
                Icons.calendar_month,
                isDarkMode,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPeriodButton(
                context,
                'Quarter',
                'quarter',
                Icons.calendar_today,
                isDarkMode,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(
    BuildContext context,
    String label,
    String period,
    IconData icon,
    bool isDarkMode,
  ) {
    final isSelected = _selectedPeriod == period;
    final authState = context.read<AuthBloc>().state;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });

        if (authState is Authenticated) {
          final budget = 2000.0; // Get from user settings
          
          switch (period) {
            case 'week':
              context.read<PredictionBloc>().add(
                    PredictNextWeekEvent(
                      userId: authState.user.id,
                      budget: budget,
                    ),
                  );
              break;
            case 'month':
              context.read<PredictionBloc>().add(
                    PredictNextMonthEvent(
                      userId: authState.user.id,
                      budget: budget,
                    ),
                  );
              break;
            case 'quarter':
              context.read<PredictionBloc>().add(
                    PredictNextQuarterEvent(
                      userId: authState.user.id,
                      budget: budget * 3,
                    ),
                  );
              break;
          }
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? Colors.blue.shade900 : Colors.blue.shade50)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Colors.blue
                : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasoningCard(
    prediction,
    bool isDarkMode,
    TextTheme textTheme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Analysis',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              prediction.reasoning,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningsCard(
    prediction,
    bool isDarkMode,
    TextTheme textTheme,
  ) {
    return Card(
      color: isDarkMode ? Colors.orange.shade900.withOpacity(0.3) : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: Colors.orange.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Warnings',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...prediction.warnings.map((warning) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 6,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          warning,
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard(
    prediction,
    bool isDarkMode,
    TextTheme textTheme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tips_and_updates,
                  color: Colors.green.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recommendations',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...prediction.recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 20,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rec,
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
