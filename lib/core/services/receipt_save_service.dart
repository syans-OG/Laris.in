import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

/// Service untuk merender widget struk menjadi gambar PNG
/// dan menyimpan / membagikannya ke galeri / aplikasi lain.
class ReceiptSaveService {
  /// Capture [widget] dengan [controller], simpan sebagai file PNG
  /// sementara di direktori temp, lalu panggil system share sheet
  /// agar pengguna dapat menyimpan ke galeri atau kirim via WhatsApp, dll.
  ///
  /// Mengembalikan `true` jika berhasil, `false` jika gagal.
  static Future<bool> captureAndSave({
    required ScreenshotController controller,
    required String invoiceNo,
  }) async {
    try {
      // 1. Render widget menjadi bytes PNG
      final Uint8List? imageBytes = await controller.capture(
        pixelRatio: 2.5,
        delay: const Duration(milliseconds: 100),
      );

      if (imageBytes == null) return false;

      // 2. Simpan ke direktori temp
      final tempDir = await getTemporaryDirectory();
      final sanitized = invoiceNo.replaceAll(RegExp(r'[^\w-]'), '_');
      final file = File('${tempDir.path}/struk_$sanitized.png');
      await file.writeAsBytes(imageBytes);

      // 3. Buka system share sheet — user bisa pilih "Simpan ke Galeri",
      //    WhatsApp, atau aplikasi lain
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        subject: 'Struk $invoiceNo',
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Versi offscreen — render widget [child] tanpa perlu GlobalKey di tree.
  /// Berguna saat dipanggil dari bottom sheet atau context yang berbeda.
  static Future<bool> captureWidgetAndSave({
    required Widget child,
    required String invoiceNo,
    double pixelRatio = 2.5,
  }) async {
    try {
      final controller = ScreenshotController();
      final Uint8List? imageBytes = await controller.captureFromWidget(
        child,
        pixelRatio: pixelRatio,
        delay: const Duration(milliseconds: 200),
      );

      if (imageBytes == null) return false;

      final tempDir = await getTemporaryDirectory();
      final sanitized = invoiceNo.replaceAll(RegExp(r'[^\w-]'), '_');
      final file = File('${tempDir.path}/struk_$sanitized.png');
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        subject: 'Struk $invoiceNo',
      );

      return true;
    } catch (_) {
      return false;
    }
  }
}
