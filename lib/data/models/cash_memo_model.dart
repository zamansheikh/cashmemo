import '../../domain/entities/cash_memo.dart';
import 'cash_memo_item_model.dart';

class CashMemoModel extends CashMemo {
  const CashMemoModel({
    required super.id,
    required super.memoNumber,
    required super.date,
    super.customerId,
    super.customerName,
    super.customerPhone,
    super.customerAddress,
    required super.items,
    required super.subtotal,
    super.discount,
    super.tax,
    required super.total,
    super.notes,
    required super.createdAt,
  });

  factory CashMemoModel.fromMap(
    Map<String, dynamic> map,
    List<CashMemoItemModel> items,
  ) {
    return CashMemoModel(
      id: map['id'] as String,
      memoNumber: map['memo_number'] as String,
      date: DateTime.parse(map['date'] as String),
      customerId: map['customer_id'] as String?,
      customerName: map['customer_name'] as String?,
      customerPhone: map['customer_phone'] as String?,
      customerAddress: map['customer_address'] as String?,
      items: items,
      subtotal: map['subtotal'] as double,
      discount: map['discount'] as double,
      tax: map['tax'] as double,
      total: map['total'] as double,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memo_number': memoNumber,
      'date': date.toIso8601String(),
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_address': customerAddress,
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total': total,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CashMemoModel.fromEntity(CashMemo cashMemo) {
    return CashMemoModel(
      id: cashMemo.id,
      memoNumber: cashMemo.memoNumber,
      date: cashMemo.date,
      customerId: cashMemo.customerId,
      customerName: cashMemo.customerName,
      customerPhone: cashMemo.customerPhone,
      customerAddress: cashMemo.customerAddress,
      items: cashMemo.items,
      subtotal: cashMemo.subtotal,
      discount: cashMemo.discount,
      tax: cashMemo.tax,
      total: cashMemo.total,
      notes: cashMemo.notes,
      createdAt: cashMemo.createdAt,
    );
  }
}
