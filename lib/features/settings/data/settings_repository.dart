import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsRepository {
  static const _keyTaxEnabled = 'tax_enabled';
  static const _keyTaxRate = 'tax_rate';
  static const _keyDiscountEnabled = 'discount_enabled';

  // Store Identity
  static const _keyStoreName = 'store_name';
  static const _keyStoreAddress = 'store_address';
  static const _keyStorePhone = 'store_phone';
  static const _keyStoreFooter = 'store_footer';
  static const _keyLogoPath = 'logo_path';
  static const _keyPaperSize = 'paper_size';

  // Receipt Styles
  static const _keyShowStoreName = 'show_store_name';
  static const _keyShowAddress = 'show_address';
  static const _keyShowLogo = 'show_logo';

  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  // ── Tax & Discount ───────────────────────────────────
  bool get taxEnabled => _prefs.getBool(_keyTaxEnabled) ?? false;
  double get taxRate => _prefs.getDouble(_keyTaxRate) ?? 11.0;
  bool get discountEnabled => _prefs.getBool(_keyDiscountEnabled) ?? false;

  Future<void> setTaxEnabled(bool value) async => _prefs.setBool(_keyTaxEnabled, value);
  Future<void> setTaxRate(double value) async => _prefs.setDouble(_keyTaxRate, value);
  Future<void> setDiscountEnabled(bool value) async => _prefs.setBool(_keyDiscountEnabled, value);

  // ── Store Identity ──────────────────────────────────
  String get storeName => _prefs.getString(_keyStoreName) ?? 'Laris.in';
  String get storeAddress => _prefs.getString(_keyStoreAddress) ?? 'Alamat belum diatur';
  String get storePhone => _prefs.getString(_keyStorePhone) ?? '-';
  String get storeFooter => _prefs.getString(_keyStoreFooter) ?? 'Terima kasih sudah belanja!';
  String? get logoPath => _prefs.getString(_keyLogoPath);

  Future<void> setStoreName(String value) async => _prefs.setString(_keyStoreName, value);
  Future<void> setStoreAddress(String value) async => _prefs.setString(_keyStoreAddress, value);
  Future<void> setStorePhone(String value) async => _prefs.setString(_keyStorePhone, value);
  Future<void> setStoreFooter(String value) async => _prefs.setString(_keyStoreFooter, value);
  Future<void> setLogoPath(String? value) async {
    if (value == null) {
      await _prefs.remove(_keyLogoPath);
    } else {
      await _prefs.setString(_keyLogoPath, value);
    }
  }

  int get paperSize => _prefs.getInt(_keyPaperSize) ?? 58;
  Future<void> setPaperSize(int value) async => _prefs.setInt(_keyPaperSize, value);

  // ── Receipt Styles ─────────────────────────────────
  bool get showStoreName => _prefs.getBool(_keyShowStoreName) ?? true;
  bool get showAddress => _prefs.getBool(_keyShowAddress) ?? true;
  bool get showLogo => _prefs.getBool(_keyShowLogo) ?? true;

  Future<void> setShowStoreName(bool value) async => _prefs.setBool(_keyShowStoreName, value);
  Future<void> setShowAddress(bool value) async => _prefs.setBool(_keyShowAddress, value);
  Future<void> setShowLogo(bool value) async => _prefs.setBool(_keyShowLogo, value);
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

// Store Identity Providers
final storeNameProvider = StateProvider<String>((ref) {
  return ref.watch(settingsRepositoryProvider).storeName;
});

final storeAddressProvider = StateProvider<String>((ref) {
  return ref.watch(settingsRepositoryProvider).storeAddress;
});

final storePhoneProvider = StateProvider<String>((ref) {
  return ref.watch(settingsRepositoryProvider).storePhone;
});

final storeFooterProvider = StateProvider<String>((ref) {
  return ref.watch(settingsRepositoryProvider).storeFooter;
});

final logoPathProvider = StateProvider<String?>((ref) {
  return ref.watch(settingsRepositoryProvider).logoPath;
});

// Receipt Styles Providers
final showStoreNameProvider = StateProvider<bool>((ref) {
  return ref.watch(settingsRepositoryProvider).showStoreName;
});

final showAddressProvider = StateProvider<bool>((ref) {
  return ref.watch(settingsRepositoryProvider).showAddress;
});

final showLogoProvider = StateProvider<bool>((ref) {
  return ref.watch(settingsRepositoryProvider).showLogo;
});

final paperSizeProvider = StateProvider<int>((ref) {
  return ref.watch(settingsRepositoryProvider).paperSize;
});

