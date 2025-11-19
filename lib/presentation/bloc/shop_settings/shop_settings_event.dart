import 'package:equatable/equatable.dart';
import '../../../domain/entities/shop_settings.dart';

abstract class ShopSettingsEvent extends Equatable {
  const ShopSettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadShopSettings extends ShopSettingsEvent {}

class SaveShopSettings extends ShopSettingsEvent {
  final ShopSettings settings;

  const SaveShopSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}
