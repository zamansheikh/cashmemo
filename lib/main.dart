import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/database_helper.dart';
import 'data/datasources/product_local_data_source.dart';
import 'data/datasources/customer_local_data_source.dart';
import 'data/datasources/cash_memo_local_data_source.dart';
import 'data/datasources/shop_settings_local_data_source.dart';
import 'data/repositories/product_repository_impl.dart';
import 'data/repositories/customer_repository_impl.dart';
import 'data/repositories/cash_memo_repository_impl.dart';
import 'data/repositories/shop_settings_repository_impl.dart';
import 'presentation/bloc/product/product_bloc.dart';
import 'presentation/bloc/customer/customer_bloc.dart';
import 'presentation/bloc/cash_memo/cash_memo_bloc.dart';
import 'presentation/bloc/shop_settings/shop_settings_bloc.dart';
import 'presentation/bloc/shop_settings/shop_settings_event.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final databaseHelper = DatabaseHelper();
  await databaseHelper.database;

  // Initialize data sources
  final productDataSource = ProductLocalDataSource(databaseHelper);
  final customerDataSource = CustomerLocalDataSource(databaseHelper);
  final cashMemoDataSource = CashMemoLocalDataSource(databaseHelper);
  final shopSettingsDataSource = ShopSettingsLocalDataSource(databaseHelper);

  // Initialize repositories
  final productRepository = ProductRepositoryImpl(productDataSource);
  final customerRepository = CustomerRepositoryImpl(customerDataSource);
  final cashMemoRepository = CashMemoRepositoryImpl(cashMemoDataSource);
  final shopSettingsRepository = ShopSettingsRepositoryImpl(
    shopSettingsDataSource,
  );

  runApp(
    MyApp(
      productRepository: productRepository,
      customerRepository: customerRepository,
      cashMemoRepository: cashMemoRepository,
      shopSettingsRepository: shopSettingsRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  final ProductRepositoryImpl productRepository;
  final CustomerRepositoryImpl customerRepository;
  final CashMemoRepositoryImpl cashMemoRepository;
  final ShopSettingsRepositoryImpl shopSettingsRepository;

  const MyApp({
    super.key,
    required this.productRepository,
    required this.customerRepository,
    required this.cashMemoRepository,
    required this.shopSettingsRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ProductBloc(productRepository)),
        BlocProvider(create: (context) => CustomerBloc(customerRepository)),
        BlocProvider(create: (context) => CashMemoBloc(cashMemoRepository)),
        BlocProvider(
          create: (context) =>
              ShopSettingsBloc(shopSettingsRepository)..add(LoadShopSettings()),
        ),
      ],
      child: MaterialApp(
        title: 'CashMemo - Grocery Shop',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const DashboardScreen(),
      ),
    );
  }
}
