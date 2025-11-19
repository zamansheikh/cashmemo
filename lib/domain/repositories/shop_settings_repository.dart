import '../entities/shop_settings.dart';

abstract class ShopSettingsRepository {
  Future<ShopSettings?> getShopSettings();
  Future<void> saveShopSettings(ShopSettings settings);
}
