import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ManageCashiersScreen extends ConsumerWidget {
  const ManageCashiersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashierList = ref.watch(cashierListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Kelola Kasir'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: cashierList.when(
        data: (cashiers) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: cashiers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final cashier = cashiers[index];
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Text(cashier.name[0].toUpperCase(), 
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
                title: Text(cashier.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(cashier.role.toUpperCase(), 
                  style: const TextStyle(color: AppColors.textMutedDark, fontSize: 12)),
                trailing: cashier.role == 'admin' 
                  ? const Icon(Icons.security, color: AppColors.primary, size: 18)
                  : IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () => _confirmDelete(context, ref, cashier.id, cashier.name),
                    ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e', style: const TextStyle(color: AppColors.error))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCashier(context, ref),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Kasir?'),
        content: Text('Apakah Anda yakin ingin menghapus akses untuk $name?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              ref.read(cashierManagementProvider).removeCashier(id);
              Navigator.pop(context);
            }, 
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showAddCashier(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final pinController = TextEditingController();
    String role = 'kasir';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Kasir'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pinController,
                decoration: const InputDecoration(labelText: 'PIN (4 digit)', hintText: '1234'),
                keyboardType: TextInputType.number,
                maxLength: 4,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: role,
                decoration: const InputDecoration(labelText: 'Hak Akses'),
                items: const [
                  DropdownMenuItem(value: 'kasir', child: Text('Kasir')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (val) => setState(() => role = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            FilledButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && pinController.text.length == 4) {
                  ref.read(cashierManagementProvider).addCashier(
                    nameController.text, 
                    pinController.text, 
                    role,
                  );
                  Navigator.pop(context);
                }
              }, 
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
