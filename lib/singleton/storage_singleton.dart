import "package:get_storage/get_storage.dart";

class StorageSingleton {
  factory StorageSingleton() {
    return _singleton;
  }

  StorageSingleton._internal();

  static final StorageSingleton _singleton = StorageSingleton._internal();

  final GetStorage globalGetStorage = GetStorage();
  final String myKey = "GetStorageKey";

  Future<void> initStorage() async {
    await GetStorage().initStorage;
    return Future<void>.value();
  }

  Future<void> setKey({required String keyId}) async {
    await globalGetStorage.write(myKey, keyId);
    return Future<void>.value();
  }

  String getKey() {
    final String keyId = globalGetStorage.read<String>(myKey) ?? "";
    return keyId;
  }

  Future<void> erase() async {
    await globalGetStorage.erase();
    return Future<void>.value();
  }
}
