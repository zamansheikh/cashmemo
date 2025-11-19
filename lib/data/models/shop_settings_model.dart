import '../../domain/entities/shop_settings.dart';

class ShopSettingsModel extends ShopSettings {
  const ShopSettingsModel({
    required super.id,
    required super.shopName,
    super.tagline,
    super.address,
    super.website,
    super.terms,
    super.phone,
    super.email,
    super.gstNumber,
    super.logoPath,
    super.invoiceByName,
    super.invoiceByRole,
    super.invoiceByContact,
  });

  factory ShopSettingsModel.fromMap(Map<String, dynamic> map) {
    return ShopSettingsModel(
      id: map['id'] as String,
      shopName: map['shop_name'] as String,
      tagline: map['tagline'] as String?,
      address: map['address'] as String?,
      website: map['website'] as String?,
      terms: map['terms'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      gstNumber: map['gst_number'] as String?,
      logoPath: map['logo_path'] as String?,
      invoiceByName: map['invoice_by_name'] as String?,
      invoiceByRole: map['invoice_by_role'] as String?,
      invoiceByContact: map['invoice_by_contact'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shop_name': shopName,
      'tagline': tagline,
      'address': address,
      'website': website,
      'terms': terms,
      'phone': phone,
      'email': email,
      'gst_number': gstNumber,
      'logo_path': logoPath,
      'invoice_by_name': invoiceByName,
      'invoice_by_role': invoiceByRole,
      'invoice_by_contact': invoiceByContact,
    };
  }

  factory ShopSettingsModel.fromEntity(ShopSettings settings) {
    return ShopSettingsModel(
      id: settings.id,
      shopName: settings.shopName,
      tagline: settings.tagline,
      address: settings.address,
      website: settings.website,
      terms: settings.terms,
      phone: settings.phone,
      email: settings.email,
      gstNumber: settings.gstNumber,
      logoPath: settings.logoPath,
      invoiceByName: settings.invoiceByName,
      invoiceByRole: settings.invoiceByRole,
      invoiceByContact: settings.invoiceByContact,
    );
  }
}
