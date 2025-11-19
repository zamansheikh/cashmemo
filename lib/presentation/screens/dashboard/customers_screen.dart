import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/entities/customer.dart';
import '../../bloc/customer/customer_bloc.dart';
import '../../bloc/customer/customer_event.dart';
import '../../bloc/customer/customer_state.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCustomerDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: Responsive.padding(context),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  context.read<CustomerBloc>().add(LoadCustomers());
                } else {
                  context.read<CustomerBloc>().add(SearchCustomers(value));
                }
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CustomerLoaded) {
                  if (state.customers.isEmpty) {
                    return const Center(child: Text('No customers found'));
                  }
                  return ListView.builder(
                    padding: Responsive.padding(context),
                    itemCount: state.customers.length,
                    itemBuilder: (context, index) {
                      final customer = state.customers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.secondary,
                            child: Text(
                              customer.name[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(customer.name),
                          subtitle: Text(customer.phone ?? 'No phone'),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showCustomerDialog(
                                  context,
                                  customer: customer,
                                );
                              } else if (value == 'delete') {
                                context.read<CustomerBloc>().add(
                                  DeleteCustomer(customer.id),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomerDialog(BuildContext context, {Customer? customer}) {
    final nameController = TextEditingController(text: customer?.name ?? '');
    final phoneController = TextEditingController(text: customer?.phone ?? '');
    final emailController = TextEditingController(text: customer?.email ?? '');
    final addressController = TextEditingController(
      text: customer?.address ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(customer == null ? 'Add Customer' : 'Edit Customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newCustomer = Customer(
                id: customer?.id ?? const Uuid().v4(),
                name: nameController.text,
                phone: phoneController.text,
                email: emailController.text,
                address: addressController.text,
                createdAt: customer?.createdAt ?? DateTime.now(),
              );

              if (customer == null) {
                context.read<CustomerBloc>().add(AddCustomer(newCustomer));
              } else {
                context.read<CustomerBloc>().add(UpdateCustomer(newCustomer));
              }
              Navigator.pop(dialogContext);
            },
            child: Text(customer == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }
}
