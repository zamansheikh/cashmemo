import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../../bloc/customer/customer_bloc.dart';
import '../../bloc/customer/customer_event.dart';
import '../../bloc/customer/customer_state.dart';
import '../../bloc/cash_memo/cash_memo_bloc.dart';
import '../../bloc/cash_memo/cash_memo_event.dart';
import '../../bloc/cash_memo/cash_memo_state.dart';
import 'products_screen.dart';
import 'customers_screen.dart';
import 'cash_memos_screen.dart';
import 'create_cash_memo_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<ProductBloc>().add(LoadProducts());
    context.read<CustomerBloc>().add(LoadCustomers());
    context.read<CashMemoBloc>().add(LoadCashMemos());
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final screens = [
      _buildHomeTab(),
      const ProductsScreen(),
      const CustomersScreen(),
      const CashMemosScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: Row(
        children: [
          if (!isMobile)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              labelType: NavigationRailLabelType.all,
              backgroundColor: AppColors.surface,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.inventory_outlined),
                  selectedIcon: Icon(Icons.inventory),
                  label: Text('Products'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: Text('Customers'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: Text('Cash Memos'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),
          Expanded(child: screens[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inventory_outlined),
                  selectedIcon: Icon(Icons.inventory),
                  label: 'Products',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: 'Customers',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: 'Memos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            )
          : null,
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateCashMemoScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('New Cash Memo'),
            )
          : null,
    );
  }

  Widget _buildHomeTab() {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: Responsive.padding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: Responsive.isMobile(context)
                    ? 2
                    : Responsive.isTablet(context)
                    ? 3
                    : 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    'Products',
                    Icons.inventory,
                    AppColors.primary,
                    ProductBloc,
                  ),
                  _buildDashboardCard(
                    'Customers',
                    Icons.people,
                    AppColors.secondary,
                    CustomerBloc,
                  ),
                  _buildDashboardCard(
                    'Cash Memos',
                    Icons.receipt_long,
                    AppColors.accent,
                    CashMemoBloc,
                  ),
                  Card(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateCashMemoScreen(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 48,
                              color: AppColors.success,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Create New\nCash Memo',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    String title,
    IconData icon,
    Color color,
    Type blocType,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (blocType == ProductBloc)
              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoaded) {
                    return Text(
                      '${state.products.length}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: color, fontWeight: FontWeight.bold),
                    );
                  }
                  return const CircularProgressIndicator();
                },
              )
            else if (blocType == CustomerBloc)
              BlocBuilder<CustomerBloc, CustomerState>(
                builder: (context, state) {
                  if (state is CustomerLoaded) {
                    return Text(
                      '${state.customers.length}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: color, fontWeight: FontWeight.bold),
                    );
                  }
                  return const CircularProgressIndicator();
                },
              )
            else if (blocType == CashMemoBloc)
              BlocBuilder<CashMemoBloc, CashMemoState>(
                builder: (context, state) {
                  if (state is CashMemoLoaded) {
                    return Text(
                      '${state.cashMemos.length}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: color, fontWeight: FontWeight.bold),
                    );
                  } else if (state is MemoNumberGenerated) {
                    // Show last known count while generating memo number
                    return Text(
                      '0', // Default count during generation
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: color, fontWeight: FontWeight.bold),
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
          ],
        ),
      ),
    );
  }
}
