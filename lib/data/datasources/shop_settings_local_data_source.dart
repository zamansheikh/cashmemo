import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../models/shop_settings_model.dart';
import 'database_helper.dart';

class ShopSettingsLocalDataSource {
  final DatabaseHelper _databaseHelper;

  ShopSettingsLocalDataSource(this._databaseHelper);

  Future<ShopSettingsModel?> getShopSettings() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.shopSettingsTable,
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ShopSettingsModel.fromMap(maps.first);
  }

  Future<void> saveShopSettings(ShopSettingsModel settings) async {
    final db = await _databaseHelper.database;
    await db.insert(
      AppConstants.shopSettingsTable,
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
