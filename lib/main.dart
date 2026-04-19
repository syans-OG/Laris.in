import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/di/providers.dart';
import 'shared/presentation/layouts/master_layout.dart';
import 'features/transactions/domain/entities/transaction_entity.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

// Define the historyProvider outside of main, as a global Riverpod provider
final historyProvider = FutureProvider<List<TransactionEntity>>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  // TransactionRepository getTransactions method currently doesn't take parameters
  return repo.getTransactions();
});

void main() {
  runApp(
    // Wrapping the entire app in ProviderScope so Riverpod works everywhere
    const ProviderScope(
      child: KasirKuProApp(),
    ),
  );
}

class KasirKuProApp extends StatelessWidget {
  const KasirKuProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Laris.in',
      theme: AppTheme.darkTheme, // Using MVP Design Tokens
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(loginViewModelProvider);

    if (viewModel.isSuccess) {
      return const MasterLayout();
    }

    return const LoginScreen();
  }
}
