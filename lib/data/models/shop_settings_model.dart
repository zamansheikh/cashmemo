import '../../domain/entities/shop_settings.dart';

class ShopSettingsModel extends ShopSettings {
  const ShopSettingsModel({
    required super.id,
    required super.shopName,
    super.address,
    super.phone,
    super.email,
    super.gstNumber,
    super.logoPath,
  });

  factory ShopSettingsModel.fromMap(Map<String, dynamic> map) {
    return ShopSettingsModel(
      id: map['id'] as String,
      shopName: map['shop_name'] as String,
      address: map['address'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      gstNumber: map['gst_number'] as String?,
      logoPath: map['logo_path'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shop_name': shopName,
      'address': address,
      'phone': phone,
      'email': email,
      'gst_number': gstNumber,
      'logo_path': logoPath,
    };
  }

  factory ShopSettingsModel.fromEntity(ShopSettings settings) {
    return ShopSettingsModel(
      id: settings.id,
      shopName: settings.shopName,
      address: settings.address,
      phone: settings.phone,
      email: settings.email,
      gstNumber: settings.gstNumber,
      logoPath: settings.logoPath,
    );
  }
}
