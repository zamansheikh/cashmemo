import '../../domain/entities/cash_memo_item.dart';

class CashMemoItemModel extends CashMemoItem {
  final String cashMemoId;

  const CashMemoItemModel({
    required super.id,
    required this.cashMemoId,
    required super.productId,
    required super.productName,
    required super.quantity,
    required super.unit,
    required super.price,
    required super.total,
  });

  factory CashMemoItemModel.fromMap(Map<String, dynamic> map) {
    return CashMemoItemModel(
      id: map['id'] as String,
      cashMemoId: map['cash_memo_id'] as String,
      productId: map['product_id'] as String,
      productName: map['product_name'] as String,
      quantity: map['quantity'] as double,
      unit: map['unit'] as String,
      price: map['price'] as double,
      total: map['total'] as double,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cash_memo_id': cashMemoId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'total': total,
    };
  }

  factory CashMemoItemModel.fromEntity(CashMemoItem item, String cashMemoId) {
    return CashMemoItemModel(
      id: item.id,
      cashMemoId: cashMemoId,
      productId: item.productId,
      productName: item.productName,
      quantity: item.quantity,
      unit: item.unit,
      price: item.price,
      total: item.total,
    );
  }
}
