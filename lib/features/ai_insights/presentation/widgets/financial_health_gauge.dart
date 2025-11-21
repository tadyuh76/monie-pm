import 'package:flutter/material.dart';

class FinancialHealthGauge extends StatelessWidget {
  final int score;

  const FinancialHealthGauge({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = score / 100;
    final color = _getColorForScore(score);
    final label = _getLabelForScore(score);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Financial Health Score',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Circular gauge
            SizedBox(
              height: 200,
              width: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 20,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(Colors.grey.shade200),
                    ),
                  ),
                  
                  // Progress circle
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: CircularProgressIndicator(
                      value: percentage,
                      strokeWidth: 20,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                  
                  // Score text
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        score.toString(),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Score explanation
            _buildScoreExplanation(score),
          ],
        ),
      ),
    );
  }

  Color _getColorForScore(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getLabelForScore(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Needs Improvement';
  }

  Widget _buildScoreExplanation(int score) {
    String message;
    IconData icon;
    Color color;

    if (score >= 80) {
      icon = Icons.celebration;
      color = Colors.green;
      message = 'Great job! You\'re managing your finances well. Keep up the good habits!';
    } else if (score >= 60) {
      icon = Icons.thumb_up;
      color = Colors.blue;
      message = 'You\'re doing well! There\'s room for some improvements to optimize your spending.';
    } else if (score >= 40) {
      icon = Icons.info_outline;
      color = Colors.orange;
      message = 'Your financial health is fair. Consider reviewing your spending patterns and making adjustments.';
    } else {
      icon = Icons.warning_amber;
      color = Colors.red;
      message = 'Your financial health needs attention. Review your spending and create a budget plan.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
