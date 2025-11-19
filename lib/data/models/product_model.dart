import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    super.description,
    required super.price,
    required super.unit,
    required super.stockQuantity,
    super.barcode,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      price: map['price'] as double,
      unit: map['unit'] as String,
      stockQuantity: map['stock_quantity'] as int,
      barcode: map['barcode'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'stock_quantity': stockQuantity,
      'barcode': barcode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      unit: product.unit,
      stockQuantity: product.stockQuantity,
      barcode: product.barcode,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }
}
