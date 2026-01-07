import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload file to Firebase Storage
  Future<String> uploadFile({
    required File file,
    required String path,
    Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);

      // Listen to upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // Upload image
  Future<String> uploadImage({
    required File imageFile,
    required String folder,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    final path = '$folder/$fileName';
    return await uploadFile(
      file: imageFile,
      path: path,
      onProgress: onProgress,
    );
  }

  // Upload profile image
  Future<String> uploadProfileImage({
    required File imageFile,
    required String userId,
    Function(double)? onProgress,
  }) async {
    final fileName = 'profile_$userId.jpg';
    return await uploadImage(
      imageFile: imageFile,
      folder: 'profiles',
      fileName: fileName,
      onProgress: onProgress,
    );
  }

  // Upload material file
  Future<String> uploadMaterialFile({
    required File file,
    required String classId,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    final path = 'materials/$classId/$fileName';
    return await uploadFile(
      file: file,
      path: path,
      onProgress: onProgress,
    );
  }

  // Delete file from Firebase Storage
  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  // Get file metadata
  Future<FullMetadata> getFileMetadata(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      return await ref.getMetadata();
    } catch (e) {
      throw Exception('Failed to get file metadata: $e');
    }
  }

  // List files in a folder
  Future<List<String>> listFiles(String folderPath) async {
    try {
      final ref = _storage.ref().child(folderPath);
      final result = await ref.listAll();

      final urls = <String>[];
      for (final item in result.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }

      return urls;
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }
}
