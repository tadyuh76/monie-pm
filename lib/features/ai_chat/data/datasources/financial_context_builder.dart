import 'package:monie/features/ai_chat/domain/entities/financial_context.dart';
import 'package:monie/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:monie/features/budgets/domain/repositories/budget_repository.dart';
// import 'package:monie/features/accounts/domain/repositories/account_repository.dart'; // Nếu có

class FinancialContextBuilder {
  final TransactionRepository transactionRepository;
  final BudgetRepository budgetRepository;
  // final AccountRepository accountRepository;

  FinancialContextBuilder({
    required this.transactionRepository,
    required this.budgetRepository,
    // required this.accountRepository,
  });

  Future<FinancialContext> build(String userId) async {
    // Lấy dữ liệu song song để tối ưu performance
    final results = await Future.wait([
      budgetRepository.getActiveBudgets(),
      // Get recent transactions (giả định hàm này có trong repo)
      transactionRepository.getTransactions(userId), 
    ]);

    final budgets = results[0] as List<dynamic>; // Cast về đúng type của Budget
    final transactions = results[1] as List<dynamic>; // Cast về đúng type của Transaction

    // Tính toán Category Spending
    final Map<String, double> categorySpending = {};
    double monthlyExpenses = 0.0;
    
    for (var t in transactions) {
      // Giả định Transaction entity có field amount và categoryName
      // Logic thực tế cần filter theo tháng hiện tại
      monthlyExpenses += t.amount;
      final category = t.categoryName ?? 'Uncategorized';
      categorySpending[category] = (categorySpending[category] ?? 0) + t.amount;
    }

    return FinancialContext(
      totalBalance: 0.0, // TODO: Lấy từ AccountRepository
      monthlyIncome: 0.0, // TODO: Lấy từ User Profile hoặc Income Transactions
      monthlyExpenses: monthlyExpenses,
      categorySpending: categorySpending,
      activeBudgets: budgets.cast(),
      recentTransactions: transactions.cast(),
      savingsRate: 0.0, // TODO: Tính toán
    );
  }
}
