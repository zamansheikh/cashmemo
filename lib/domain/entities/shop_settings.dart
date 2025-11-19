import 'package:equatable/equatable.dart';

class ShopSettings extends Equatable {
  final String id;
  final String shopName;
  final String? tagline;
  final String? address;
  final String? website;
  final String? phone;
  final String? email;
  final String? gstNumber;
  final String? logoPath;

  const ShopSettings({
    required this.id,
    required this.shopName,
    this.tagline,
    this.address,
    this.website,
    this.phone,
    this.email,
    this.gstNumber,
    this.logoPath,
  });

  ShopSettings copyWith({
    String? id,
    String? shopName,
    String? tagline,
    String? address,
    String? website,
    String? phone,
    String? email,
    String? gstNumber,
    String? logoPath,
  }) {
    return ShopSettings(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      tagline: tagline ?? this.tagline,
      address: address ?? this.address,
      website: website ?? this.website,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gstNumber: gstNumber ?? this.gstNumber,
      logoPath: logoPath ?? this.logoPath,
    );
  }

  @override
  List<Object?> get props => [
    id,
    shopName,
    tagline,
    address,
    website,
    phone,
    email,
    gstNumber,
    logoPath,
  ];
}
