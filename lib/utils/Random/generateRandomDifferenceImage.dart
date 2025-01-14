import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

Uint8List? generateRandomDifferenceImage(Uint8List originalBytes, Uint8List modifiedBytes, int seed) {
  // Decode the images
  img.Image originalImage = img.decodeImage(originalBytes)!;
  img.Image modifiedImage = img.decodeImage(modifiedBytes)!;

  if (originalImage.width != modifiedImage.width || originalImage.height != modifiedImage.height) {
    return null; // Images must have the same dimensions
  }

  // Create a new image for differences
  img.Image differenceImage = img.Image(originalImage.width, originalImage.height);

  // Generate random positions using the seed
  int totalPixels = originalImage.width * originalImage.height;
  Random random = Random(seed);
  List<int> positions = List<int>.generate(totalPixels, (index) => index)..shuffle(random);

  for (int i = 0; i < positions.length; i++) {
    int position = positions[i];
    int x = position % originalImage.width;
    int y = position ~/ originalImage.width;

    int originalPixel = originalImage.getPixel(x, y);
    int modifiedPixel = modifiedImage.getPixel(x, y);

    // Compare the LSB of the red channel
    int originalLSB = img.getRed(originalPixel) & 1;
    int modifiedLSB = img.getRed(modifiedPixel) & 1;

    if (originalLSB != modifiedLSB) {
      // Highlight differences in red
      differenceImage.setPixel(x, y, img.getColor(255, 0, 0));
    } else {
      // Keep unchanged pixels black
      differenceImage.setPixel(x, y, img.getColor(0, 0, 0));
    }
  }

  // Return the difference image as Uint8List
  return Uint8List.fromList(img.encodePng(differenceImage));
}
