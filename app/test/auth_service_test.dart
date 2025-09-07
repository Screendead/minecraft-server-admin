import 'package:flutter_test/flutter_test.dart';
import 'package:app/services/encryption_service.dart';

void main() {
  group('EncryptionService', () {
    late EncryptionService encryptionService;

    setUp(() {
      encryptionService = EncryptionService();
    });

    group('encrypt', () {
      test('should encrypt text successfully', () {
        const text = 'test-api-key';
        const password = 'password123';

        final encrypted = encryptionService.encrypt(text, password);

        expect(encrypted, isNotEmpty);
        expect(encrypted, isNot(equals(text)));
      });

      test('should return empty string for empty text', () {
        const text = '';
        const password = 'password123';

        final encrypted = encryptionService.encrypt(text, password);

        expect(encrypted, isEmpty);
      });
    });

    group('decrypt', () {
      test('should decrypt text successfully', () {
        const text = 'test-api-key';
        const password = 'password123';

        final encrypted = encryptionService.encrypt(text, password);
        final decrypted = encryptionService.decrypt(encrypted, password);

        expect(decrypted, equals(text));
      });

      test('should return empty string for empty encrypted text', () {
        const encryptedText = '';
        const password = 'password123';

        final decrypted = encryptionService.decrypt(encryptedText, password);

        expect(decrypted, isEmpty);
      });

      test('should return empty string for wrong password', () {
        const text = 'test-api-key';
        const password = 'password123';
        const wrongPassword = 'wrong-password';

        final encrypted = encryptionService.encrypt(text, password);
        final decrypted = encryptionService.decrypt(encrypted, wrongPassword);

        expect(decrypted, isEmpty);
      });
    });
  });
}