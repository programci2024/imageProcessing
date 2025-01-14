import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

Uint8List? hideTextRandomly(Uint8List imageBytes, String text, int seed) {
  img.Image originalImage = img.decodeImage(imageBytes)!;

  // Convert text to binary
  List<int> binaryText = text.codeUnits
      .expand((char) => char.toRadixString(2).padLeft(8, '0').split('').map(int.parse))
      .toList();

  // Add text length in binary (32 bits for the length)
  List<int> binaryTextLength = text.length
      .toRadixString(2)
      .padLeft(32, '0')
      .split('')
      .map(int.parse)
      .toList();

  List<int> dataToEmbed = [...binaryTextLength, ...binaryText];

  // Ensure data fits within the image
  int totalPixels = originalImage.width * originalImage.height;
  if (dataToEmbed.length > totalPixels) {
    return null; // Data is too large for the image
  }

  // Generate random positions using the seed
  Random random = Random(seed);
  List<int> positions = List<int>.generate(totalPixels, (index) => index)..shuffle(random);

  int binaryIndex = 0;

  // Embed the binary data in random positions
  for (int i = 0; i < positions.length && binaryIndex < dataToEmbed.length; i++) {
    int position = positions[i];
    int x = position % originalImage.width;
    int y = position ~/ originalImage.width;

    int pixel = originalImage.getPixel(x, y);
    int red = img.getRed(pixel);
    int newRed = (red & 0xFE) | dataToEmbed[binaryIndex]; // Modify LSB
    originalImage.setPixel(x, y, img.getColor(newRed, img.getGreen(pixel), img.getBlue(pixel)));

    binaryIndex++;
  }

  // Encode and return the modified image
  return Uint8List.fromList(img.encodePng(originalImage));
}
