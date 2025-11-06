import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadPaymentScreenshot(String billId, File file) async {
    final ref = _storage.ref().child('payments').child('$billId.jpg');
    final task = await ref.putFile(file);
    final url = await task.ref.getDownloadURL();
    return url;
  }
}
