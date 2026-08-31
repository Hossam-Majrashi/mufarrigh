import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Cross-platform file utilities for importing sprite sheets and exporting elements.
class FileUtils {
  FileUtils._();

  /// Opens a native image file picker and returns the selected file's bytes,
  /// or null if the user cancelled.
  static Future<({Uint8List bytes, String path})?> pickImageFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp', 'bmp', 'gif'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      // On desktop, bytes may be null — read from path
      final path = file.path;
      if (path == null) return null;
      final data = await File(path).readAsBytes();
      return (bytes: data, path: path);
    }
    return (bytes: bytes, path: file.path ?? file.name);
  }

  /// Opens a native folder/directory picker and returns the chosen path,
  /// or null if cancelled.
  static Future<String?> pickOutputFolder() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose Export Folder',
    );
    return result;
  }

  /// Returns the default export folder for the current platform:
  /// - Mobile: app documents directory
  /// - Desktop: user's Pictures directory (if available), otherwise documents
  static Future<String> defaultExportFolder() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final dir = await getApplicationDocumentsDirectory();
        return p.join(dir.path, 'Mufarrigh', 'Exports');
      } else {
        // Desktop — use Pictures if available
        final home = Platform.environment['HOME'] ??
            Platform.environment['USERPROFILE'] ??
            (await getApplicationDocumentsDirectory()).path;
        final pictures = p.join(home, 'Pictures', 'Mufarrigh');
        return pictures;
      }
    } catch (_) {
      final dir = await getApplicationDocumentsDirectory();
      return p.join(dir.path, 'Mufarrigh');
    }
  }

  /// Ensures the directory at [folderPath] exists.
  static Future<void> ensureDir(String folderPath) async {
    final dir = Directory(folderPath);
    if (!dir.existsSync()) await dir.create(recursive: true);
  }

  /// Returns a safe filename by replacing invalid characters.
  static String sanitizeFilename(String name) {
    return name
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_')
        .trim();
  }
}
