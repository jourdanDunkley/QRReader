import 'package:string_validator/string_validator.dart';

class StringValidator {
  bool isStringURL(String message) {
    return isURL(message);
  }
}
