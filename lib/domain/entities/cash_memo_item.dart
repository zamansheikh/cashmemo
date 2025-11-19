import 'package:equatable/equatable.dart';

class CashMemoItem extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final double quantity;
  final String unit;
  final double price;
  final double total;

  const CashMemoItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.total,
  });

  CashMemoItem copyWith({
    String? id,
    String? productId,
    String? productName,
    double? quantity,
    String? unit,
    double? price,
    double? total,
  }) {
    return CashMemoItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    productName,
    quantity,
    unit,
    price,
    total,
  ];
}
