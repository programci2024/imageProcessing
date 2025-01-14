
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String?> saveImageReq(Uint8List imageBytes) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/hidden_image.png';
    final file = File(path);
    await file.writeAsBytes(imageBytes);
    return path;
  } catch (e) {
    return null; // Handle error if necessary
  }
}
Future<String?> saveImageRandom(Uint8List imageBytes) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/randomImage.png';
    final file = File(path);
    await file.writeAsBytes(imageBytes);
    return path;
  } catch (e) {
    return null; // Handle error if necessary
  }
}