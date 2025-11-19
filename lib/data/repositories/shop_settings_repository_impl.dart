import '../../domain/entities/shop_settings.dart';
import '../../domain/repositories/shop_settings_repository.dart';
import '../datasources/shop_settings_local_data_source.dart';
import '../models/shop_settings_model.dart';

class ShopSettingsRepositoryImpl implements ShopSettingsRepository {
  final ShopSettingsLocalDataSource localDataSource;

  ShopSettingsRepositoryImpl(this.localDataSource);

  @override
  Future<ShopSettings?> getShopSettings() async {
    return await localDataSource.getShopSettings();
  }

  @override
  Future<void> saveShopSettings(ShopSettings settings) async {
    final settingsModel = ShopSettingsModel.fromEntity(settings);
    await localDataSource.saveShopSettings(settingsModel);
  }
}
