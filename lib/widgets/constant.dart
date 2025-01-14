final Map<String, List<Map<String, dynamic>>> topics = {
  "LSB Overview": [
    {
      "content": "What is LSB?\n\nLSB stands for Least Significant Bit. It is the smallest bit in the binary representation of a number, holding the lowest value. In image steganography, LSB is used to embed secret information by replacing the least significant bits of pixel values with the binary data to be hidden. This subtle modification ensures the visual integrity of the image.",
      "example": "For a pixel value of 200 (binary: 11001000), modifying the LSB to embed '1' changes it to 201 (binary: 11001001).",
    },
    {
      "content": "Why Use LSB in Steganography?\n\nLSB modification is popular in steganography because it is a simple, efficient, and minimally invasive technique. By changing the LSBs of pixel values, we can hide large amounts of data without significantly altering the image's visual appearance.",
      "image": "assest/4.png",
    },
  ],
  "Channel Modifications": [
    {
      "content": "Channel Modifications in RGB Images\n\nIn RGB images, each pixel consists of three channels: Red, Green, and Blue. Each channel stores a color intensity value ranging from 0 to 255. By modifying the LSB of each channel independently, we can embed more data into an image without significantly altering its appearance.",
      "example": "For a pixel with Red channel value 100 (binary: 01100100), modifying its LSB to '1' changes it to 101 (binary: 01100101).",
      "image": "assest/10.png",
    },
    {
      "content": "Grayscale Image Modifications\n\nIn grayscale images, each pixel has a single intensity value representing its brightness. These values range from 0 (black) to 255 (white). Modifying the LSB of these intensity values allows us to embed data into grayscale images effectively.",
      "example": "Original intensity: 150 (binary: 10010110). After embedding '1', the intensity becomes 151 (binary: 10010111).",
      "image": "assest/2.png",
    },
  ],
  "Random Data Embedding": [
    {
      "content": "What is Randomized Data Embedding?\n\nInstead of embedding data sequentially, this method distributes the data randomly across the image's pixels. By introducing randomness, this approach increases the security of the hidden message, making it harder for attackers to detect or extract the hidden information.",
      "example": "For the message 'Hi' (binary: 01001000 01101001), random pixel positions such as 5, 23, and 78 can be chosen for embedding individual bits of the message.",
    },
    {
      "content": "Using a Random Seed for Embedding\n\nA random seed ensures that the randomness used in embedding can be recreated during data extraction. Both the sender and receiver must use the same seed to correctly encode and decode the hidden message.",
      "image": "assest/8.png",
    },
  ],
  "Compression and Recovery": [
    {
      "content": "Impact of Compression on Steganography\n\nCompression reduces the size of an image but may affect hidden data. Lossless compression methods (e.g., PNG) retain the embedded data exactly, while lossy compression methods (e.g., JPEG) may distort the hidden information, making it challenging to recover.",
      "example": "If the message 'Yes' is hidden in a PNG image, the data remains intact after compression. However, in a JPEG image, the data might be partially lost or distorted.",
      "image": "assest/12.png",
    },
    {
      "content": "Recovery Techniques After Compression\n\nWhen using lossy compression, advanced recovery techniques like error correction or data reconstruction algorithms may be required to retrieve the hidden information.",
    },
  ],
  "Data Extraction": [
    {
      "content": "How to Extract Hidden Data?\n\nData extraction involves reversing the embedding process by reading the LSBs of the modified pixel values. Using the same sequence or random pattern as embedding, the hidden data can be reconstructed accurately.",
      "example": "For example, extracting 'Hello' (binary: 01001000 01100101 01101100 01101100 01101111) requires reading the LSBs of the respective pixels and converting them back to characters.",
      "image": "assest/data_extraction.png",
    },
    {
      "content": "Challenges in Data Extraction\n\n1. Noise: Any modifications to the image, such as added noise, may alter pixel values and corrupt the hidden data.\n2. Compression Artifacts: Lossy compression methods can modify the LSBs, making data recovery difficult.\n3. Transformations: Scaling, rotation, or other transformations may distort the embedding pattern, requiring advanced techniques to retrieve the data.",
    },
  ],
  "Methods and Implementations": [
    {
      "content": "compressImage Method\n\nCompresses the given image to reduce its size without significant quality loss. Useful for optimizing images before embedding data.",
      "example": "Compress a 5MB image to 1MB with 70% quality.",
      "image": "assest/12.png",
    },
    {
      "content": "extractTextRandomly Method\n\nExtracts hidden text from an image by randomly selecting pixels using a seed. This adds an extra layer of security to the hidden message.",
      "example": "Seed: 12345. Hidden text: 'Hello, World!'. Extracted by reading LSBs of random pixel positions.",
      "image": "assest/13.png",
    },
    {
      "content": "generateRandomDifferenceImage Method\n\nCreates a difference image highlighting changes in the LSBs between two images using random pixel positions. Useful for visualizing changes in steganography.",
      "example": "Original image: 'image1.png', Modified image: 'image2.png'. Differences shown in red pixels.",
      "image": "assest/8.png",
    },
    {
      "content": "hideTextRandomly Method\n\nHides a given text in an image by embedding it into the LSBs of randomly selected pixels using a seed.",
      "example": "Text: 'Secret', Seed: 54321. The text is hidden in random pixels and can be extracted using the same seed.",
      "image": "assest/11.png",
    },
    {
      "content": "extractTextFromImage Method\n\nExtracts hidden text from an image by reading the LSBs sequentially from all pixels.",
      "example": "Hidden text: 'Welcome!' extracted from the LSBs of an image.",
      "image": "assest/11.png",
    },
    
  ],
};
