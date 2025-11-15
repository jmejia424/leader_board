import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'storage_repository.g.dart';

class StorageRepository {
  StorageRepository(this._storage);
  final FirebaseStorage _storage;

  Future<String> uploadScore(XFile file, [String? customFileName]) async {
    final fileName = customFileName ?? file.name;
    final ref = _storage.ref().child('scores/$fileName.jpg');
    if (kIsWeb) {
      final data = await file.readAsBytes();
      final uploadTask = ref.putData(data);
      final snapshot = await uploadTask.whenComplete(() => null);
      return snapshot.ref.getDownloadURL();
    } else {
      final uploadTask = ref.putFile(File(file.path));
      final snapshot = await uploadTask.whenComplete(() => null);
      return snapshot.ref.getDownloadURL();
    }
  }
}

@Riverpod(keepAlive: true)
StorageRepository storageRepository(Ref ref) {
  return StorageRepository(FirebaseStorage.instance);
}
