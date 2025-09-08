import 'package:flutter_test/flutter_test.dart';
import 'package:app/services/encryption_service.dart';

void main() {
  group('EncryptionService', () {
    late EncryptionService encryptionService;

    setUp(() {
      encryptionService = EncryptionService();
    });

    group('Encryption', () {
      test('should encrypt text successfully', () {
        const text = 'Hello, World!';
        const password = 'test-password';

        final encrypted = encryptionService.encrypt(text, password);

        expect(encrypted, isNotEmpty);
        expect(encrypted, isNot(equals(text)));
        expect(encrypted.length, greaterThan(text.length));
      });

      test('should return empty string for empty text', () {
        const password = 'test-password';

        final encrypted = encryptionService.encrypt('', password);

        expect(encrypted, isEmpty);
      });

      test('should produce different encrypted results for same input', () {
        const text = 'Hello, World!';
        const password = 'test-password';

        final encrypted1 = encryptionService.encrypt(text, password);
        final encrypted2 = encryptionService.encrypt(text, password);

        // Should be different due to random IV
        expect(encrypted1, isNot(equals(encrypted2)));
      });

      test('should encrypt different texts differently', () {
        const password = 'test-password';

        final encrypted1 = encryptionService.encrypt('Hello', password);
        final encrypted2 = encryptionService.encrypt('World', password);

        expect(encrypted1, isNot(equals(encrypted2)));
      });

      test('should encrypt with different passwords differently', () {
        const text = 'Hello, World!';

        final encrypted1 = encryptionService.encrypt(text, 'password1');
        final encrypted2 = encryptionService.encrypt(text, 'password2');

        expect(encrypted1, isNot(equals(encrypted2)));
      });

      test('should handle special characters', () {
        const text = 'Hello! @#\$%^&*()_+-=[]{}|;:,.<>?';
        const password = 'test-password';

        final encrypted = encryptionService.encrypt(text, password);

        expect(encrypted, isNotEmpty);
        expect(encrypted, isNot(equals(text)));
      });

      test('should handle unicode characters', () {
        const text = 'Hello 世界! 🌍';
        const password = 'test-password';

        final encrypted = encryptionService.encrypt(text, password);

        expect(encrypted, isNotEmpty);
        expect(encrypted, isNot(equals(text)));
      });

      test('should handle long text', () {
        final text = 'A' * 1000; // 1000 character string
        const password = 'test-password';

        final encrypted = encryptionService.encrypt(text, password);

        expect(encrypted, isNotEmpty);
        expect(encrypted, isNot(equals(text)));
      });
    });

    group('Decryption', () {
      test('should decrypt text successfully', () {
        const text = 'Hello, World!';
        const password = 'test-password';

        final encrypted = encryptionService.encrypt(text, password);
        final decrypted = encryptionService.decrypt(encrypted, password);

        expect(decrypted, equals(text));
      });

      test('should return empty string for empty encrypted text', () {
        const password = 'test-password';

        final decrypted = encryptionService.decrypt('', password);

        expect(decrypted, isEmpty);
      });

      test('should return empty string for wrong password', () {
        const text = 'Hello, World!';
        const correctPassword = 'correct-password';
        const wrongPassword = 'wrong-password';

        final encrypted = encryptionService.encrypt(text, correctPassword);
        final decrypted = encryptionService.decrypt(encrypted, wrongPassword);

        expect(decrypted, isEmpty);
      });

      test('should return empty string for invalid base64', () {
        const password = 'test-password';

        final decrypted =
            encryptionService.decrypt('invalid-base64!', password);

        expect(decrypted, isEmpty);
      });

      test('should return empty string for corrupted encrypted data', () {
        const text = 'Hello, World!';
        const password = 'test-password';

        final encrypted = encryptionService.encrypt(text, password);
        // Corrupt the encrypted data by changing some characters
        final corrupted =
            encrypted.substring(0, encrypted.length - 5) + 'XXXXX';

        final decrypted = encryptionService.decrypt(corrupted, password);

        expect(decrypted, isEmpty);
      });

      test('should decrypt special characters correctly', () {
        const text = 'Hello! @#\$%^&*()_+-=[]{}|;:,.<>?';
        const password = 'test-password';

        final encrypted = encryptionService.encrypt(text, password);
        final decrypted = encryptionService.decrypt(encrypted, password);

        expect(decrypted, equals(text));
      });

      test('should decrypt unicode characters correctly', () {
        const text = 'Hello 世界! 🌍';
        const password = 'test-password';

        final encrypted = encryptionService.encrypt(text, password);
        final decrypted = encryptionService.decrypt(encrypted, password);

        expect(decrypted, equals(text));
      });

      test('should decrypt long text correctly', () {
        final text = 'A' * 1000; // 1000 character string
        const password = 'test-password';

        final encrypted = encryptionService.encrypt(text, password);
        final decrypted = encryptionService.decrypt(encrypted, password);

        expect(decrypted, equals(text));
      });

      test('should handle multiple encrypt/decrypt cycles', () {
        const text = 'Hello, World!';
        const password = 'test-password';

        String currentText = text;
        for (int i = 0; i < 5; i++) {
          final encrypted = encryptionService.encrypt(currentText, password);
          currentText = encryptionService.decrypt(encrypted, password);
          expect(currentText, equals(text));
        }
      });
    });

    group('Round-trip encryption', () {
      test('should work with various text lengths', () {
        const password = 'test-password';
        final testTexts = [
          'A',
          'AB',
          'Hello',
          'Hello, World!',
          'This is a longer text with multiple words and punctuation!',
          'A' * 100,
          'A' * 1000,
        ];

        for (final text in testTexts) {
          final encrypted = encryptionService.encrypt(text, password);
          final decrypted = encryptionService.decrypt(encrypted, password);
          expect(decrypted, equals(text), reason: 'Failed for text: "$text"');
        }
      });

      test('should work with various passwords', () {
        const text = 'Hello, World!';
        final testPasswords = [
          'a',
          'ab',
          'password',
          'very-long-password-with-special-chars!@#',
          '123456789',
          'password with spaces',
          'пароль', // Cyrillic
          '密码', // Chinese
        ];

        for (final password in testPasswords) {
          final encrypted = encryptionService.encrypt(text, password);
          final decrypted = encryptionService.decrypt(encrypted, password);
          expect(decrypted, equals(text),
              reason: 'Failed for password: "$password"');
        }
      });
    });

    group('Edge cases', () {
      test('should handle very short password', () {
        const text = 'Hello, World!';
        const password = 'a';

        final encrypted = encryptionService.encrypt(text, password);
        final decrypted = encryptionService.decrypt(encrypted, password);

        expect(decrypted, equals(text));
      });

      test('should handle very long password', () {
        const text = 'Hello, World!';
        final password = 'a' * 1000;

        final encrypted = encryptionService.encrypt(text, password);
        final decrypted = encryptionService.decrypt(encrypted, password);

        expect(decrypted, equals(text));
      });

      test('should handle password with special characters', () {
        const text = 'Hello, World!';
        const password = 'p@ssw0rd!@#\$%^&*()';

        final encrypted = encryptionService.encrypt(text, password);
        final decrypted = encryptionService.decrypt(encrypted, password);

        expect(decrypted, equals(text));
      });

      test('should handle empty password', () {
        const text = 'Hello, World!';
        const password = '';

        final encrypted = encryptionService.encrypt(text, password);
        final decrypted = encryptionService.decrypt(encrypted, password);

        expect(decrypted, equals(text));
      });
    });

    group('Security validation', () {
      test('should reject garbage decrypted data', () {
        // This test verifies that the _isValidDecryptedData method works
        // by trying to decrypt with wrong password and ensuring empty result
        const text = 'Hello, World!';
        const correctPassword = 'correct-password';
        const wrongPassword = 'wrong-password';

        final encrypted = encryptionService.encrypt(text, correctPassword);
        final decrypted = encryptionService.decrypt(encrypted, wrongPassword);

        // Should return empty string due to validation failure
        expect(decrypted, isEmpty);
      });

      test('should accept valid decrypted data', () {
        const text = 'Hello, World! This is valid text.';
        const password = 'test-password';

        final encrypted = encryptionService.encrypt(text, password);
        final decrypted = encryptionService.decrypt(encrypted, password);

        expect(decrypted, equals(text));
      });
    });

    group('Performance', () {
      test('should encrypt/decrypt reasonably fast', () {
        const text = 'Hello, World!';
        const password = 'test-password';

        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 100; i++) {
          final encrypted = encryptionService.encrypt(text, password);
          final decrypted = encryptionService.decrypt(encrypted, password);
          expect(decrypted, equals(text));
        }

        stopwatch.stop();

        // Should complete 100 encrypt/decrypt cycles in reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });
    });
  });
}
