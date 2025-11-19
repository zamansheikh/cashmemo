import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../models/cash_memo_model.dart';
import '../models/cash_memo_item_model.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

class CashMemoLocalDataSource {
  final DatabaseHelper _databaseHelper;

  CashMemoLocalDataSource(this._databaseHelper);

  Future<List<CashMemoModel>> getAllCashMemos() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> memoMaps = await db.query(
      AppConstants.cashMemosTable,
      orderBy: 'created_at DESC',
    );

    List<CashMemoModel> cashMemos = [];
    for (var memoMap in memoMaps) {
      final items = await _getCashMemoItems(db, memoMap['id'] as String);
      cashMemos.add(CashMemoModel.fromMap(memoMap, items));
    }
    return cashMemos;
  }

  Future<CashMemoModel?> getCashMemoById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.cashMemosTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;

    final items = await _getCashMemoItems(db, id);
    return CashMemoModel.fromMap(maps.first, items);
  }

  Future<List<CashMemoItemModel>> _getCashMemoItems(
    Database db,
    String cashMemoId,
  ) async {
    final List<Map<String, dynamic>> itemMaps = await db.query(
      AppConstants.cashMemoItemsTable,
      where: 'cash_memo_id = ?',
      whereArgs: [cashMemoId],
    );
    return List.generate(
      itemMaps.length,
      (i) => CashMemoItemModel.fromMap(itemMaps[i]),
    );
  }

  Future<void> insertCashMemo(CashMemoModel cashMemo) async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      // Insert cash memo
      await txn.insert(
        AppConstants.cashMemosTable,
        cashMemo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert cash memo items
      for (var item in cashMemo.items) {
        final itemModel = CashMemoItemModel.fromEntity(item, cashMemo.id);
        await txn.insert(
          AppConstants.cashMemoItemsTable,
          itemModel.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> deleteCashMemo(String id) async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      // Delete cash memo items first
      await txn.delete(
        AppConstants.cashMemoItemsTable,
        where: 'cash_memo_id = ?',
        whereArgs: [id],
      );

      // Delete cash memo
      await txn.delete(
        AppConstants.cashMemosTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<String> generateMemoNumber() async {
    final db = await _databaseHelper.database;
    final now = DateTime.now();
    final prefix = 'CM${DateFormat('yyyyMMdd').format(now)}';

    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.cashMemosTable,
      where: 'memo_number LIKE ?',
      whereArgs: ['$prefix%'],
      orderBy: 'memo_number DESC',
      limit: 1,
    );

    if (maps.isEmpty) {
      return '${prefix}001';
    }

    final lastNumber = maps.first['memo_number'] as String;
    final sequence = int.parse(lastNumber.substring(prefix.length));
    final nextSequence = sequence + 1;
    return '$prefix${nextSequence.toString().padLeft(3, '0')}';
  }

  Future<List<CashMemoModel>> getCashMemosByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> memoMaps = await db.query(
      AppConstants.cashMemosTable,
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'created_at DESC',
    );

    List<CashMemoModel> cashMemos = [];
    for (var memoMap in memoMaps) {
      final items = await _getCashMemoItems(db, memoMap['id'] as String);
      cashMemos.add(CashMemoModel.fromMap(memoMap, items));
    }
    return cashMemos;
  }
}
