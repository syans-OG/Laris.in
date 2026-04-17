import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_windows/path_provider_windows.dart';

void main() {
  test('Print Documents Directory', () async {
    // Force path_provider to use windows implementation in tests
    PathProviderWindows.registerWith();
    
    final dir = await getApplicationDocumentsDirectory();
    print('--- Path Provider Diagnostics ---');
    print('DOCUMENTS_DIR: ${dir.path}');
    print('---------------------------------');
  });
}
