import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService extends ChangeNotifier {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String> uploadBeforeImage(String containerId, File file) async {
    final path = 'before/$containerId.jpg';
    final ref = storage.ref(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<String> uploadAfterImage(String containerId, File file) async {
    final path = 'after/$containerId.jpg';
    final ref = storage.ref(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}