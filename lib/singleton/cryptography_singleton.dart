import "package:encrypt/encrypt.dart";

class CryptographySingleton {
  factory CryptographySingleton() {
    return _singleton;
  }

  CryptographySingleton._internal();

  static final CryptographySingleton _singleton =
      CryptographySingleton._internal();

  static Key key = Key.fromUtf8("82CUuvQYcPCsN2j1lwpYv0bb2lYn8fmg");
  final IV iv = IV.fromUtf8("AAKdpwIC4K7u6diN");
  final Encrypter e = Encrypter(AES(key, mode: AESMode.cbc));

  String encryptMyData(String text) {
    final Encrypted encryptedData = e.encrypt(text, iv: iv);
    return encryptedData.base64;
  }

  String decryptMyData(String text) {
    final String decryptedData = e.decrypt(Encrypted.fromBase64(text), iv: iv);
    return decryptedData;
  }
}
