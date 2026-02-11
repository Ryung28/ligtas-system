import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'file_upload_service.dart';

class PersistentFileStorage {
  static const String _filesKey = 'uploaded_files_data';
  static const String _filesDirKey = 'uploaded_files_directory';

  /// Save uploaded files to persistent storage
  static Future<void> saveUploadedFiles(List<FileUploadItem> files) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filesData = <Map<String, dynamic>>[];

      // Skip file storage on web platform - use SharedPreferences only
      if (kIsWeb) {
        debugPrint(
            'File storage skipped on web platform - using SharedPreferences only');
        for (int i = 0; i < files.length; i++) {
          final file = files[i];
          filesData.add({
            'name': file.name,
            'type': file.type.toString(),
            'size': file.size,
            'uploadStatus': file.uploadStatus.toString(),
            'cloudUrl': file.cloudUrl,
            'persistentPath': null, // No local path on web
          });
        }
        await prefs.setString(_filesKey, jsonEncode(filesData));
        return;
      }

      // Mobile platform file storage logic would go here
      // For now, just store metadata
      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        filesData.add({
          'name': file.name,
          'type': file.type.toString(),
          'size': file.size,
          'uploadStatus': file.uploadStatus.toString(),
          'cloudUrl': file.cloudUrl,
          'persistentPath': null, // File storage disabled for web compatibility
        });
      }

      await prefs.setString(_filesKey, jsonEncode(filesData));
    } catch (e) {
      debugPrint('Error saving uploaded files: $e');
    }
  }

  /// Load uploaded files from persistent storage
  static Future<List<FileUploadItem>> loadUploadedFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filesDataString = prefs.getString(_filesKey);

      if (filesDataString == null) {
        return [];
      }

      final filesData = List<Map<String, dynamic>>.from(
        jsonDecode(filesDataString) as List,
      );

      final loadedFiles = <FileUploadItem>[];

      for (final fileData in filesData) {
        final persistentPath = fileData['persistentPath'] as String?;

        // Skip file loading on web platform
        if (kIsWeb) {
          debugPrint('File loading skipped on web platform');
          continue;
        }

        // Mobile platform file loading logic would go here
        // For now, skip file loading for web compatibility
        debugPrint('File loading disabled for web compatibility');
      }

      return loadedFiles;
    } catch (e) {
      debugPrint('Error loading uploaded files: $e');
      return [];
    }
  }

  /// Clear all persistent files
  static Future<void> clearPersistentFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Skip file clearing on web platform
      if (kIsWeb) {
        debugPrint('File clearing skipped on web platform');
        await prefs.remove(_filesKey);
        await prefs.remove(_filesDirKey);
        return;
      }

      // Mobile platform file clearing logic would go here
      // For now, just clear preferences
      await prefs.remove(_filesKey);
      await prefs.remove(_filesDirKey);
    } catch (e) {
      debugPrint('Error clearing persistent files: $e');
    }
  }

  /// Save a single file to persistent storage
  static Future<String?> saveFile(dynamic file) async {
    try {
      // Skip file saving on web platform
      if (kIsWeb) {
        debugPrint('File saving skipped on web platform');
        return null;
      }

      // Mobile platform file saving logic would go here
      // For now, return null for web compatibility
      debugPrint('File saving disabled for web compatibility');
      return null;
    } catch (e) {
      debugPrint('Error saving file: $e');
      return null;
    }
  }

  /// Check if persistent files exist
  static Future<bool> hasPersistentFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filesDataString = prefs.getString(_filesKey);
      return filesDataString != null && filesDataString.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
