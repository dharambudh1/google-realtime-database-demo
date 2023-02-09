import "package:get/get.dart";
import "package:realtime_database_demo/models/user_model.dart";

class OTPVerifyController extends GetxController {
  RxList<String> authDomain = <String>[
    "localhost",
    "realtime-database-demo-ed1c0.firebaseapp.com",
    "realtime-database-demo-ed1c0.web.app",
  ].obs;

  RxString verificationID = "".obs;
  Rx<String> snapshotKey = "".obs;
  Rx<UserModel> userModel = UserModel().obs;
  Rx<String> otpNumber = "".obs;

  void updateVerificationID(String value) {
    verificationID(value);
    return;
  }

  void updateSnapshotKey(String value) {
    snapshotKey(value);
    return;
  }

  void updateUserModel(UserModel value) {
    userModel(value);
    return;
  }

  void updateOtpNumber(String value) {
    otpNumber(value);
    return;
  }

  String getFullNumber() {
    return (userModel.value.phoneCode ?? "") +
        (userModel.value.phoneNumber ?? "");
  }

  UserModel getModelData() {
    return UserModel(
      fullName: userModel.value.fullName,
      birthDate: userModel.value.birthDate,
      experience: userModel.value.experience,
      phoneCode: userModel.value.phoneCode,
      phoneNumber: userModel.value.phoneNumber,
      emailAddress: userModel.value.emailAddress,
      password: userModel.value.password,
      isPremiumUser: userModel.value.isPremiumUser,
      isVerifiedByPhone: false,
      createdAt: snapshotKey.value.isNotEmpty
          ? userModel.value.createdAt
          : DateTime.now().toString(),
      updatedAt: DateTime.now().toString(),
    );
  }
}
