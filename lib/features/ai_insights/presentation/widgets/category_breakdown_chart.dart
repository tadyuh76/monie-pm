import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:monie/core/themes/category_colors.dart';
import 'package:monie/core/utils/formatters.dart';

class CategoryBreakdownChart extends StatelessWidget {
  final Map<String, double> categoryBreakdown;

  const CategoryBreakdownChart({
    super.key,
    required this.categoryBreakdown,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryBreakdown.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('No category data available'),
          ),
        ),
      );
    }

    // Sort categories by amount
    final sortedEntries = categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Take top 8 categories, group rest as "Others"
    final topCategories = sortedEntries.take(8).toList();
    final othersTotal = sortedEntries.skip(8).fold(
      0.0,
      (sum, entry) => sum + entry.value,
    );

    final total = categoryBreakdown.values.fold(0.0, (sum, val) => sum + val);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Pie Chart
            SizedBox(
              height: 250,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 50,
                        sections: _buildPieChartSections(
                          topCategories,
                          othersTotal,
                          total,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildLegend(topCategories, othersTotal, total),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Category List
            ...topCategories.map((entry) => _buildCategoryRow(
              category: entry.key,
              amount: entry.value,
              percentage: (entry.value / total) * 100,
            )),
            
            if (othersTotal > 0)
              _buildCategoryRow(
                category: 'Others',
                amount: othersTotal,
                percentage: (othersTotal / total) * 100,
              ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    List<MapEntry<String, double>> topCategories,
    double othersTotal,
    double total,
  ) {
    final sections = <PieChartSectionData>[];

    for (var i = 0; i < topCategories.length; i++) {
      final entry = topCategories[i];
      final percentage = (entry.value / total) * 100;
      
      sections.add(
        PieChartSectionData(
          value: entry.value,
          title: '${percentage.toStringAsFixed(0)}%',
          color: _getCategoryColor(i),
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    if (othersTotal > 0) {
      final percentage = (othersTotal / total) * 100;
      sections.add(
        PieChartSectionData(
          value: othersTotal,
          title: '${percentage.toStringAsFixed(0)}%',
          color: Colors.grey,
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
  }

  Widget _buildLegend(
    List<MapEntry<String, double>> topCategories,
    double othersTotal,
    double total,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...topCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(index),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (othersTotal > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Others',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow({
    required String category,
    required double amount,
    required double percentage,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(
                    _getCategoryColor(
                      categoryBreakdown.keys.toList().indexOf(category),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.formatCurrency(amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      CategoryColors.blue,
      CategoryColors.green,
      CategoryColors.red,
      CategoryColors.orange,
      CategoryColors.purple,
      CategoryColors.plum,
      CategoryColors.teal,
      CategoryColors.gold,
    ];
    return colors[index % colors.length];
  }
}
