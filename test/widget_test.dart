// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kasir_pro/main.dart';
import 'package:kasir_pro/features/auth/domain/repositories/auth_repository.dart';
import 'package:kasir_pro/features/auth/presentation/providers/auth_provider.dart';
import 'package:kasir_pro/features/auth/domain/entities/cashier_entity.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<List<CashierEntity>> getActiveCashiers() async => [];
  
  @override
  Future<bool> verifyPin(int cashierId, String pin) async => true;
  
  @override
  Future<CashierEntity?> getCurrentUser() async => null;
  
  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app with a mocked repository to avoid real DB/async issues.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
        child: const LarisInApp(),
      ),
    );
    
    // Initial pump to trigger the first frame.
    await tester.pump();
    
    // We expect "Laris.in" to be visible immediately as it's a constant title.
    expect(find.text('Laris.in'), findsOneWidget);
    expect(find.text('Selamat datang, silakan login'), findsOneWidget);
  });
}
