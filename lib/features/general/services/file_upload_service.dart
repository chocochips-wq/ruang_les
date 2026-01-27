import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'file_upload_stub.dart' if (dart.library.io) 'file_upload_io.dart';

/// General file upload service for all roles
/// Supports images and documents (PDF, PPT, DOCX, etc.)
/// Works on both web and mobile platforms
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
        withData: true, // Required for web
      );

      if (result == null || result.files.isEmpty) return null;

      final pickedFile = result.files.single;
      return await _uploadPickedFile(
        pickedFile,
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
        withData: true, // Required for web
      );

      if (result == null || result.files.isEmpty) return null;

      final pickedFile = result.files.single;
      return await _uploadPickedFile(
        pickedFile,
        folder: folder,
        onProgress: onProgress,
      );
    } catch (e) {
      throw Exception('Failed to pick document: $e');
    }
  }

  /// Upload a PlatformFile (works on both web and mobile)
  Future<String?> _uploadPickedFile(
    PlatformFile pickedFile, {
    required String folder,
    Function(double)? onProgress,
  }) async {
    try {
      // Validate file size
      final fileSize = pickedFile.size;
      if (fileSize > maxFileSizeBytes) {
        throw Exception(
            'File terlalu besar. Maksimal ${(maxFileSizeBytes / (1024 * 1024)).toStringAsFixed(0)} MB');
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${timestamp}_${pickedFile.name}';
      final filePath = '$folder/$fileName';

      // Upload to Firebase Storage
      final ref = _storage.ref().child(filePath);
      UploadTask uploadTask;

      if (kIsWeb) {
        // Web: use bytes
        final bytes = pickedFile.bytes;
        if (bytes == null) {
          throw Exception('Tidak dapat membaca file. Coba lagi.');
        }
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(
            contentType: _getContentType(pickedFile.extension ?? ''),
          ),
        );
      } else {
        // Mobile: use file path
        if (pickedFile.path == null) {
          throw Exception('Path file tidak tersedia');
        }
        uploadTask = createUploadTask(ref, pickedFile.path!);
      }

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

  /// Get content type from extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'ppt':
      case 'pptx':
        return 'application/vnd.ms-powerpoint';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
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
    final lastDot = filePath.lastIndexOf('.');
    if (lastDot == -1) return '';
    return filePath.substring(lastDot + 1).toLowerCase();
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
