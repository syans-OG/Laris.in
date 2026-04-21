import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../database/app_database.dart';

class BackupService {
  static Future<String> _getDbPath() async {
    final dir = await getApplicationSupportDirectory();
    return p.join(dir.path, 'databases', 'kasir_pro.db');
  }

  static Future<bool> backupDatabase() async {
    try {
      final dbPath = await _getDbPath();
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) return false;

      // Create a temporary copy to share
      final tempDir = await getTemporaryDirectory();
      final backupPath = p.join(tempDir.path, 'backup_larisin_${DateTime.now().millisecondsSinceEpoch}.db');
      await dbFile.copy(backupPath);

      await Share.shareXFiles([XFile(backupPath)], text: 'Backup Database Laris.in');
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> restoreDatabase() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any, // .db files often show up as custom
      );

      if (result == null || result.files.single.path == null) return false;

      final pickedFile = File(result.files.single.path!);
      final dbPath = await _getDbPath();

      // 1. Close current DB connection
      await AppDatabase.instance.close();

      // 2. Overwrite
      await pickedFile.copy(dbPath);

      // 3. Re-init is usually automatic upon next access to AppDatabase.instance.database
      return true;
    } catch (e) {
      return false;
    }
  }
}
