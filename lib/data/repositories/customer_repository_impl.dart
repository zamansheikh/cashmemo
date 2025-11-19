import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_local_data_source.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerLocalDataSource localDataSource;

  CustomerRepositoryImpl(this.localDataSource);

  @override
  Future<List<Customer>> getAllCustomers() async {
    return await localDataSource.getAllCustomers();
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    return await localDataSource.getCustomerById(id);
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    final customerModel = CustomerModel.fromEntity(customer);
    await localDataSource.insertCustomer(customerModel);
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    final customerModel = CustomerModel.fromEntity(customer);
    await localDataSource.updateCustomer(customerModel);
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await localDataSource.deleteCustomer(id);
  }

  @override
  Future<List<Customer>> searchCustomers(String query) async {
    return await localDataSource.searchCustomers(query);
  }
}
