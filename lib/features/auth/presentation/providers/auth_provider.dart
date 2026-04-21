import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cashier_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

import '../../../../core/di/providers.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final db = ref.read(databaseProvider);
  return AuthRepositoryImpl(db);
});

final sessionProvider = StateProvider<CashierEntity?>((ref) => null);

final loginViewModelProvider = ChangeNotifierProvider.autoDispose<LoginViewModel>((ref) {
  return LoginViewModel(ref.read(authRepositoryProvider), ref);
});

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final Ref _ref;

  LoginViewModel(this._repository, this._ref) {
    _loadCashiers();
  }

  List<CashierEntity> activeCashiers = [];
  CashierEntity? selectedCashier;
  String currentPin = '';
  bool isLoading = false;
  String? errorMessage;
  bool isSuccess = false;

  Future<void> _loadCashiers() async {
    isLoading = true;
    notifyListeners();

    try {
      activeCashiers = await _repository.getActiveCashiers();
      if (activeCashiers.isNotEmpty) {
        selectedCashier = activeCashiers.first;
      }
    } catch (e) {
      errorMessage = 'Gagal memuat daftar kasir';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectCashier(CashierEntity? cashier) {
    if (isLoading) return;
    selectedCashier = cashier;
    currentPin = '';
    errorMessage = null;
    notifyListeners();
  }

  void addPinDigit(String digit) {
    if (isLoading || selectedCashier == null) return;
    if (currentPin.length < 6) {
      currentPin += digit;
      errorMessage = null;
      notifyListeners();

      if (currentPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void removePinDigit() {
    if (isLoading) return;
    if (currentPin.isNotEmpty) {
      currentPin = currentPin.substring(0, currentPin.length - 1);
      errorMessage = null;
      notifyListeners();
    }
  }

  void clearPin() {
    currentPin = '';
    notifyListeners();
  }

  Future<void> _verifyPin() async {
    if (selectedCashier == null) return;
    
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final isValid = await _repository.verifyPin(selectedCashier!.id, currentPin);
      if (isValid) {
        isSuccess = true;
        _ref.read(sessionProvider.notifier).state = selectedCashier;
      } else {
        errorMessage = 'PIN Salah!';
        currentPin = ''; // Reset PIN on error
      }
    } catch (e) {
      errorMessage = 'Terjadi kesalahan sistem';
      currentPin = '';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// ── Cashier Management ───────────────────────────────────────────────────────

final cashierListProvider = FutureProvider.autoDispose<List<CashierEntity>>((ref) {
  return ref.watch(authRepositoryProvider).getActiveCashiers();
});

final cashierManagementProvider = ChangeNotifierProvider.autoDispose<CashierManagementViewModel>((ref) {
  return CashierManagementViewModel(ref.read(authRepositoryProvider), ref);
});

class CashierManagementViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final Ref _ref;

  CashierManagementViewModel(this._repository, this._ref);

  bool isLoading = false;

  Future<void> addCashier(String name, String pin, String role) async {
    isLoading = true;
    notifyListeners();
    try {
      await _repository.addUser(name, pin, role);
      _ref.invalidate(cashierListProvider);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeCashier(int id) async {
    isLoading = true;
    notifyListeners();
    try {
      await _repository.deleteUser(id);
      _ref.invalidate(cashierListProvider);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePin(int id, String newPin) async {
    await _repository.updatePin(id, newPin);
    if (_ref.read(sessionProvider)?.id == id) {
      final user = _ref.read(sessionProvider);
      if (user != null) {
        _ref.read(sessionProvider.notifier).state = user.copyWith(pin: newPin);
      }
    }
  }
}
