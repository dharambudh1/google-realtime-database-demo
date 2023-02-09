import "dart:convert";

import "package:get/get_state_manager/get_state_manager.dart";
import "package:realtime_database_demo/models/user_model.dart";
import "package:realtime_database_demo/singleton/function_singleton.dart";
import "package:realtime_database_demo/singleton/storage_singleton.dart";

class HomeController extends GetxController {
  bool isMe(String snapshotKey) {
    return snapshotKey == StorageSingleton().getKey();
  }

  UserModel getData(Object snapshotValue) {
    final String encodedJson = json.encode(snapshotValue);
    final dynamic decodedJson = json.decode(encodedJson);
    final UserModel userModel = UserModel.fromJson(decodedJson);
    return userModel;
  }

  Future<void> navigateToOTP({
    required String snapshotKey,
    required UserModel userModel,
  }) async {
    await FunctionSingleton().navigateToOTP(
      snapshotKey: snapshotKey,
      userModel: userModel,
    );
    return Future<void>.value();
  }
}
