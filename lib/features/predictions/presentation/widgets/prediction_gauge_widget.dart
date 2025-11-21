// lib/features/predictions/presentation/widgets/prediction_gauge_widget.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:monie/features/predictions/domain/entities/spending_prediction.dart';

class PredictionGaugeWidget extends StatelessWidget {
  final SpendingPrediction prediction;

  const PredictionGaugeWidget({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isOverBudget = prediction.isOverBudget;
    final utilization = prediction.budgetUtilization;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Next Period Forecast',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // Custom Gauge
            SizedBox(
              height: 200,
              width: 200,
              child: CustomPaint(
                painter: GaugePainter(
                  value: utilization.clamp(0.0, 1.0),
                  isOverBudget: isOverBudget,
                  isDarkMode: isDarkMode,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '\$${prediction.predictedTotal.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isOverBudget ? Colors.red : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Predicted',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(utilization * 100).toStringAsFixed(0)}% of budget',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Budget Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.blue.shade900.withOpacity(0.3)
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.flag,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Budget',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '\$${prediction.budget.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (isOverBudget)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            size: 16,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Over Budget',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Difference indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isOverBudget ? Icons.arrow_upward : Icons.check_circle,
                  size: 16,
                  color: isOverBudget ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  isOverBudget
                      ? 'Over by \$${(prediction.predictedTotal - prediction.budget).toStringAsFixed(0)}'
                      : 'Under by \$${(prediction.budget - prediction.predictedTotal).toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isOverBudget ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Gauge Painter
class GaugePainter extends CustomPainter {
  final double value; // 0.0 to 1.0
  final bool isOverBudget;
  final bool isDarkMode;

  GaugePainter({
    required this.value,
    required this.isOverBudget,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 20;

    // Background arc
    final backgroundPaint = Paint()
      ..color = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi * 0.75, // Start angle (bottom left)
      pi * 1.5, // Sweep angle (270 degrees)
      false,
      backgroundPaint,
    );

    // Foreground arc (progress)
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: isOverBudget
            ? [Colors.orange, Colors.red]
            : [Colors.green.shade400, Colors.green.shade600],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi * 0.75,
      pi * 1.5 * value.clamp(0.0, 1.0),
      false,
      progressPaint,
    );

    // Budget threshold marker (vertical line at 100%)
    final markerPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final markerAngle = -pi * 0.75 + pi * 1.5; // 100% position
    final markerStart = Offset(
      center.dx + (radius - 25) * cos(markerAngle),
      center.dy + (radius - 25) * sin(markerAngle),
    );
    final markerEnd = Offset(
      center.dx + (radius + 5) * cos(markerAngle),
      center.dy + (radius + 5) * sin(markerAngle),
    );

    canvas.drawLine(markerStart, markerEnd, markerPaint);
  }

  @override
  bool shouldRepaint(GaugePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.isOverBudget != isOverBudget;
  }
}
