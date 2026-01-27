// Stub file for web platform - File operations not needed
// This is used when dart:io is not available (web)

import 'package:firebase_storage/firebase_storage.dart';

UploadTask createUploadTask(Reference ref, String path) {
  throw UnsupportedError('File upload via path not supported on web');
}
