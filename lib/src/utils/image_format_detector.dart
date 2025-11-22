import 'dart:typed_data';

/// Utility class for detecting image formats from bytes
class ImageFormatDetector {
  /// Detects the image format from bytes by checking file signatures (magic numbers)
  static String? detectFormat(Uint8List bytes) {
    if (bytes.length < 12) return null;

    // Check HEIC/HEIF format
    // HEIC files start with specific box signatures (ftyp box)
    if (_isHeicFormat(bytes)) {
      return 'heic';
    }

    // Check JPEG format
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'jpeg';
    }

    // Check PNG format
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return 'png';
    }

    // Check BMP format
    if (bytes[0] == 0x42 && bytes[1] == 0x4D) {
      return 'bmp';
    }

    // Check WebP format
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'webp';
    }

    return null;
  }

  /// Checks if the bytes represent a HEIC/HEIF image
  /// HEIC files use the ISO Base Media File Format (ISOBMFF) container
  /// They start with an 'ftyp' box containing brand identifiers
  static bool _isHeicFormat(Uint8List bytes) {
    if (bytes.length < 12) return false;

    // Check for 'ftyp' box at the beginning (ISO Base Media File Format)
    // The ftyp box starts at offset 4 with the box type 'ftyp'
    // Bytes 4-7 should be: 'f', 't', 'y', 'p'
    if (bytes.length >= 12 &&
        bytes[4] == 0x66 && // 'f'
        bytes[5] == 0x74 && // 't'
        bytes[6] == 0x79 && // 'y'
        bytes[7] == 0x70) {
      // 'p'

      // Check for HEIC/HEIF brand identifiers at offset 8-11
      // Common brands: 'heic', 'heif', 'mif1', 'msf1'
      final brand1 = bytes[8];
      final brand2 = bytes[9];
      final brand3 = bytes[10];
      final brand4 = bytes[11];

      // Check for 'heic' (0x68 0x65 0x69 0x63)
      if (brand1 == 0x68 &&
          brand2 == 0x65 &&
          brand3 == 0x69 &&
          brand4 == 0x63) {
        return true;
      }

      // Check for 'heif' (0x68 0x65 0x69 0x66)
      if (brand1 == 0x68 &&
          brand2 == 0x65 &&
          brand3 == 0x69 &&
          brand4 == 0x66) {
        return true;
      }

      // Check for 'mif1' (0x6D 0x69 0x66 0x31) - HEIF image file
      if (brand1 == 0x6D &&
          brand2 == 0x69 &&
          brand3 == 0x66 &&
          brand4 == 0x31) {
        return true;
      }

      // Check for 'msf1' (0x6D 0x73 0x66 0x31) - HEIF sequence file
      if (brand1 == 0x6D &&
          brand2 == 0x73 &&
          brand3 == 0x66 &&
          brand4 == 0x31) {
        return true;
      }
    }

    return false;
  }
}
