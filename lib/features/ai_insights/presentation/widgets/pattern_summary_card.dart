import 'package:flutter/material.dart';
import 'package:monie/core/utils/formatters.dart';
import 'package:monie/features/ai_insights/domain/entities/spending_pattern.dart';

class PatternSummaryCard extends StatelessWidget {
  final SpendingPattern pattern;

  const PatternSummaryCard({
    super.key,
    required this.pattern,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spending Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Total Spending
            _buildSummaryRow(
              icon: Icons.payments,
              label: 'Total Spending',
              value: Formatters.formatCurrency(pattern.totalSpending),
              valueColor: Colors.red.shade700,
            ),
            const Divider(height: 24),
            
            // Average Daily
            _buildSummaryRow(
              icon: Icons.calendar_today,
              label: 'Daily Average',
              value: Formatters.formatCurrency(pattern.avgDailySpending),
              valueColor: Colors.blue.shade700,
            ),
            const Divider(height: 24),
            
            // Top Category
            if (pattern.topCategory != null)
              _buildSummaryRow(
                icon: Icons.category,
                label: 'Top Category',
                value: pattern.topCategory!,
                valueColor: Colors.purple.shade700,
              ),
            
            if (pattern.topCategory != null) const Divider(height: 24),
            
            // Peak Day
            if (pattern.peakDayOfWeek != null)
              _buildSummaryRow(
                icon: Icons.event,
                label: 'Peak Spending Day',
                value: _getDayName(pattern.peakDayOfWeek!),
                valueColor: Colors.orange.shade700,
              ),
            
            if (pattern.peakDayOfWeek != null) const Divider(height: 24),
            
            // Peak Hour
            if (pattern.peakHour != null)
              _buildSummaryRow(
                icon: Icons.access_time,
                label: 'Peak Spending Hour',
                value: '${pattern.peakHour}:00',
                valueColor: Colors.teal.shade700,
              ),
            
            // Period
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.date_range, size: 20, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Period: ${Formatters.formatShortDate(pattern.startDate)} - ${Formatters.formatShortDate(pattern.endDate)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  String _getDayName(int dayOfWeek) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[dayOfWeek];
  }
}
