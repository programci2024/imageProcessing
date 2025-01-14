import 'dart:typed_data';

import 'package:image/image.dart' as img;


Uint8List? hideTextInImage(Uint8List imageBytes, String text) {
  // Decode the image
  img.Image originalImage = img.decodeImage(imageBytes)!;

  // Convert the text to binary
  List<int> binaryText = text.codeUnits
      .expand((char) => char.toRadixString(2).padLeft(8, '0').split('').map(int.parse))
      .toList();

  // Ensure the text fits in the image
  if (binaryText.length > originalImage.width * originalImage.height) {
    return null; // Text is too long to fit in the image
  }

  // Add the length of the text to the binary
  List<int> binaryTextLength = text.length
      .toRadixString(2)
      .padLeft(32, '0')
      .split('')
      .map(int.parse)
      .toList();
  List<int> dataToEmbed = [...binaryTextLength, ...binaryText];

  int binaryIndex = 0;

  // Embed the binary data into the LSB of the red channel of each pixel
  for (int y = 0; y < originalImage.height && binaryIndex < dataToEmbed.length; y++) {
    for (int x = 0; x < originalImage.width && binaryIndex < dataToEmbed.length; x++) {
      int pixel = originalImage.getPixel(x, y);
      int red = img.getRed(pixel);
      int newRed = (red & 0xFE) | dataToEmbed[binaryIndex]; // Replace LSB
      originalImage.setPixel(x, y, img.getColor(newRed, img.getGreen(pixel), img.getBlue(pixel)));
      binaryIndex++;
    }
  }

  // Encode the modified image to Uint8List and return
  return Uint8List.fromList(img.encodePng(originalImage));


}
