import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/entities/shop_settings.dart';
import '../../bloc/shop_settings/shop_settings_bloc.dart';
import '../../bloc/shop_settings/shop_settings_event.dart';
import '../../bloc/shop_settings/shop_settings_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _shopNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _gstController;

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _gstController = TextEditingController();
    context.read<ShopSettingsBloc>().add(LoadShopSettings());
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocConsumer<ShopSettingsBloc, ShopSettingsState>(
        listener: (context, state) {
          if (state is ShopSettingsSaved) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ShopSettingsLoaded) {
            if (_shopNameController.text.isEmpty) {
              _shopNameController.text = state.settings.shopName;
              _addressController.text = state.settings.address ?? '';
              _phoneController.text = state.settings.phone ?? '';
              _emailController.text = state.settings.email ?? '';
              _gstController.text = state.settings.gstNumber ?? '';
            }

            return SingleChildScrollView(
              padding: Responsive.padding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Shop Information',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _shopNameController,
                    decoration: const InputDecoration(labelText: 'Shop Name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _gstController,
                    decoration: const InputDecoration(labelText: 'GST Number'),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final settings = ShopSettings(
                          id: state.settings.id,
                          shopName: _shopNameController.text,
                          address: _addressController.text,
                          phone: _phoneController.text,
                          email: _emailController.text,
                          gstNumber: _gstController.text,
                        );
                        context.read<ShopSettingsBloc>().add(
                          SaveShopSettings(settings),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Save Settings'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
