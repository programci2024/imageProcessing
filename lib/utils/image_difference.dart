import 'dart:typed_data';
import 'package:image/image.dart' as img;

Uint8List? generateDifferenceImage(Uint8List originalBytes, Uint8List modifiedBytes) {
  // Decode the images
  img.Image originalImage = img.decodeImage(originalBytes)!;
  img.Image modifiedImage = img.decodeImage(modifiedBytes)!;

  if (originalImage.width != modifiedImage.width || originalImage.height != modifiedImage.height) {
    return null; // Images must have the same dimensions
  }

  // Create a new image for differences
  img.Image differenceImage = img.Image(originalImage.width, originalImage.height);

  for (int y = 0; y < originalImage.height; y++) {
    for (int x = 0; x < originalImage.width; x++) {
      int originalPixel = originalImage.getPixel(x, y);
      int modifiedPixel = modifiedImage.getPixel(x, y);

      // Extract the LSB of the red channel
      int originalLSB = img.getRed(originalPixel) & 1;
      int modifiedLSB = img.getRed(modifiedPixel) & 1;

      if (originalLSB != modifiedLSB) {
        // Highlight differences in red if LSBs differ
        differenceImage.setPixel(x, y, img.getColor(255, 0, 0)); // Red for differences
      } else {
        // Keep unchanged pixels black
        differenceImage.setPixel(x, y, img.getColor(0, 0, 0)); // Black for no differences
      }
    }
  }

  // Return the difference image as Uint8List
  return Uint8List.fromList(img.encodePng(differenceImage));
}
