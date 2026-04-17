import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/usecases/import_csv_usecase.dart';
import '../providers/product_provider.dart';

class ImportCsvBottomSheet extends ConsumerStatefulWidget {
  const ImportCsvBottomSheet({super.key});

  @override
  ConsumerState<ImportCsvBottomSheet> createState() => _ImportCsvBottomSheetState();
}

class _ImportCsvBottomSheetState extends ConsumerState<ImportCsvBottomSheet> {
  File? _selectedFile;
  int _estimatedLines = 0;
  bool _isLoading = false;
  ImportResult? _result;

  Future<void> _downloadTemplate() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/template_import_produk.csv');
      await file.writeAsString('barcode,nama_produk,kategori,harga_jual,harga_beli,stok,satuan\n');
      
      await Share.shareXFiles([XFile(file.path)], subject: 'Template Import Produk CSV');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat template: $e')),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final file = File(path);
        
        // Coba baca jumlah baris (estimasi)
        final isi = await file.readAsString();
        final baris = isi.split('\n').where((l) => l.trim().isNotEmpty).length;
        
        setState(() {
          _selectedFile = file;
          _estimatedLines = baris > 0 ? baris - 1 : 0; // Kurangi header
          _result = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih file: $e')),
        );
      }
    }
  }

  Future<void> _startImport() async {
    if (_selectedFile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ref.read(importCsvUseCaseProvider).execute(_selectedFile!.path);
      
      // Refresh list
      await ref.read(productsProvider.notifier).loadProducts(
        searchQuery: ref.read(productsQueryProvider),
        categoryId: ref.read(productsCategoryFilterProvider),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _result = result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error import: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1F26),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Import Produk via CSV',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Color(0xFFBACBBF)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_result != null) ...[
            // STATE RESULT
            _buildResultState(),
          ] else if (_isLoading) ...[
            // STATE LOADING
            const SizedBox(height: 32),
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF00E5A0)),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Mengimpor Data...',
                style: TextStyle(color: Color(0xFFBACBBF)),
              ),
            ),
            const SizedBox(height: 32),
          ] else ...[
            // STATE AWAL / PREVIEW
            OutlinedButton.icon(
              onPressed: _downloadTemplate,
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Download Template CSV'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF00E5A0),
                side: BorderSide(color: const Color(0xFF00E5A0).withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file_rounded, size: 18),
              label: Text(_selectedFile != null ? 'Ganti File CSV' : 'Pilih File CSV'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF33343B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            
            if (_selectedFile != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C0E14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3B4A41).withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.file_present_rounded, color: Color(0xFF00E5A0), size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedFile!.path.split(Platform.pathSeparator).last,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_estimatedLines baris data terdeteksi',
                      style: const TextStyle(color: Color(0xFF84958A), fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _estimatedLines > 0 ? _startImport : null,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5A0),
                  foregroundColor: const Color(0xFF006141),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('MULAI IMPORT', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildResultState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0C0E14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF00E5A0), size: 20),
                  const SizedBox(width: 8),
                  Text('${_result!.successCount} produk berhasil diimport', style: const TextStyle(color: Colors.white)),
                ],
              ),
              if (_result!.updatedCount > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.info_rounded, color: Color(0xFFFFB347), size: 20),
                    const SizedBox(width: 8),
                    Text('${_result!.updatedCount} produk diperbarui', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ],
              if (_result!.errors.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.cancel_rounded, color: Color(0xFFFFB4AB), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${_result!.errors.length} baris gagal:', style: const TextStyle(color: Color(0xFFFFB4AB))),
                          const SizedBox(height: 4),
                          ..._result!.errors.take(5).map((e) => Text('- $e', style: const TextStyle(color: Color(0xFFBACBBF), fontSize: 12))),
                          if (_result!.errors.length > 5)
                            Text('...dan ${_result!.errors.length - 5} error lainnya', style: const TextStyle(color: Color(0xFF84958A), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF33343B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('SELESAI', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
