import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobileapplication/services/cloudinary_service.dart';
import 'package:mobileapplication/userdashboard/usercomplaintpage/services/persistent_file_storage.dart';

class FileUploadService {
  static final FileUploadService _instance = FileUploadService._internal();
  factory FileUploadService() => _instance;
  FileUploadService._internal() {
    _loadPersistentFiles();
  }

  /// Load files from persistent storage on initialization
  Future<void> _loadPersistentFiles() async {
    try {
      final persistentFiles = await PersistentFileStorage.loadUploadedFiles();
      _uploadedFiles.addAll(persistentFiles);
    } catch (e) {
      debugPrint('Error loading persistent files: $e');
    }
  }

  final ImagePicker _picker = ImagePicker();
  final List<FileUploadItem> _uploadedFiles = [];

  List<FileUploadItem> get uploadedFiles => _uploadedFiles;

  /// Supported file types
  static const List<String> supportedImageTypes = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp'
  ];

  static const List<String> supportedVideoTypes = [
    'mp4',
    'mov',
    'avi',
    'mkv',
    'webm'
  ];

  static const List<String> supportedDocumentTypes = [
    'pdf',
    'doc',
    'docx',
    'txt',
    'rtf'
  ];

  /// Pick image from gallery or camera
  Future<FileUploadResult> pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (file == null) {
        return FileUploadResult.cancelled();
      }

      final filePath = file.path;
      final fileSize = await _getFileSize(filePath);

      if (fileSize > 10 * 1024 * 1024) {
        // 10MB limit
        return FileUploadResult.error('File size exceeds 10MB limit');
      }

      final fileType = _getFileType(filePath);
      if (!supportedImageTypes.contains(fileType)) {
        return FileUploadResult.error('Unsupported image format');
      }

      final uploadItem = FileUploadItem(
        file: File(filePath),
        type: FileType.image,
        name: file.name,
        size: fileSize,
        uploadStatus: UploadStatus.pending,
      );

      _uploadedFiles.add(uploadItem);
      // Save to persistent storage
      await PersistentFileStorage.saveUploadedFiles(_uploadedFiles);
      return FileUploadResult.success(uploadItem);
    } catch (e) {
      debugPrint('Image picker error: $e');
      return FileUploadResult.error('Failed to pick image: $e');
    }
  }

  /// Pick video from gallery or camera
  Future<FileUploadResult> pickVideo(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 2), // 2 minute limit
      );

      if (file == null) {
        return FileUploadResult.cancelled();
      }

      final filePath = file.path;
      final fileSize = await _getFileSize(filePath);

      if (fileSize > 50 * 1024 * 1024) {
        // 50MB limit for videos
        return FileUploadResult.error('Video size exceeds 50MB limit');
      }

      final fileType = _getFileType(filePath);
      if (!supportedVideoTypes.contains(fileType)) {
        return FileUploadResult.error('Unsupported video format');
      }

      final uploadItem = FileUploadItem(
        file: File(filePath),
        type: FileType.video,
        name: file.name,
        size: fileSize,
        uploadStatus: UploadStatus.pending,
      );

      _uploadedFiles.add(uploadItem);
      // Save to persistent storage
      await PersistentFileStorage.saveUploadedFiles(_uploadedFiles);
      return FileUploadResult.success(uploadItem);
    } catch (e) {
      debugPrint('Video picker error: $e');
      return FileUploadResult.error('Failed to pick video: $e');
    }
  }

  /// Replace existing images with a new one
  Future<FileUploadResult> replaceImage(ImageSource source) async {
    try {
      // Remove all existing images first
      _uploadedFiles.removeWhere((item) => item.type == FileType.image);
      // Save to persistent storage after removal
      await PersistentFileStorage.saveUploadedFiles(_uploadedFiles);
      
      // Pick new image
      return await pickImage(source);
    } catch (e) {
      debugPrint('Replace image error: $e');
      return FileUploadResult.error('Failed to replace image: $e');
    }
  }

  /// Replace existing videos with a new one
  Future<FileUploadResult> replaceVideo(ImageSource source) async {
    try {
      // Remove all existing videos first
      _uploadedFiles.removeWhere((item) => item.type == FileType.video);
      // Save to persistent storage after removal
      await PersistentFileStorage.saveUploadedFiles(_uploadedFiles);
      
      // Pick new video
      return await pickVideo(source);
    } catch (e) {
      debugPrint('Replace video error: $e');
      return FileUploadResult.error('Failed to replace video: $e');
    }
  }

  /// Pick document (for future implementation)
  Future<FileUploadResult> pickDocument() async {
    // This would typically use file_picker package
    // For now, return a placeholder
    return FileUploadResult.error('Document picker not implemented yet');
  }

  /// Upload all files to Cloudinary
  Future<UploadResult> uploadAllFiles() async {
    if (_uploadedFiles.isEmpty) {
      return UploadResult.success([]);
    }

    try {
      final filesToUpload = _uploadedFiles
          .where((item) => item.uploadStatus == UploadStatus.pending)
          .map((item) => item.file)
          .toList();

      if (filesToUpload.isEmpty) {
        return UploadResult.success([]);
      }

      // Update status to uploading
      for (var item in _uploadedFiles) {
        if (item.uploadStatus == UploadStatus.pending) {
          item.uploadStatus = UploadStatus.uploading;
        }
      }

      // Upload to Cloudinary
      final urls =
          await CloudinaryService.uploadFiles(filesToUpload, 'complaints');

      // Update status to completed
      for (var item in _uploadedFiles) {
        if (item.uploadStatus == UploadStatus.uploading) {
          item.uploadStatus = UploadStatus.completed;
        }
      }

      return UploadResult.success(urls);
    } catch (e) {
      // Update status to failed
      for (var item in _uploadedFiles) {
        if (item.uploadStatus == UploadStatus.uploading) {
          item.uploadStatus = UploadStatus.failed;
        }
      }

      debugPrint('File upload error: $e');
      return UploadResult.error('Failed to upload files: $e');
    }
  }

  /// Remove file from upload list
  Future<void> removeFile(int index) async {
    if (index >= 0 && index < _uploadedFiles.length) {
      _uploadedFiles.removeAt(index);
      // Update persistent storage
      await PersistentFileStorage.saveUploadedFiles(_uploadedFiles);
    }
  }

  /// Clear all files
  Future<void> clearAllFiles() async {
    _uploadedFiles.clear();
    // Clear persistent storage
    await PersistentFileStorage.clearPersistentFiles();
  }

  /// Get file size in bytes
  Future<int> _getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      return await file.length();
    } catch (e) {
      return 0;
    }
  }

  /// Get file type from path
  String _getFileType(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Check if file type is supported
  static bool isFileTypeSupported(String filePath) {
    final fileType = filePath.split('.').last.toLowerCase();
    return supportedImageTypes.contains(fileType) ||
        supportedVideoTypes.contains(fileType) ||
        supportedDocumentTypes.contains(fileType);
  }
}

