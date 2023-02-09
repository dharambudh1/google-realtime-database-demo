import "package:get/get.dart";
import "package:realtime_database_demo/singleton/database_singleton.dart";

enum SignInTypeEnum { email, phone }

class LoginController extends GetxController {
  RxString email = "".obs;
  RxString phoneCode = "".obs;
  RxString phoneNumber = "".obs;
  RxString password = "".obs;
  Rx<SignInTypeEnum> signInTypeValue = SignInTypeEnum.values[0].obs;
  RxInt currentIndex = 0.obs;
  RxBool obscureText = true.obs;

  void updateUserPhoneCode(String formattedPhoneCode) {
    phoneCode(formattedPhoneCode);
    return;
  }

  void onChangedSignInTypeValue(SignInTypeEnum? value) {
    signInTypeValue(value ?? SignInTypeEnum.values[0]);
    return;
  }

  void resetSignInTypeValue() {
    signInTypeValue(SignInTypeEnum.values[0]);
    return;
  }

  void updateCurrentIndex(int value) {
    currentIndex(value);
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

  int enumToInt(SignInTypeEnum? value) {
    switch (value ?? SignInTypeEnum.values[0]) {
      case SignInTypeEnum.email:
        return 0;
      case SignInTypeEnum.phone:
        return 1;
    }
  }

  SignInTypeEnum intToEnum(int intValue) {
    switch (intValue) {
      case 0:
        return SignInTypeEnum.email;
      case 1:
        return SignInTypeEnum.phone;
      default:
        return SignInTypeEnum.email;
    }
  }
}
