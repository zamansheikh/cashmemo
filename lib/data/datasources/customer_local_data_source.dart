import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../models/customer_model.dart';
import 'database_helper.dart';

class CustomerLocalDataSource {
  final DatabaseHelper _databaseHelper;

  CustomerLocalDataSource(this._databaseHelper);

  Future<List<CustomerModel>> getAllCustomers() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.customersTable,
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => CustomerModel.fromMap(maps[i]));
  }

  Future<CustomerModel?> getCustomerById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.customersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return CustomerModel.fromMap(maps.first);
  }

  Future<void> insertCustomer(CustomerModel customer) async {
    final db = await _databaseHelper.database;
    await db.insert(
      AppConstants.customersTable,
      customer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    final db = await _databaseHelper.database;
    await db.update(
      AppConstants.customersTable,
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<void> deleteCustomer(String id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      AppConstants.customersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<CustomerModel>> searchCustomers(String query) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.customersTable,
      where: 'name LIKE ? OR phone LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => CustomerModel.fromMap(maps[i]));
  }
}
