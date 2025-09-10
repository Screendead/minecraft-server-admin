import 'package:flutter_test/flutter_test.dart';
import 'package:minecraft_server_automation/services/encryption_service.dart';

void main() {
  group('EncryptionService', () {
    late EncryptionService service;

    setUp(() {
      service = EncryptionService();
    });

    group('encrypt', () {
      test('should encrypt text with password', () {
        const text = 'Hello, World!';
        const password = 'test-password';

        final encrypted = service.encrypt(text, password);

        expect(encrypted, isNotEmpty);
        expect(encrypted, isNot(equals(text)));
        expect(encrypted, isA<String>());
      });

      test('should return empty string for empty text', () {
        const text = '';
        const password = 'test-password';

        final encrypted = service.encrypt(text, password);

        expect(encrypted, equals(''));
      });

      test('should produce different encrypted text for same input', () {
        const text = 'Hello, World!';
        const password = 'test-password';

        final encrypted1 = service.encrypt(text, password);
        final encrypted2 = service.encrypt(text, password);

        // Should be different due to random IV
        expect(encrypted1, isNot(equals(encrypted2)));
        expect(encrypted1, isNotEmpty);
        expect(encrypted2, isNotEmpty);
      });

      test('should produce different encrypted text for different passwords',
          () {
        const text = 'Hello, World!';
        const password1 = 'password1';
        const password2 = 'password2';

        final encrypted1 = service.encrypt(text, password1);
        final encrypted2 = service.encrypt(text, password2);

        expect(encrypted1, isNot(equals(encrypted2)));
        expect(encrypted1, isNotEmpty);
        expect(encrypted2, isNotEmpty);
      });

      test('should handle special characters', () {
        const text = 'Special chars: !@#\$%^&*()_+-=[]{}|;:,.<>?';
        const password = 'test-password';

        final encrypted = service.encrypt(text, password);

        expect(encrypted, isNotEmpty);
        expect(encrypted, isNot(equals(text)));
      });

      test('should handle unicode characters', () {
        const text = 'Unicode: 你好世界 🌍 émojis';
        const password = 'test-password';

        final encrypted = service.encrypt(text, password);

        expect(encrypted, isNotEmpty);
        expect(encrypted, isNot(equals(text)));
      });

      test('should handle long text', () {
        final text = 'A' * 1000; // 1000 character string
        const password = 'test-password';

        final encrypted = service.encrypt(text, password);

        expect(encrypted, isNotEmpty);
        expect(encrypted, isNot(equals(text)));
      });
    });

    group('decrypt', () {
      test('should decrypt text with correct password', () {
        const text = 'Hello, World!';
        const password = 'test-password';

        final encrypted = service.encrypt(text, password);
        final decrypted = service.decrypt(encrypted, password);

        expect(decrypted, equals(text));
      });

      test('should return empty string for empty encrypted text', () {
        const encryptedText = '';
        const password = 'test-password';

        final decrypted = service.decrypt(encryptedText, password);

        expect(decrypted, equals(''));
      });

      test('should return empty string for wrong password', () {
        const text = 'Hello, World!';
        const correctPassword = 'correct-password';
        const wrongPassword = 'wrong-password';

        final encrypted = service.encrypt(text, correctPassword);
        final decrypted = service.decrypt(encrypted, wrongPassword);

        expect(decrypted, equals(''));
      });

      test('should return empty string for invalid encrypted text', () {
        const invalidEncryptedText = 'invalid-encrypted-text';
        const password = 'test-password';

        final decrypted = service.decrypt(invalidEncryptedText, password);

        expect(decrypted, equals(''));
      });

      test('should handle special characters', () {
        const text = 'Special chars: !@#\$%^&*()_+-=[]{}|;:,.<>?';
        const password = 'test-password';

        final encrypted = service.encrypt(text, password);
        final decrypted = service.decrypt(encrypted, password);

        expect(decrypted, equals(text));
      });

      test('should handle unicode characters', () {
        const text = 'Unicode: 你好世界 🌍 émojis';
        const password = 'test-password';

        final encrypted = service.encrypt(text, password);
        final decrypted = service.decrypt(encrypted, password);

        expect(decrypted, equals(text));
      });

      test('should handle long text', () {
        final text = 'A' * 1000; // 1000 character string
        const password = 'test-password';

        final encrypted = service.encrypt(text, password);
        final decrypted = service.decrypt(encrypted, password);

        expect(decrypted, equals(text));
      });

      test('should handle empty text', () {
        const text = '';
        const password = 'test-password';

        final encrypted = service.encrypt(text, password);
        final decrypted = service.decrypt(encrypted, password);

        expect(decrypted, equals(text));
      });
    });

    group('round-trip encryption', () {
      test('should encrypt and decrypt successfully', () {
        const text = 'Test message for encryption';
        const password = 'secure-password';

        final encrypted = service.encrypt(text, password);
        final decrypted = service.decrypt(encrypted, password);

        expect(decrypted, equals(text));
        expect(encrypted, isNot(equals(text)));
      });

      test('should work with various text lengths', () {
        const password = 'test-password';
        final texts = [
          'a',
          'ab',
          'abc',
          'Hello World',
          'A' * 100,
          'A' * 1000,
          'Mixed case and numbers: Test123!@#',
        ];

        for (final text in texts) {
          final encrypted = service.encrypt(text, password);
          final decrypted = service.decrypt(encrypted, password);

          expect(decrypted, equals(text), reason: 'Failed for text: $text');
        }
      });

      test('should work with various passwords', () {
        const text = 'Test message';
        final passwords = [
          'a',
          'ab',
          'password',
          'very-long-password-with-special-chars!@#\$%',
          '123456',
          'P@ssw0rd!',
        ];

        for (final password in passwords) {
          final encrypted = service.encrypt(text, password);
          final decrypted = service.decrypt(encrypted, password);

          expect(decrypted, equals(text),
              reason: 'Failed for password: $password');
        }
      });
    });

    group('security', () {
      test('should not reveal original text in encrypted output', () {
        const text = 'Secret message';
        const password = 'password';

        final encrypted = service.encrypt(text, password);

        expect(encrypted, isNot(contains(text)));
        expect(encrypted, isNot(contains('Secret')));
        expect(encrypted, isNot(contains('message')));
      });

      test(
          'should produce different encrypted output for same text and password',
          () {
        const text = 'Same text';
        const password = 'same-password';

        final encrypted1 = service.encrypt(text, password);
        final encrypted2 = service.encrypt(text, password);

        expect(encrypted1, isNot(equals(encrypted2)));
      });

      test('should handle password with special characters', () {
        const text = 'Test message';
        const password = 'P@ssw0rd!@#\$%^&*()';

        final encrypted = service.encrypt(text, password);
        final decrypted = service.decrypt(encrypted, password);

        expect(decrypted, equals(text));
      });
    });

    group('error handling', () {
      test('should handle malformed base64', () {
        const malformedEncryptedText = 'not-valid-base64!@#';
        const password = 'test-password';

        final decrypted = service.decrypt(malformedEncryptedText, password);

        expect(decrypted, equals(''));
      });

      test('should handle too short encrypted text', () {
        const shortEncryptedText =
            'dGVzdA=='; // "test" in base64, too short for IV + data
        const password = 'test-password';

        final decrypted = service.decrypt(shortEncryptedText, password);

        expect(decrypted, equals(''));
      });

      test('should handle invalid characters in encrypted text', () {
        const invalidEncryptedText = 'This is not base64 encoded text';
        const password = 'test-password';

        final decrypted = service.decrypt(invalidEncryptedText, password);

        expect(decrypted, equals(''));
      });
    });

    group('data validation', () {
      test('should reject garbage data from wrong password', () {
        const text = 'Valid text message';
        const correctPassword = 'correct-password';
        const wrongPassword = 'wrong-password';

        final encrypted = service.encrypt(text, correctPassword);
        final decrypted = service.decrypt(encrypted, wrongPassword);

        expect(decrypted, equals(''));
      });

      test('should accept valid decrypted data', () {
        const text = 'Valid text message';
        const password = 'test-password';

        final encrypted = service.encrypt(text, password);
        final decrypted = service.decrypt(encrypted, password);

        expect(decrypted, equals(text));
      });

      test('should handle text with numbers and letters', () {
        const text = 'Test123456789';
        const password = 'test-password';

        final encrypted = service.encrypt(text, password);
        final decrypted = service.decrypt(encrypted, password);

        expect(decrypted, equals(text));
      });

      test('should handle text with special characters and letters', () {
        const text = 'Test!@#\$%^&*()';
        const password = 'test-password';

        final encrypted = service.encrypt(text, password);
        final decrypted = service.decrypt(encrypted, password);

        expect(decrypted, equals(text));
      });
    });
  });
}
