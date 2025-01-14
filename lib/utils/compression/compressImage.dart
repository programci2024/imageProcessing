import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
Future<List<int>> compressImage(Uint8List imageBytes, {int quality = 70}) async {
   final img.Image originalImage = img.decodeImage(imageBytes)!;
  return img.encodeJpg(originalImage, quality: quality);
}