// lib/features/home/presentation/widgets/ai_analysis_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monie/core/themes/app_colors.dart';
import 'package:monie/di/injection.dart';
import 'package:monie/features/ai_insights/presentation/bloc/spending_pattern_bloc.dart';
import 'package:monie/features/ai_insights/presentation/bloc/spending_pattern_event.dart';
import 'package:monie/features/ai_insights/presentation/bloc/spending_pattern_state.dart';
import 'package:monie/features/ai_insights/presentation/pages/spending_analysis_page.dart';
import 'package:monie/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:monie/features/authentication/presentation/bloc/auth_state.dart';

class AIAnalysisWidget extends StatelessWidget {
  const AIAnalysisWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = sl<SpendingPatternBloc>();
        // Auto-load analysis khi widget được tạo
        final authState = context.read<AuthBloc>().state;
        if (authState is Authenticated) {
          bloc.add(AnalyzeSpendingPatternEvent(
            userId: authState.user.id,
            monthsBack: 1, // Quick 1-month analysis cho home
          ));
        }
        return bloc;
      },
      child: const _AIAnalysisContent(),
    );
  }
} // ⭐ DẤU ĐÓNG CHO AIAnalysisWidget

class _AIAnalysisContent extends StatelessWidget {
  const _AIAnalysisContent();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<SpendingPatternBloc, SpendingPatternState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            // ⭐ Navigate to full analysis page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SpendingAnalysisPage(),
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
                    ? [const Color(0xFF2E3747), const Color(0xFF1E2533)]
                    : [const Color(0xFFE9F7FF), const Color(0xFFD4EEFF)],
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
                            ? const Color(0xFF3D4A63)
                            : const Color(0xFFBBE0FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: isDarkMode ? Colors.cyanAccent : Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AI Spending Insights',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    if (state is SpendingPatternLoading)
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
                if (state is SpendingPatternLoading) ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Analyzing your spending...'),
                    ),
                  ),
                ] else if (state is SpendingPatternLoaded) ...[
                  // ⭐ Show real insights from AI
                  _buildInsightCard(
                    context,
                    title: 'Financial Health',
                    content: state.pattern.aiSummary ?? 'Analysis complete',
                    icon: Icons.health_and_safety,
                    color: _getHealthColor(state.pattern.financialHealthScore),
                  ),
                  if (state.pattern.unusualPatterns.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInsightCard(
                      context,
                      title: 'Unusual Activity',
                      content: state.pattern.unusualPatterns.first,
                      icon: Icons.warning_amber,
                      color: Colors.orange,
                    ),
                  ],
                ] else if (state is SpendingPatternError) ...[
                  _buildInsightCard(
                    context,
                    title: 'Analysis Unavailable',
                    content: 'Tap to view detailed insights',
                    icon: Icons.info_outline,
                    color: Colors.grey,
                  ),
                ],

                const SizedBox(height: 12),

                // View full analysis button
                Center(
                  child: Text(
                    'Tap to view full analysis →',
                    style: TextStyle(
                      color: isDarkMode ? Colors.cyanAccent : Colors.blue,
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

  Color _getHealthColor(int? score) {
    if (score == null) return Colors.grey;
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  Widget _buildInsightCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} // ⭐ DẤU ĐÓNG CHO _AIAnalysisContent
