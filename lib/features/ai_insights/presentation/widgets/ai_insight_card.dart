import 'package:flutter/material.dart';

class AIInsightCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final List<String>? recommendations;

  const AIInsightCard({
    super.key,
    required this.title,
    required this.content,
    this.icon = Icons.lightbulb_outline,
    this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
                    Colors.purple.shade900.withOpacity(0.3),
                    Colors.blue.shade900.withOpacity(0.3),
                  ]
                : [
                    Colors.purple.shade50,
                    Colors.blue.shade50,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                          ? Colors.purple.shade800
                          : Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: isDarkMode ? Colors.purple.shade300 : Colors.purple.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.purple.shade200 : Colors.purple.shade900,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 12,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'AI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Content
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
                ),
              ),
              
              // Recommendations (if provided)
              if (recommendations != null && recommendations!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Divider(color: isDarkMode ? Colors.grey.shade700 : null),
                const SizedBox(height: 8),
                Text(
                  'Recommendations',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.purple.shade200 : Colors.purple.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                ...recommendations!.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: isDarkMode ? Colors.green.shade400 : Colors.green.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rec,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
