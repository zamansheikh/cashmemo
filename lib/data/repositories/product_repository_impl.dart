import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl(this.localDataSource);

  @override
  Future<List<Product>> getAllProducts() async {
    return await localDataSource.getAllProducts();
  }

  @override
  Future<Product?> getProductById(String id) async {
    return await localDataSource.getProductById(id);
  }

  @override
  Future<void> addProduct(Product product) async {
    final productModel = ProductModel.fromEntity(product);
    await localDataSource.insertProduct(productModel);
  }

  @override
  Future<void> updateProduct(Product product) async {
    final productModel = ProductModel.fromEntity(product);
    await localDataSource.updateProduct(productModel);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await localDataSource.deleteProduct(id);
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    return await localDataSource.searchProducts(query);
  }
}
