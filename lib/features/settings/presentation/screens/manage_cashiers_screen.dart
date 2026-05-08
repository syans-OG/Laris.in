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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Kelola Kasir',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            color: Color(0xFF191C1D),
          ),
        ),
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF191C1D)),
      ),
      body: cashierList.when(
        data: (cashiers) => ListView.separated(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          itemCount: cashiers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final cashier = cashiers[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDEEEF)),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.03),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE5F0EC),
                  child: Text(
                    cashier.name[0].toUpperCase(), 
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: Color(0xFF006948), 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  cashier.name, 
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: Color(0xFF191C1D), 
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  cashier.role.toUpperCase(), 
                  style: const TextStyle(
                    fontFamily: 'Space Mono',
                    color: Color(0xFF6D7A72), 
                    fontSize: 12,
                  ),
                ),
                trailing: cashier.role == 'admin' 
                  ? const Icon(Icons.security, color: Color(0xFF006948), size: 20)
                  : IconButton(
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFBA1A1A)),
                      onPressed: () => _confirmDelete(context, ref, cashier.id, cashier.name),
                    ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF006948))),
        error: (e, _) => Center(child: Text('Gagal memuat: $e', style: const TextStyle(color: Color(0xFFBA1A1A)))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCashier(context, ref),
        backgroundColor: const Color(0xFF006948),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Kasir?',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            color: Color(0xFFBA1A1A),
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus akses untuk $name?',
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            color: Color(0xFF3D4A42),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Batal', style: TextStyle(color: Color(0xFF6D7A72), fontWeight: FontWeight.bold)),
          ),
          FilledButton(
            onPressed: () {
              ref.read(cashierManagementProvider).removeCashier(id);
              Navigator.pop(context);
            }, 
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFBA1A1A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
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
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Tambah Kasir',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.bold,
              color: Color(0xFF191C1D),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  labelStyle: const TextStyle(color: Color(0xFF8A9A90)),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pinController,
                decoration: InputDecoration(
                  labelText: 'PIN (4 digit)',
                  labelStyle: const TextStyle(color: Color(0xFF8A9A90)),
                  hintText: '1234',
                  hintStyle: const TextStyle(color: Color(0xFFBCCAC0)),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: role,
                decoration: InputDecoration(
                  labelText: 'Hak Akses',
                  labelStyle: const TextStyle(color: Color(0xFF8A9A90)),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: const [
                  DropdownMenuItem(value: 'kasir', child: Text('Kasir', style: TextStyle(fontFamily: 'Plus Jakarta Sans'))),
                  DropdownMenuItem(value: 'admin', child: Text('Admin', style: TextStyle(fontFamily: 'Plus Jakarta Sans'))),
                ],
                onChanged: (val) => setState(() => role = val!),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Batal', style: TextStyle(color: Color(0xFF6D7A72), fontWeight: FontWeight.bold)),
            ),
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
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF006948),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
