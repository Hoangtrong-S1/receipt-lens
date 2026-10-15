import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/expense.dart';

class DatabaseService {
  Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;
    final dbPath = join(await getDatabasesPath(), 'receipt_lens.db');
    _database = await openDatabase(dbPath, version: 1, onCreate: (db, _) async {
      await db.execute('''
        CREATE TABLE expenses(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          merchant TEXT NOT NULL,
          amount REAL NOT NULL,
          transaction_date TEXT NOT NULL,
          category TEXT NOT NULL,
          image_path TEXT,
          note TEXT,
          raw_text TEXT
        )
      ''');
    });
    return _database!;
  }

  Future<List<Expense>> getExpenses() async {
    final rows = await (await _db).query('expenses', orderBy: 'transaction_date DESC, id DESC');
    return rows.map(Expense.fromMap).toList();
  }

  Future<Expense> insert(Expense expense) async {
    final map = expense.toMap()..remove('id');
    final id = await (await _db).insert('expenses', map);
    return Expense(
      id: id,
      merchant: expense.merchant,
      amount: expense.amount,
      transactionDate: expense.transactionDate,
      category: expense.category,
      imagePath: expense.imagePath,
      note: expense.note,
      rawText: expense.rawText,
    );
  }

  Future<void> delete(int id) async =>
      (await _db).delete('expenses', where: 'id = ?', whereArgs: [id]);
}
