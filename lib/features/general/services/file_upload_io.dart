// IO-specific file operations for mobile platforms
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

UploadTask createUploadTask(Reference ref, String path) {
  final file = File(path);
  return ref.putFile(file);
}
