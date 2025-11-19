import 'package:equatable/equatable.dart';
import '../../../domain/entities/shop_settings.dart';

abstract class ShopSettingsState extends Equatable {
  const ShopSettingsState();

  @override
  List<Object?> get props => [];
}

class ShopSettingsInitial extends ShopSettingsState {}

class ShopSettingsLoading extends ShopSettingsState {}

class ShopSettingsLoaded extends ShopSettingsState {
  final ShopSettings settings;

  const ShopSettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

class ShopSettingsError extends ShopSettingsState {
  final String message;

  const ShopSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ShopSettingsSaved extends ShopSettingsState {
  final String message;

  const ShopSettingsSaved(this.message);

  @override
  List<Object?> get props => [message];
}
