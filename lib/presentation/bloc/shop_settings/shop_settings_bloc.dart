import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/shop_settings_repository.dart';
import 'shop_settings_event.dart';
import 'shop_settings_state.dart';

class ShopSettingsBloc extends Bloc<ShopSettingsEvent, ShopSettingsState> {
  final ShopSettingsRepository shopSettingsRepository;

  ShopSettingsBloc(this.shopSettingsRepository) : super(ShopSettingsInitial()) {
    on<LoadShopSettings>(_onLoadShopSettings);
    on<SaveShopSettings>(_onSaveShopSettings);
  }

  Future<void> _onLoadShopSettings(
    LoadShopSettings event,
    Emitter<ShopSettingsState> emit,
  ) async {
    emit(ShopSettingsLoading());
    try {
      final settings = await shopSettingsRepository.getShopSettings();
      if (settings != null) {
        emit(ShopSettingsLoaded(settings));
      } else {
        emit(const ShopSettingsError('No settings found'));
      }
    } catch (e) {
      emit(ShopSettingsError(e.toString()));
    }
  }

  Future<void> _onSaveShopSettings(
    SaveShopSettings event,
    Emitter<ShopSettingsState> emit,
  ) async {
    try {
      await shopSettingsRepository.saveShopSettings(event.settings);
      emit(const ShopSettingsSaved('Settings saved successfully'));
      add(LoadShopSettings());
    } catch (e) {
      emit(ShopSettingsError(e.toString()));
    }
  }
}
