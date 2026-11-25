import 'package:flutter/foundation.dart';

import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../services/database_helper.dart';

class FinanceProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper;

  FinanceProvider({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  bool _isLoading = false;
  String? _errorMessage;

  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  List<BudgetProgress> _budgetProgressList = [];

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<CategoryModel> get categories => List.unmodifiable(_categories);
  List<BudgetProgress> get budgetProgressList =>
      List.unmodifiable(_budgetProgressList);
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;

  List<CategoryModel> getCategoriesByType(String type) {
    return _categories.where((c) => c.type == type).toList();
  }

  double get totalBudget => _budgetProgressList.fold(
        0.0,
        (sum, item) => sum + item.budget.limitAmount,
      );

  double get totalSpent => _budgetProgressList.fold(
        0.0,
        (sum, item) => sum + item.spentAmount,
      );

  double get totalRemaining => totalBudget - totalSpent;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _dbHelper.getCategories();
      _transactions = await _dbHelper.getTransactions();
      await _loadBudgetsInternal();
    } catch (e) {
      _errorMessage = 'Gagal memuat data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    try {
      _categories = await _dbHelper.getCategories();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat kategori: $e';
      notifyListeners();
    }
  }

  Future<void> fetchTransactions() async {
    try {
      _transactions = await _dbHelper.getTransactions();
      await _loadBudgetsInternal();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat transaksi: $e';
      notifyListeners();
    }
  }

  Future<bool> addTransaction({
    required String title,
    required double amount,
    required String type,
    required String categoryId,
    required DateTime date,
    String? note,
    String source = 'manual',
  }) async {
    _errorMessage = null;
    try {
      final now = DateTime.now();
      final id = 'trx_${now.microsecondsSinceEpoch}';
      final transaction = TransactionModel(
        id: id,
        title: title,
        amount: amount,
        type: type,
        categoryId: categoryId,
        date: date.toIso8601String(),
        note: note?.trim().isEmpty == true ? null : note?.trim(),
        source: source,
        createdAt: now.toIso8601String(),
      );

      await _dbHelper.insertTransaction(transaction);
      _transactions = await _dbHelper.getTransactions();
      await _loadBudgetsInternal();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menyimpan transaksi: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction(TransactionModel transaction) async {
    _errorMessage = null;
    try {
      await _dbHelper.updateTransaction(transaction);
      _transactions = await _dbHelper.getTransactions();
      await _loadBudgetsInternal();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui transaksi: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    _errorMessage = null;
    try {
      await _dbHelper.deleteTransaction(id);
      _transactions = await _dbHelper.getTransactions();
      await _loadBudgetsInternal();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus transaksi: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> setBudgetPeriod(int month, int year) async {
    _selectedMonth = month;
    _selectedYear = year;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadBudgetsInternal();
    } catch (e) {
      _errorMessage = 'Gagal memuat budget: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBudgets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadBudgetsInternal();
    } catch (e) {
      _errorMessage = 'Gagal memuat budget: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadBudgetsInternal() async {
    if (_categories.isEmpty) {
      _categories = await _dbHelper.getCategories();
    }
    final budgets =
        await _dbHelper.getBudgetsByPeriod(_selectedMonth, _selectedYear);
    final categoryMap = {for (final c in _categories) c.id: c};

    final progressList = <BudgetProgress>[];
    for (final budget in budgets) {
      final category = categoryMap[budget.categoryId];
      if (category == null) continue;

      final spent = await _dbHelper.getSpentAmountByCategory(
        budget.categoryId,
        _selectedMonth,
        _selectedYear,
      );

      progressList.add(
        BudgetProgress(
          budget: budget,
          category: category,
          spentAmount: spent,
        ),
      );
    }

    _budgetProgressList = progressList;
  }

  Future<bool> addBudget({
    required String categoryId,
    required double limitAmount,
  }) async {
    _errorMessage = null;
    try {
      final exists = await _dbHelper.budgetExists(
        categoryId,
        _selectedMonth,
        _selectedYear,
      );
      if (exists) {
        _errorMessage =
            'Budget untuk kategori ini pada periode tersebut sudah ada.';
        notifyListeners();
        return false;
      }

      final budget = BudgetModel(
        id: 'bdg_${DateTime.now().microsecondsSinceEpoch}',
        categoryId: categoryId,
        limitAmount: limitAmount,
        month: _selectedMonth,
        year: _selectedYear,
      );

      await _dbHelper.insertBudget(budget);
      await _loadBudgetsInternal();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambahkan budget: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBudget(BudgetModel budget, double newLimitAmount) async {
    _errorMessage = null;
    try {
      final updated = budget.copyWith(limitAmount: newLimitAmount);
      await _dbHelper.updateBudget(updated);
      await _loadBudgetsInternal();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui budget: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBudget(String id) async {
    _errorMessage = null;
    try {
      await _dbHelper.deleteBudget(id);
      await _loadBudgetsInternal();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus budget: $e';
      notifyListeners();
      return false;
    }
  }
}
