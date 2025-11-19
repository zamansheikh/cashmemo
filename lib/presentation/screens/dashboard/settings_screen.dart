import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
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
  late TextEditingController _taglineController;
  late TextEditingController _addressController;
  late TextEditingController _websiteController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _gstController;
  late TextEditingController _termsController;
  late TextEditingController _invoiceByNameController;
  late TextEditingController _invoiceByRoleController;
  late TextEditingController _invoiceByContactController;

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController();
    _taglineController = TextEditingController();
    _addressController = TextEditingController();
    _websiteController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _gstController = TextEditingController();
    _termsController = TextEditingController();
    _invoiceByNameController = TextEditingController();
    _invoiceByRoleController = TextEditingController();
    _invoiceByContactController = TextEditingController();
    context.read<ShopSettingsBloc>().add(LoadShopSettings());
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _taglineController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _gstController.dispose();
    _termsController.dispose();
    _invoiceByNameController.dispose();
    _invoiceByRoleController.dispose();
    _invoiceByContactController.dispose();
    super.dispose();
  }

  void _populateFields(ShopSettings settings) {
    _shopNameController.text = settings.shopName;
    _taglineController.text = settings.tagline ?? '';
    _addressController.text = settings.address ?? '';
    _websiteController.text = settings.website ?? '';
    _phoneController.text = settings.phone ?? '';
    _emailController.text = settings.email ?? '';
    _gstController.text = settings.gstNumber ?? '';
    _termsController.text = settings.terms ?? '';
    _invoiceByNameController.text = settings.invoiceByName ?? '';
    _invoiceByRoleController.text = settings.invoiceByRole ?? '';
    _invoiceByContactController.text = settings.invoiceByContact ?? '';
  }

  void _clearFields() {
    _shopNameController.clear();
    _taglineController.clear();
    _addressController.clear();
    _websiteController.clear();
    _phoneController.clear();
    _emailController.clear();
    _gstController.clear();
    _termsController.clear();
    _invoiceByNameController.clear();
    _invoiceByRoleController.clear();
    _invoiceByContactController.clear();
  }

  ShopSettings _buildSettingsFromControllers(String id) {
    return ShopSettings(
      id: id,
      shopName: _shopNameController.text,
      tagline: _taglineController.text,
      address: _addressController.text,
      website: _websiteController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      gstNumber: _gstController.text,
      terms: _termsController.text,
      invoiceByName: _invoiceByNameController.text,
      invoiceByRole: _invoiceByRoleController.text,
      invoiceByContact: _invoiceByContactController.text,
    );
  }

  Widget _buildSettingsForm(ShopSettings? existingSettings) {
    final isNewSettings = existingSettings == null;

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
            controller: _taglineController,
            decoration: const InputDecoration(labelText: 'Tagline'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Address'),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _websiteController,
            decoration: const InputDecoration(labelText: 'Website'),
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
          const Text(
            'Terms & Conditions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _termsController,
            decoration: const InputDecoration(
              labelText: 'Terms & Conditions',
              hintText: 'Enter your terms and conditions',
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 32),
          const Text(
            'Invoice By (Signature)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _invoiceByNameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _invoiceByRoleController,
            decoration: const InputDecoration(labelText: 'Role/Position'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _invoiceByContactController,
            decoration: const InputDecoration(labelText: 'Contact Information'),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final settings = _buildSettingsFromControllers(
                  isNewSettings ? const Uuid().v4() : existingSettings.id,
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
              _populateFields(state.settings);
            }
            return _buildSettingsForm(state.settings);
          } else if (state is ShopSettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (_shopNameController.text.isEmpty) {
              _clearFields();
            }
            return _buildSettingsForm(null);
          }
        },
      ),
    );
  }
}