/// File upload item model
class FileUploadItem {
  final File file;
  final FileType type;
  final String name;
  final int size;
  UploadStatus uploadStatus;
  String? cloudUrl;

  FileUploadItem({
    required this.file,
    required this.type,
    required this.name,
    required this.size,
    required this.uploadStatus,
    this.cloudUrl,
  });
}

/// File types enum
enum FileType {
  image,
  video,
  document,
}

/// Upload status enum
enum UploadStatus {
  pending,
  uploading,
  completed,
  failed,
}

/// File upload result
class FileUploadResult {
  final bool isSuccess;
  final bool isCancelled;
  final String? error;
  final FileUploadItem? item;

  FileUploadResult.success(this.item)
      : isSuccess = true,
        isCancelled = false,
        error = null;

  FileUploadResult.error(this.error)
      : isSuccess = false,
        isCancelled = false,
        item = null;

  FileUploadResult.cancelled()
      : isSuccess = false,
        isCancelled = true,
        error = null,
        item = null;
}

/// Upload result for batch operations
class UploadResult {
  final bool isSuccess;
  final String? error;
  final List<String> urls;

  UploadResult.success(this.urls)
      : isSuccess = true,
        error = null;

  UploadResult.error(this.error)
      : isSuccess = false,
        urls = [];
}
