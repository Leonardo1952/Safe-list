import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionHelper {
  static const String _keyString =
      'O83k2L9s6Q1w8R5v2T7y4N0b3H8d6F1c'; // 32 chars for AES-256
  static const String _separator = ':';

  static final encrypt.Key _key = encrypt.Key.fromUtf8(_keyString);
  static final encrypt.AES _aes =
      encrypt.AES(_key, mode: encrypt.AESMode.cbc, padding: 'PKCS7');
  static final encrypt.Encrypter _encrypter = encrypt.Encrypter(_aes);

  static String encryptText(String plainText) {
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypted = _encrypter.encrypt(plainText, iv: iv);
    return '${iv.base64}$_separator${encrypted.base64}';
  }

  static String? decryptText(String cipherText) {
    try {
      final parts = cipherText.split(_separator);
      if (parts.length != 2) return null;
      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
      return _encrypter.decrypt(encrypted, iv: iv);
    } catch (_) {
      return null;
    }
  }
}
