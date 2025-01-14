import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
import 'package:image/image.dart' as img;

String? _extractTextUsingThreeChannels(Uint8List imageBytes) {
  final img.Image? image = img.decodeImage(imageBytes);
  if (image == null) return null;

  List<int> binaryData = [];

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      int pixel = image.getPixel(x, y);
      int red = img.getRed(pixel);
      int green = img.getGreen(pixel);
      int blue = img.getBlue(pixel);

      // Extract LSB alternately from Red, Green, and Blue channels
      if (binaryData.length % 3 == 0) {
        binaryData.add(red & 1);
      } else if (binaryData.length % 3 == 1) {
        binaryData.add(green & 1);
      } else if (binaryData.length % 3 == 2) {
        binaryData.add(blue & 1);
      }
    }
  }

  // Extract text length (32 bits)
  if (binaryData.length < 32) return null;
  String binaryTextLength = binaryData.sublist(0, 32).join();
  int textLength = int.tryParse(binaryTextLength, radix: 2) ?? 0;

  // Extract text based on length
  if (binaryData.length < 32 + textLength * 8) return null;
  List<int> textBinary = binaryData.sublist(32, 32 + textLength * 8);
  List<int> charCodes = [];

  for (int i = 0; i < textBinary.length; i += 8) {
    String byte = textBinary.sublist(i, i + 8).join();
    charCodes.add(int.tryParse(byte, radix: 2) ?? 0);
  }

  return String.fromCharCodes(charCodes);
}
