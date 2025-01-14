import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
String? extractTextRandomly(Uint8List imageBytes, int seed) {
  img.Image image = img.decodeImage(imageBytes)!;

  // Generate random positions using the seed
  int totalPixels = image.width * image.height;
  Random random = Random(seed);
  List<int> positions = List<int>.generate(totalPixels, (index) => index)..shuffle(random);

  List<int> binaryData = [];

  // Extract binary data from random positions
  for (int position in positions) {
    int x = position % image.width;
    int y = position ~/ image.width;

    int pixel = image.getPixel(x, y);
    int red = img.getRed(pixel);
    binaryData.add(red & 1); // Extract the LSB
  }

  // Extract the text length (first 32 bits)
  if (binaryData.length < 32) {
    return null; // Insufficient data for text length
  }

  String binaryTextLength = binaryData.sublist(0, 32).map((bit) => bit.toString()).join();
  int textLength = int.tryParse(binaryTextLength, radix: 2) ?? 0;

  // Extract the text based on the extracted length
  if (binaryData.length < (32 + textLength * 8)) {
    return null; // Insufficient data for text
  }

  List<int> textBinary = binaryData.sublist(32, 32 + textLength * 8);
  List<int> charCodes = [];
  for (int i = 0; i < textBinary.length; i += 8) {
    String byte = textBinary.sublist(i, i + 8).map((bit) => bit.toString()).join();
    charCodes.add(int.tryParse(byte, radix: 2) ?? 0);
  }

  return String.fromCharCodes(charCodes);
}

