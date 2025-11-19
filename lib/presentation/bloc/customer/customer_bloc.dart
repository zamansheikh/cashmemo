import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/customer_repository.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository customerRepository;

  CustomerBloc(this.customerRepository) : super(CustomerInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<AddCustomer>(_onAddCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);
    on<SearchCustomers>(_onSearchCustomers);
  }

  Future<void> _onLoadCustomers(
    LoadCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    try {
      final customers = await customerRepository.getAllCustomers();
      emit(CustomerLoaded(customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onAddCustomer(
    AddCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      await customerRepository.addCustomer(event.customer);
      emit(const CustomerOperationSuccess('Customer added successfully'));
      add(LoadCustomers());
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onUpdateCustomer(
    UpdateCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      await customerRepository.updateCustomer(event.customer);
      emit(const CustomerOperationSuccess('Customer updated successfully'));
      add(LoadCustomers());
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      await customerRepository.deleteCustomer(event.id);
      emit(const CustomerOperationSuccess('Customer deleted successfully'));
      add(LoadCustomers());
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onSearchCustomers(
    SearchCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    try {
      if (event.query.isEmpty) {
        final customers = await customerRepository.getAllCustomers();
        emit(CustomerLoaded(customers));
      } else {
        final customers = await customerRepository.searchCustomers(event.query);
        emit(CustomerLoaded(customers));
      }
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }
}
