import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../entities/product_entity.dart';
import '../entities/category_entity.dart';
import '../repositories/product_repository.dart';
import '../repositories/category_repository.dart';

class ImportResult {
  final int successCount;
  final int updatedCount;
  final List<String> errors;

  ImportResult(this.successCount, this.updatedCount, this.errors);
}

class ImportCsvUseCase {
  final ProductRepository _productRepository;
  final CategoryRepository _categoryRepository;

  ImportCsvUseCase(this._productRepository, this._categoryRepository);

  Future<ImportResult> execute(String filePath) async {
    int successCount = 0;
    int updatedCount = 0;
    List<String> errors = [];
    List<ProductEntity> productsToSave = [];

    try {
      final file = File(filePath);
      final csvString = await file.readAsString(encoding: utf8);
      
      final rows = const CsvToListConverter().convert(csvString);
      if (rows.isEmpty) {
        errors.add("File CSV kosong.");
        return ImportResult(successCount, updatedCount, errors);
      }

      // Pastikan ada header
      final dataRows = rows.skip(1).toList();

      // Get existing categories
      List<CategoryEntity> categories = await _categoryRepository.getCategories();
      
      // Get existing products mapped by barcode
      final existingProducts = await _productRepository.getProducts();
      final productMap = {for (var p in existingProducts) p.barcode: p};

      // Custom helper to get category ID
      Future<int?> getCategoryId(String name) async {
        final targetName = name.isEmpty ? "Lainnya" : name;
        var foundCat = categories.where((c) => c.name.toLowerCase() == targetName.toLowerCase());
        if (foundCat.isNotEmpty) {
          return foundCat.first.id;
        }
        
        // Buat kategori baru jika belum ada
        final newCategory = CategoryEntity(id: 0, name: targetName, color: '#6B7280', icon: 'folder', sortOrder: 99);
        await _categoryRepository.saveCategory(newCategory);
        categories = await _categoryRepository.getCategories(); // Refresh
        foundCat = categories.where((c) => c.name.toLowerCase() == targetName.toLowerCase());
        return foundCat.isNotEmpty ? foundCat.first.id : null;
      }

      for (var i = 0; i < dataRows.length; i++) {
        final row = dataRows[i];
        final rowNum = i + 2; // +1 header, +1 untuk index (1-based)

        try {
          if (row.length < 2) {
            errors.add("Baris $rowNum: Format kolom tidak lengkap.");
            continue;
          }

          final barcode = row[0].toString().trim();
          final namaProduk = row[1].toString().trim();
          final String kategoriNama = row.length > 2 ? row[2].toString().trim() : '';
          final double hargaJual = row.length > 3 ? (num.tryParse(row[3].toString())?.toDouble() ?? 0) : 0;
          final double hargaBeli = row.length > 4 ? (num.tryParse(row[4].toString())?.toDouble() ?? 0) : 0;
          final int stok = row.length > 5 ? (num.tryParse(row[5].toString())?.toInt() ?? 0) : 0;
          // field 6 (satuan) diabaikan dulu 

          if (barcode.isEmpty) {
            errors.add("Baris $rowNum: Barcode kosong.");
            continue;
          }
          if (namaProduk.isEmpty) {
            errors.add("Baris $rowNum: Nama produk kosong.");
            continue;
          }
          if (hargaJual <= 0) {
            errors.add("Baris $rowNum: Harga jual harus > 0.");
            continue;
          }

          final categoryId = await getCategoryId(kategoriNama);

          final existingProduct = productMap[barcode];
          if (existingProduct != null) {
            productsToSave.add(
              existingProduct.copyWith(
                name: namaProduk,
                price: hargaJual,
                costPrice: hargaBeli,
                stock: stok,
                categoryId: categoryId,
              )
            );
            updatedCount++;
          } else {
            productsToSave.add(
              ProductEntity(
                id: 0,
                barcode: barcode,
                name: namaProduk,
                price: hargaJual,
                costPrice: hargaBeli,
                stock: stok,
                categoryId: categoryId,
                isActive: true,
              )
            );
            successCount++;
          }

        } catch (e) {
          errors.add("Baris $rowNum: Gagal diparse (${e.toString()})");
        }
      }

      if (productsToSave.isNotEmpty) {
        await _productRepository.saveProductsBatch(productsToSave);
      }

    } catch (e) {
      errors.add("Gagal membaca file: $e");
    }

    return ImportResult(successCount, updatedCount, errors);
  }
}

final importCsvUseCaseProvider = Provider<ImportCsvUseCase>((ref) {
  return ImportCsvUseCase(
    ref.watch(productRepositoryProvider),
    ref.watch(categoryRepositoryProvider),
  );
});
