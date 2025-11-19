import 'package:equatable/equatable.dart';

class ShopSettings extends Equatable {
  final String id;
  final String shopName;
  final String? address;
  final String? phone;
  final String? email;
  final String? gstNumber;
  final String? logoPath;

  const ShopSettings({
    required this.id,
    required this.shopName,
    this.address,
    this.phone,
    this.email,
    this.gstNumber,
    this.logoPath,
  });

  ShopSettings copyWith({
    String? id,
    String? shopName,
    String? address,
    String? phone,
    String? email,
    String? gstNumber,
    String? logoPath,
  }) {
    return ShopSettings(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      address: address ?? this.address,
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
    address,
    phone,
    email,
    gstNumber,
    logoPath,
  ];
}
