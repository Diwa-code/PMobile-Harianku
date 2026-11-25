import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;
  static String? _customDbPath;

  DatabaseHelper._internal();

  /// Digunakan khusus untuk testing agar setiap test memakai database bersih.
  static Future<void> setTestDatabasePath(String path) async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    _customDbPath = path;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path =
        _customDbPath ?? join(await getDatabasesPath(), 'harianku.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon_name TEXT NOT NULL,
        color_hex TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category_id TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        source TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        category_id TEXT NOT NULL,
        limit_amount REAL NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        UNIQUE(category_id, month, year)
      )
    ''');

    await _seedDefaultCategories(db);
  }

  Future<void> _seedDefaultCategories(Database db) async {
    const defaultCategories = [
      // Expense categories
      CategoryModel(
        id: 'cat_exp_food',
        name: 'Makan',
        iconName: 'restaurant',
        colorHex: '#E45B64',
        type: 'expense',
      ),
      CategoryModel(
        id: 'cat_exp_transport',
        name: 'Transport',
        iconName: 'directions_car',
        colorHex: '#253B80',
        type: 'expense',
      ),
      CategoryModel(
        id: 'cat_exp_shopping',
        name: 'Belanja',
        iconName: 'shopping_bag',
        colorHex: '#F59E0B',
        type: 'expense',
      ),
      CategoryModel(
        id: 'cat_exp_bills',
        name: 'Tagihan',
        iconName: 'receipt_long',
        colorHex: '#6366F1',
        type: 'expense',
      ),
      CategoryModel(
        id: 'cat_exp_entertainment',
        name: 'Hiburan',
        iconName: 'movie',
        colorHex: '#EC4899',
        type: 'expense',
      ),
      CategoryModel(
        id: 'cat_exp_health',
        name: 'Kesehatan',
        iconName: 'local_hospital',
        colorHex: '#10B981',
        type: 'expense',
      ),
      CategoryModel(
        id: 'cat_exp_education',
        name: 'Pendidikan',
        iconName: 'school',
        colorHex: '#0EA5E9',
        type: 'expense',
      ),
      CategoryModel(
        id: 'cat_exp_other',
        name: 'Lainnya',
        iconName: 'more_horiz',
        colorHex: '#8A90A0',
        type: 'expense',
      ),

      // Income categories
      CategoryModel(
        id: 'cat_inc_salary',
        name: 'Gaji',
        iconName: 'payments',
        colorHex: '#22A06B',
        type: 'income',
      ),
      CategoryModel(
        id: 'cat_inc_freelance',
        name: 'Freelance',
        iconName: 'work',
        colorHex: '#253B80',
        type: 'income',
      ),
      CategoryModel(
        id: 'cat_inc_invest',
        name: 'Investasi',
        iconName: 'trending_up',
        colorHex: '#10B981',
        type: 'income',
      ),
      CategoryModel(
        id: 'cat_inc_gift',
        name: 'Hadiah',
        iconName: 'card_giftcard',
        colorHex: '#F59E0B',
        type: 'income',
      ),
      CategoryModel(
        id: 'cat_inc_other',
        name: 'Lainnya',
        iconName: 'more_horiz',
        colorHex: '#8A90A0',
        type: 'income',
      ),
    ];

    for (final category in defaultCategories) {
      await db.insert(
        'categories',
        category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  // ==================== CATEGORIES ====================

  Future<List<CategoryModel>> getCategories({String? type}) async {
    final db = await database;
    final maps = type != null
        ? await db.query(
            'categories',
            where: 'type = ?',
            whereArgs: [type],
          )
        : await db.query('categories');
    return maps.map((m) => CategoryModel.fromMap(m)).toList();
  }

  // ==================== TRANSACTIONS ====================

  Future<void> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      orderBy: 'date DESC, created_at DESC',
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== BUDGETS ====================

  Future<bool> budgetExists(String categoryId, int month, int year) async {
    final db = await database;
    final result = await db.query(
      'budgets',
      where: 'category_id = ? AND month = ? AND year = ?',
      whereArgs: [categoryId, month, year],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<void> insertBudget(BudgetModel budget) async {
    final db = await database;
    await db.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> updateBudget(BudgetModel budget) async {
    final db = await database;
    await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<void> deleteBudget(String id) async {
    final db = await database;
    await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<BudgetModel>> getBudgetsByPeriod(int month, int year) async {
    final db = await database;
    final maps = await db.query(
      'budgets',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );
    return maps.map((m) => BudgetModel.fromMap(m)).toList();
  }

  /// Menghitung total pengeluaran secara dinamis dari tabel transactions
  /// berdasarkan category_id, type = 'expense', month, dan year.
  Future<double> getSpentAmountByCategory(
    String categoryId,
    int month,
    int year,
  ) async {
    final db = await database;
    final monthStr = month.toString().padLeft(2, '0');
    final yearMonthPrefix = '$year-$monthStr';

    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0.0) AS total
      FROM transactions
      WHERE category_id = ?
        AND type = ?
        AND substr(date, 1, 7) = ?
      ''',
      [categoryId, 'expense', yearMonthPrefix],
    );

    if (result.isEmpty) return 0.0;
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
