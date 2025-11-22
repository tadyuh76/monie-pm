import 'package:monie/features/budgets/domain/entities/budget.dart';
import 'package:monie/features/transactions/domain/entities/transaction.dart';

class FinancialContext {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpenses;
  final Map<String, double> categorySpending;
  final List<Budget> activeBudgets;
  final List<Transaction> recentTransactions;
  final double savingsRate;

  const FinancialContext({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.categorySpending,
    required this.activeBudgets,
    required this.recentTransactions,
    required this.savingsRate,
  });

  /// Convert financial data into a readable prompt string for AI
  String toPromptContext() {
    return """
**User Financial Snapshot:**
- Total Balance: \$$totalBalance
- Monthly Income: \$$monthlyIncome
- Monthly Expenses: \$$monthlyExpenses
- Savings Rate: ${(savingsRate * 100).toStringAsFixed(1)}%

**Top Spending Categories:**
${categorySpending.entries.take(5).map((e) => '- ${e.key}: \$${e.value.toStringAsFixed(2)}').join('\n')}

**Active Budgets:**
${activeBudgets.map((b) => '- ${b.name}: \$${b.amount.toStringAsFixed(2)}').join('\n')}

**Recent Transactions (Last 5):**
${recentTransactions.take(5).map((t) => '- \$${t.amount.toStringAsFixed(2)} at ${t.title ?? 'Unknown'} on ${t.date.day}/${t.date.month}').join('\n')}
""";
  }
}
