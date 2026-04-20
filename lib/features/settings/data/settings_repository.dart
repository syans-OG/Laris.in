import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsRepository {
  static const _keyTaxEnabled = 'tax_enabled';
  static const _keyTaxRate = 'tax_rate';
  static const _keyDiscountEnabled = 'discount_enabled';

  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  // ── Tax ──────────────────────────────────────────────
  bool get taxEnabled => _prefs.getBool(_keyTaxEnabled) ?? false;
  double get taxRate => _prefs.getDouble(_keyTaxRate) ?? 11.0;

  Future<void> setTaxEnabled(bool value) async =>
      _prefs.setBool(_keyTaxEnabled, value);

  Future<void> setTaxRate(double value) async =>
      _prefs.setDouble(_keyTaxRate, value);

  // ── Discount ─────────────────────────────────────────
  bool get discountEnabled => _prefs.getBool(_keyDiscountEnabled) ?? false;

  Future<void> setDiscountEnabled(bool value) async =>
      _prefs.setBool(_keyDiscountEnabled, value);
}

// ── Providers ─────────────────────────────────────────────────────────────────

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsRepository(prefs);
});

// Reactive providers agar UI rebuild otomatis saat setting berubah
final taxEnabledProvider = StateProvider<bool>((ref) {
  return ref.watch(settingsRepositoryProvider).taxEnabled;
});

final taxRateProvider = StateProvider<double>((ref) {
  return ref.watch(settingsRepositoryProvider).taxRate;
});

final discountEnabledProvider = StateProvider<bool>((ref) {
  return ref.watch(settingsRepositoryProvider).discountEnabled;
});
