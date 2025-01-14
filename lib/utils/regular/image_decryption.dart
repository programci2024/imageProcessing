import 'dart:typed_data';
import 'package:image/image.dart' as img;

String? decryptTextFromImage(Uint8List imageBytes) {
  // Decode the image
  img.Image image = img.decodeImage(imageBytes)!;

  // Extract binary data from the image
  List<int> binaryData = [];
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      int pixel = image.getPixel(x, y);
      int red = img.getRed(pixel);
      binaryData.add(red & 1); // Extract the least significant bit
    }
  }

  // Ensure sufficient data exists to extract message length
  if (binaryData.length < 32) {
    return null; // Insufficient data
  }

  // Extract the length of the hidden message
  String binaryTextLength = binaryData.sublist(0, 32).map((bit) => bit.toString()).join();
  int textLength = int.tryParse(binaryTextLength, radix: 2) ?? 0;

  if (textLength <= 0 || (textLength * 8 + 32) > binaryData.length) {
    return null; // Invalid or corrupted data
  }

  // Extract the message bits
  List<int> textBinary = binaryData.sublist(32, 32 + (textLength * 8));
  List<int> charCodes = [];
  for (int i = 0; i < textBinary.length; i += 8) {
    String byte = textBinary.sublist(i, i + 8).map((bit) => bit.toString()).join();
    charCodes.add(int.tryParse(byte, radix: 2) ?? 0);
  }

  // Convert binary data to string
  return String.fromCharCodes(charCodes);
}
