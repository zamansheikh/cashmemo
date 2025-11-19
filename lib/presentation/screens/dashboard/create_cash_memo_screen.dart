import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/services/pdf_service.dart';
import '../../../domain/entities/cash_memo.dart';
import '../../../domain/entities/cash_memo_item.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/customer.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_state.dart';
import '../../bloc/customer/customer_bloc.dart';
import '../../bloc/customer/customer_state.dart';
import '../../bloc/cash_memo/cash_memo_bloc.dart';
import '../../bloc/cash_memo/cash_memo_event.dart';
import '../../bloc/cash_memo/cash_memo_state.dart';
import '../../bloc/shop_settings/shop_settings_bloc.dart';
import '../../bloc/shop_settings/shop_settings_state.dart';

class CreateCashMemoScreen extends StatefulWidget {
  const CreateCashMemoScreen({super.key});

  @override
  State<CreateCashMemoScreen> createState() => _CreateCashMemoScreenState();
}

class _CreateCashMemoScreenState extends State<CreateCashMemoScreen> {
  final List<CashMemoItem> _items = [];
  Customer? _selectedCustomer;
  double _discount = 0;
  double _tax = 0;
  String? _memoNumber;
  late final CashMemoBloc _cashMemoBloc;

  @override
  void initState() {
    super.initState();
    _cashMemoBloc = context.read<CashMemoBloc>();
    _cashMemoBloc.add(GenerateMemoNumber());
  }

  @override
  void dispose() {
    // Reload cash memos when leaving the screen to restore proper state
    _cashMemoBloc.add(LoadCashMemos());
    super.dispose();
  }

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.total);

  double get _total => _subtotal - _discount + _tax;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Cash Memo')),
      body: BlocListener<CashMemoBloc, CashMemoState>(
        listener: (context, state) {
          if (state is MemoNumberGenerated) {
            setState(() => _memoNumber = state.memoNumber);
          } else if (state is CashMemoOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          }
        },
        child: Padding(
          padding: Responsive.padding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Memo Number and Date
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Memo #${_memoNumber ?? "..."}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(DateFormat('dd/MM/yyyy').format(DateTime.now())),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Customer Selection
              _buildCustomerSelection(),
              const SizedBox(height: 16),

              // Add Item Button
              ElevatedButton.icon(
                onPressed: _showAddItemDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              ),
              const SizedBox(height: 16),

              // Items List
              Expanded(
                child: _items.isEmpty
                    ? const Center(child: Text('No items added'))
                    : ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Card(
                            child: ListTile(
                              title: Text(item.productName),
                              subtitle: Text(
                                '${item.quantity} ${item.unit} × ৳${item.price.toStringAsFixed(2)}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '৳${item.total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() => _items.removeAt(index));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Totals
              Card(
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTotalRow('Subtotal', _subtotal),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Discount',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(
                                  () => _discount = double.tryParse(value) ?? 0,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Tax',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(
                                  () => _tax = double.tryParse(value) ?? 0,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildTotalRow('Total', _total, isBold: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _items.isEmpty ? null : _saveCashMemo,
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _items.isEmpty ? null : _saveAndPrint,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                      ),
                      child: const Text('Save & Print'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerSelection() {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        if (state is CustomerLoaded) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer (Optional)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<Customer?>(
                    isExpanded: true,
                    value: _selectedCustomer,
                    hint: const Text('Select Customer'),
                    items: [
                      const DropdownMenuItem<Customer?>(
                        value: null,
                        child: Text('Walk-in Customer'),
                      ),
                      ...state.customers.map((Customer customer) {
                        return DropdownMenuItem<Customer?>(
                          value: customer,
                          child: Text(customer.name),
                        );
                      }),
                    ],
                    onChanged: (customer) {
                      setState(() => _selectedCustomer = customer);
                    },
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 16,
            ),
          ),
          Text(
            '৳${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    Product? selectedProduct;
    final quantityController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Item'),
        content: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoaded) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Product>(
                    decoration: const InputDecoration(labelText: 'Product'),
                    items: state.products.map((Product product) {
                      return DropdownMenuItem<Product>(
                        value: product,
                        child: Text(product.name),
                      );
                    }).toList(),
                    onChanged: (product) => selectedProduct = product,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              );
            }
            return const CircularProgressIndicator();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedProduct != null) {
                final quantity = double.tryParse(quantityController.text) ?? 1;
                final item = CashMemoItem(
                  id: const Uuid().v4(),
                  productId: selectedProduct!.id,
                  productName: selectedProduct!.name,
                  quantity: quantity,
                  unit: selectedProduct!.unit,
                  price: selectedProduct!.price,
                  total: quantity * selectedProduct!.price,
                );
                setState(() => _items.add(item));
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _saveCashMemo() {
    if (_memoNumber == null) return;

    final cashMemo = CashMemo(
      id: const Uuid().v4(),
      memoNumber: _memoNumber!,
      date: DateTime.now(),
      customerId: _selectedCustomer?.id,
      customerName: _selectedCustomer?.name,
      customerPhone: _selectedCustomer?.phone,
      customerAddress: _selectedCustomer?.address,
      items: _items,
      subtotal: _subtotal,
      discount: _discount,
      tax: _tax,
      total: _total,
      createdAt: DateTime.now(),
    );

    context.read<CashMemoBloc>().add(AddCashMemo(cashMemo));
  }

  void _saveAndPrint() async {
    if (_memoNumber == null) return;

    final cashMemo = CashMemo(
      id: const Uuid().v4(),
      memoNumber: _memoNumber!,
      date: DateTime.now(),
      customerId: _selectedCustomer?.id,
      customerName: _selectedCustomer?.name,
      customerPhone: _selectedCustomer?.phone,
      customerAddress: _selectedCustomer?.address,
      items: _items,
      subtotal: _subtotal,
      discount: _discount,
      tax: _tax,
      total: _total,
      createdAt: DateTime.now(),
    );

    context.read<CashMemoBloc>().add(AddCashMemo(cashMemo));

    final settingsState = context.read<ShopSettingsBloc>().state;
    if (settingsState is ShopSettingsLoaded) {
      await PdfService.generateAndPrintCashMemo(
        cashMemo,
        settingsState.settings,
      );
    } else {
      //Show error if shop settings not loaded
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Shop settings not configured. Open Settings to configure.',
          ),
        ),
      );
    }
  }
}
