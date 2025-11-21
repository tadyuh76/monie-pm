// lib/features/predictions/presentation/widgets/confidence_indicator.dart

import 'package:flutter/material.dart';
import 'package:monie/features/predictions/domain/entities/spending_prediction.dart';

class ConfidenceIndicator extends StatelessWidget {
  final SpendingPrediction prediction;

  const ConfidenceIndicator({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    final value = (prediction.confidence * 100).toInt();
    Color barColor = value >= 80
        ? Colors.green
        : value >= 60
            ? Colors.blue
            : value >= 40
                ? Colors.orange
                : Colors.red;

    String text = value >= 80
        ? 'High'
        : value >= 60
            ? 'Medium'
            : value >= 40
                ? 'Low'
                : 'Very Low';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.shield, color: barColor),
            SizedBox(width: 10),
            Text('Confidence: ', style: TextStyle(fontWeight: FontWeight.w600)),
            Expanded(
              child: LinearProgressIndicator(
                value: prediction.confidence,
                minHeight: 8,
                color: barColor,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
            SizedBox(width: 16),
            Text('$text ($value%)', style: TextStyle(color: barColor)),
          ],
        ),
      ),
    );
  }
}
