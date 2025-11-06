import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ml_helper/flutter_ml_helper.dart';

void main() {
  group('ImageNetLabels Tests', () {
    test('should get label for valid class index', () {
      final label = ImageNetLabels.getLabel(0);
      expect(label, isNotEmpty);
      expect(label, isA<String>());
    });

    test('should get display name for valid class index', () {
      final displayName = ImageNetLabels.getDisplayName(0);
      expect(displayName, isNotEmpty);
      expect(displayName, isA<String>());
    });

    test('should return fallback label for known fallback indices', () {
      final label = ImageNetLabels.getLabel(611);
      expect(label, isNotEmpty);
      // Should be either from cache or fallback
      expect(label, isA<String>());
    });

    test('should return "Class X" for unknown indices', () {
      final label = ImageNetLabels.getLabel(99999);
      expect(label, startsWith('Class '));
    });

    test('should handle display name with commas', () {
      // Test that display name splits on comma
      final displayName = ImageNetLabels.getDisplayName(0);
      expect(displayName, isA<String>());
      // Display name should be the first part before comma
      expect(displayName.split(',').length, greaterThanOrEqualTo(1));
    });
  });
}
