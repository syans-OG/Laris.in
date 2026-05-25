import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_input.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final ProductEntity? product;

  const ProductFormScreen({super.key, this.product});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _barcodeController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _costPriceController;
  late TextEditingController _imageUrlController;
  late TextEditingController _lowStockController;

  int? _selectedCategoryId;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _barcodeController = TextEditingController(text: p?.barcode ?? '');
    _priceController = TextEditingController(text: p?.price.toStringAsFixed(0) ?? '');
    _stockController = TextEditingController(text: p?.stock.toString() ?? '0');
    _costPriceController = TextEditingController(text: p?.costPrice?.toStringAsFixed(0) ?? '');
    _imageUrlController = TextEditingController(text: p?.imageUrl ?? '');
    _lowStockController = TextEditingController(text: p?.lowStockThreshold.toString() ?? '5');

    _selectedCategoryId = p?.categoryId;
    _isActive = p?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _costPriceController.dispose();
    _imageUrlController.dispose();
    _lowStockController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final newProduct = ProductEntity(
        id: widget.product?.id ?? 0,
        barcode: _barcodeController.text.trim(),
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        costPrice: _costPriceController.text.trim().isEmpty 
            ? null 
            : double.parse(_costPriceController.text.trim()),
        stock: int.parse(_stockController.text.trim()),
        categoryId: _selectedCategoryId,
        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        isActive: _isActive,
        lowStockThreshold: int.parse(_lowStockController.text.trim()),
      );

      await ref.read(productsProvider.notifier).saveProduct(newProduct);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil disimpan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final productImageDir = Directory(path.join(appDir.path, 'product_images'));
    if (!await productImageDir.exists()) {
      await productImageDir.create(recursive: true);
    }

    final extension = path.extension(image.path).isEmpty ? '.jpg' : path.extension(image.path);
    final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}$extension';
    final savedImage = await File(image.path).copy(path.join(productImageDir.path, fileName));

    setState(() {
      _imageUrlController.text = savedImage.path;
    });
  }

  void _removeImage() {
    setState(() {
      _imageUrlController.clear();
    });
  }

  Widget _buildImagePreview(String imagePath) {
    final isNetworkImage = imagePath.startsWith('http://') || imagePath.startsWith('https://');
    final fallback = Center(
      child: Icon(Icons.broken_image_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
    );

    if (!isNetworkImage && !File(imagePath).existsSync()) {
      return fallback;
    }

    final image = isNetworkImage
        ? Image.network(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => fallback,
          )
        : Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => fallback,
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: image,
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Tambah Produk' : 'Edit Produk'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextInput(
                label: 'Barcode',
                controller: _barcodeController,
                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              
              AppTextInput(
                label: 'Nama Produk',
                controller: _nameController,
                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                   Expanded(
                    child: AppTextInput(
                      label: 'Harga Jual',
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'Wajib' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextInput(
                      label: 'Harga Beli (Opsional)',
                      controller: _costPriceController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: AppTextInput(
                      label: 'Stok Saat Ini',
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextInput(
                      label: 'Batas Stok Menipis',
                      controller: _lowStockController,
                      keyboardType: TextInputType.number,
                      hint: 'Default: 5',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kategori', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 8),
                  categoriesState.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Error load category'),
                    data: (categories) {
                      return DropdownButtonFormField<int>(
                        isExpanded: true,
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(filled: true),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('Tanpa Kategori'),
                          ),
                          ...categories.map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          )),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedCategoryId = val);
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildImagePickerSection(theme),
              const SizedBox(height: 16),
              
              SwitchListTile(
                title: const Text('Aktif / Tersedia'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              const SizedBox(height: 32),
              
              AppButton(
                text: 'Simpan',
                isLoading: _isLoading,
                onPressed: _saveProduct,
              ),
              
              if (widget.product != null) ...[
                const SizedBox(height: 16),
                AppButton(
                  text: 'Hapus',
                  isPrimary: false,
                  onPressed: () async {
                    final conf = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Hapus?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
                          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Ya')),
                        ],
                      ),
                    );
                    if (conf == true) {
                      await ref.read(productsProvider.notifier).deleteProduct(widget.product!.id);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerSection(ThemeData theme) {
    final imagePath = _imageUrlController.text.trim();
    final hasImage = imagePath.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Gambar Produk',
            style: theme.textTheme.labelMedium?.copyWith(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: hasImage
                  ? _buildImagePreview(imagePath)
                  : Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImageFromGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(hasImage ? 'Ganti dari Galeri' : 'Pilih dari Galeri'),
                ),
              ),
              if (hasImage) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _removeImage,
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.error,
                  tooltip: 'Hapus gambar',
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          AppTextInput(
            label: 'URL / Path Gambar (Opsional)',
            controller: _imageUrlController,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }
}
