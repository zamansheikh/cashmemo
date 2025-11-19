import 'package:equatable/equatable.dart';
import 'cash_memo_item.dart';

class CashMemo extends Equatable {
  final String id;
  final String memoNumber;
  final DateTime date;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final List<CashMemoItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String? notes;
  final DateTime createdAt;

  const CashMemo({
    required this.id,
    required this.memoNumber,
    required this.date,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    required this.items,
    required this.subtotal,
    this.discount = 0,
    this.tax = 0,
    required this.total,
    this.notes,
    required this.createdAt,
  });

  CashMemo copyWith({
    String? id,
    String? memoNumber,
    DateTime? date,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    List<CashMemoItem>? items,
    double? subtotal,
    double? discount,
    double? tax,
    double? total,
    String? notes,
    DateTime? createdAt,
  }) {
    return CashMemo(
      id: id ?? this.id,
      memoNumber: memoNumber ?? this.memoNumber,
      date: date ?? this.date,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    memoNumber,
    date,
    customerId,
    customerName,
    customerPhone,
    customerAddress,
    items,
    subtotal,
    discount,
    tax,
    total,
    notes,
    createdAt,
  ];
}
