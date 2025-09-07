import 'package:flutter_test/flutter_test.dart';
import 'package:app/services/encryption_service.dart';

void main() {
  group('EncryptionService', () {
    late EncryptionService encryptionService;

    setUp(() {
      encryptionService = EncryptionService();
    });

    group('encrypt', () {
      test('should encrypt text and return different result each time', () {
        // Arrange
        const text = 'test-api-key';
        const password = 'user-password';

        // Act
        final encrypted1 = encryptionService.encrypt(text, password);
        final encrypted2 = encryptionService.encrypt(text, password);

        // Assert
        expect(encrypted1, isNot(equals(text)));
        expect(encrypted2, isNot(equals(text)));
        expect(encrypted1, isNot(equals(encrypted2))); // Different IV each time
        expect(encrypted1, isNotEmpty);
        expect(encrypted2, isNotEmpty);
      });

      test('should return empty string for empty input', () {
        // Arrange
        const text = '';
        const password = 'user-password';

        // Act
        final encrypted = encryptionService.encrypt(text, password);

        // Assert
        expect(encrypted, isEmpty);
      });
    });

    group('decrypt', () {
      test('should decrypt encrypted text correctly', () {
        // Arrange
        const text = 'test-api-key';
        const password = 'user-password';

        // Act
        final encrypted = encryptionService.encrypt(text, password);
        final decrypted = encryptionService.decrypt(encrypted, password);

        // Assert
        expect(decrypted, equals(text));
      });

      test('should return empty string for empty encrypted input', () {
        // Arrange
        const encrypted = '';
        const password = 'user-password';

        // Act
        final decrypted = encryptionService.decrypt(encrypted, password);

        // Assert
        expect(decrypted, isEmpty);
      });

      test('should return empty string for wrong password', () {
        // Arrange
        const text = 'test-api-key';
        const correctPassword = 'correct-password';
        const wrongPassword = 'wrong-password';

        // Act
        final encrypted = encryptionService.encrypt(text, correctPassword);
        final decrypted = encryptionService.decrypt(encrypted, wrongPassword);

        // Assert
        expect(decrypted, isEmpty);
      });
    });

    group('round trip', () {
      test('should encrypt and decrypt various texts correctly', () {
        // Arrange
        final testCases = [
          'simple-key',
          'complex-key-with-special-chars!@#\$%^&*()',
          'key-with-unicode-🚀-emoji',
          'very-long-key-' + 'x' * 1000,
        ];
        const password = 'test-password';

        for (final text in testCases) {
          // Act
          final encrypted = encryptionService.encrypt(text, password);
          final decrypted = encryptionService.decrypt(encrypted, password);

          // Assert
          expect(decrypted, equals(text), reason: 'Failed for text: $text');
        }
      });
    });
  });
}
