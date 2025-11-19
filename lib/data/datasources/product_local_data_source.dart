import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../models/product_model.dart';
import 'database_helper.dart';

class ProductLocalDataSource {
  final DatabaseHelper _databaseHelper;

  ProductLocalDataSource(this._databaseHelper);

  Future<List<ProductModel>> getAllProducts() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.productsTable,
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => ProductModel.fromMap(maps[i]));
  }

  Future<ProductModel?> getProductById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.productsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return ProductModel.fromMap(maps.first);
  }

  Future<void> insertProduct(ProductModel product) async {
    final db = await _databaseHelper.database;
    await db.insert(
      AppConstants.productsTable,
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateProduct(ProductModel product) async {
    final db = await _databaseHelper.database;
    await db.update(
      AppConstants.productsTable,
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> deleteProduct(String id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      AppConstants.productsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.productsTable,
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => ProductModel.fromMap(maps[i]));
  }
}
