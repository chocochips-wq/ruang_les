import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

/// General file upload service for all roles
/// Supports images and documents (PDF, PPT, DOCX, etc.)
class FileUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Maximum file size: 10MB
  static const int maxFileSizeBytes = 10 * 1024 * 1024;

  // Allowed document extensions
  static const List<String> allowedDocuments = [
    'pdf',
    'doc',
    'docx',
    'ppt',
    'pptx',
    'xls',
    'xlsx',
  ];

  // Allowed image extensions
  static const List<String> allowedImages = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];

  /// Pick and upload an image
  /// Returns download URL or null if cancelled/failed
  Future<String?> pickAndUploadImage({
    required String folder,
    Function(double)? onProgress,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = File(result.files.single.path!);
      return await uploadFile(
        file,
        folder: folder,
        onProgress: onProgress,
      );
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Pick and upload a document
  /// Returns download URL or null if cancelled/failed
  Future<String?> pickAndUploadDocument({
    required String folder,
    List<String>? allowedExtensions,
    Function(double)? onProgress,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions ?? allowedDocuments,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = File(result.files.single.path!);
      return await uploadFile(
        file,
        folder: folder,
        onProgress: onProgress,
      );
    } catch (e) {
      throw Exception('Failed to pick document: $e');
    }
  }

  /// Upload any file to Firebase Storage
  /// Returns download URL
  Future<String?> uploadFile(
    File file, {
    required String folder,
    Function(double)? onProgress,
  }) async {
    try {
      // Validate file size
      final fileSize = await file.length();
      if (fileSize > maxFileSizeBytes) {
        throw Exception(
            'File terlalu besar. Maksimal ${(maxFileSizeBytes / (1024 * 1024)).toStringAsFixed(0)} MB');
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(file.path);
      final fileName = '${timestamp}_${path.basename(file.path)}';
      final filePath = '$folder/$fileName';

      // Upload to Firebase Storage
      final ref = _storage.ref().child(filePath);
      final uploadTask = ref.putFile(file);

      // Track progress
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      // Wait for completion
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Delete file from Firebase Storage using download URL
  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Get file extension from path
  String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase().replaceAll('.', '');
  }

  /// Get file type from extension
  String getFileType(String extension) {
    extension = extension.toLowerCase();
    if (allowedImages.contains(extension)) return 'image';
    if (extension == 'pdf') return 'pdf';
    if (['doc', 'docx'].contains(extension)) return 'document';
    if (['ppt', 'pptx'].contains(extension)) return 'presentation';
    if (['xls', 'xlsx'].contains(extension)) return 'spreadsheet';
    return 'other';
  }

  /// Format file size to human-readable string
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
