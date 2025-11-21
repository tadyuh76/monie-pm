// lib/features/predictions/presentation/widgets/category_forecast_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:monie/features/predictions/domain/entities/spending_prediction.dart';

class CategoryForecastChart extends StatelessWidget {
  final SpendingPrediction prediction;

  const CategoryForecastChart({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    final categories = prediction.categoryPredictions;
    if (categories.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('No category data available'),
        ),
      );
    }

    final total = categories.fold<double>(0, (sum, e) => sum + e.predictedAmount);
    final pieSections = categories.map((e) {
      final percent = (e.predictedAmount / (total == 0 ? 1 : total)) * 100;
      return PieChartSectionData(
        value: e.predictedAmount,
        title: '${e.categoryName} (${percent.toStringAsFixed(0)}%)',
        color: _getColor(e.categoryName),
        radius: 60,
        titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Breakdown by Category', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: pieSections,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
            SizedBox(height: 12),
            ...categories.map((cat) => Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getColor(cat.categoryName),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(child: Text(cat.categoryName)),
                    Text('\$${cat.predictedAmount.toStringAsFixed(0)}'),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  // Helper function to assign color by category (edit for your app's palette)
  Color _getColor(String category) {
    final colors = <String, Color>{
      'Food': Colors.orange,
      'Transport': Colors.blue,
      'Shopping': Colors.purple,
      'Entertainment': Colors.green,
      'Bills': Colors.red,
      'Healthcare': Colors.teal,
      'Others': Colors.grey,
    };
    return colors[category] ?? Colors.grey.shade400;
  }
}
