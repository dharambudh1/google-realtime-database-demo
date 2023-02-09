import "package:get/get.dart";
import "package:realtime_database_demo/models/user_model.dart";
import "package:realtime_database_demo/singleton/cryptography_singleton.dart";
import "package:realtime_database_demo/singleton/database_singleton.dart";
import "package:realtime_database_demo/singleton/function_singleton.dart";

enum PremiumUserEnum { no, yes }

class SignUpController extends GetxController {
  RxString fullName = "".obs;
  RxString birthDate = "".obs;
  RxString experience = "".obs;
  RxString phoneCode = "".obs;
  RxString phoneNumber = "".obs;
  RxString email = "".obs;
  RxString password = "".obs;
  Rx<PremiumUserEnum> premiumUserValue = PremiumUserEnum.values[0].obs;
  RxBool obscureText = true.obs;

  void updateUserBirthDate(String formattedDate) {
    birthDate(formattedDate);
    return;
  }

  void updateUserPhoneCode(String formattedPhoneCode) {
    phoneCode(formattedPhoneCode);
    return;
  }

  void onChangedPremiumUserValue(PremiumUserEnum? value) {
    premiumUserValue(value ?? PremiumUserEnum.values[0]);
    return;
  }

  void changeObscureText() {
    obscureText(obscureText.value = !obscureText.value);
    return;
  }

  Future<bool> isNumberExists() async {
    return Future<bool>.value(
      await DatabaseSingleton().isNumberExists(
        phoneNumber: phoneNumber.value,
      ),
    );
  }

  Future<bool> isEmailExists() async {
    return Future<bool>.value(
      await DatabaseSingleton().isEmailExists(
        email: email.value,
      ),
    );
  }

  UserModel getModelData() {
    return UserModel(
      fullName: fullName.value,
      birthDate: birthDate.value,
      experience: int.parse(experience.value),
      phoneCode: phoneCode.value,
      phoneNumber: phoneNumber.value,
      emailAddress: email.value,
      // password: password.value,
      password: CryptographySingleton().encryptMyData(password.value),
      isPremiumUser: premiumUserValue.value == PremiumUserEnum.yes,
      isVerifiedByPhone: false,
      createdAt: DateTime.now().toString(),
      updatedAt: DateTime.now().toString(),
    );
  }

  Future<void> skipOrContinue() async {
    await FunctionSingleton().skipOrContinue(
      snapshotKey: "",
      userModel: getModelData(),
      isVerified: false,
      isFromSignIn: false,
    );
    return Future<void>.value();
  }

  Future<void> navigateToOTP() async {
    await FunctionSingleton().navigateToOTP(
      snapshotKey: "",
      userModel: getModelData(),
    );
    return Future<void>.value();
  }
}
