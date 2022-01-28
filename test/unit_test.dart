import 'package:test/test.dart';
import 'package:QRReader/utils/string_validator.dart';

void main() {
  group('URL String Validation', () {
    test('If text is a URL, should return true', () {
      final stringValidator = StringValidator();

      bool isURL = stringValidator.isStringURL("google.com");

      expect(isURL, true);
    });

    test('If text is a URL, should return true', () {
      final stringValidator = StringValidator();

      bool isURL = stringValidator.isStringURL("snake.io");

      expect(isURL, true);
    });

    test('If text is a URL, should return true', () {
      final stringValidator = StringValidator();

      bool isURL = stringValidator.isStringURL("https://snake.io/");

      expect(isURL, true);
    });

    test('If text is not URL, should return false', () {
      final stringValidator = StringValidator();

      bool isURL = stringValidator.isStringURL("google");

      expect(isURL, false);
    });
  });
}
