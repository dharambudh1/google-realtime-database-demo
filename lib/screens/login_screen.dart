import "dart:async";
import "dart:convert";
import "dart:developer";

import "package:after_layout/after_layout.dart";
import "package:country_picker/country_picker.dart";
import "package:flutter/material.dart";
import "package:fzregex/fzregex.dart";
import "package:fzregex/utils/pattern.dart";
import "package:get/get.dart";
import "package:realtime_database_demo/controllers/login_controller.dart";
import "package:realtime_database_demo/models/user_model.dart";
import "package:realtime_database_demo/screens/sign_up_screen.dart";
import "package:realtime_database_demo/singleton/analytics_singleton.dart";
import "package:realtime_database_demo/singleton/cryptography_singleton.dart";
import "package:realtime_database_demo/singleton/database_singleton.dart";
import "package:realtime_database_demo/singleton/function_singleton.dart";
import "package:realtime_database_demo/singleton/network_singleton.dart";
import "package:realtime_database_demo/singleton/storage_singleton.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with AfterLayoutMixin<LoginScreen> {
  final LoginController _controller = Get.put(LoginController());
  final TextEditingController _emailAddressController = TextEditingController();
  final TextEditingController _phoneCodeController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _emailAddressController.dispose();
    _phoneCodeController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _formKey.currentState?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Screen"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.navigate_next),
        onPressed: () async {
          if (_formKey.currentState?.validate() ?? false) {
            final bool isConnected = await NetworkSingleton().isConnected();
            if (isConnected) {
              if (_controller.currentIndex.value == 0) {
                if (!(await _controller.isEmailExists())) {
                  FunctionSingleton().showSnackBar(
                    text: "Email address is not exist, try another.",
                  );
                  return Future<void>.value();
                } else {
                  await decryptAndCheckPassword();
                }
              } else if (_controller.currentIndex.value == 1) {
                if (!(await _controller.isNumberExists())) {
                  FunctionSingleton().showSnackBar(
                    text: "Phone number is not exist, try another.",
                  );
                  return Future<void>.value();
                } else {
                  await decryptAndCheckPassword();
                }
              } else {}
            } else {
              FunctionSingleton().showSnackBar(
                text: "Please check your internet connection!",
              );
            }
          } else {}
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 50),
                const Text("Login with..."),
                const SizedBox(height: 10),
                ageGroupSelectionRadioListTile(),
                form(),
                const SizedBox(height: 50),
                Align(
                  child: TextButton(
                    onPressed: () async {
                      await Get.to(
                        () {
                          return const SignUpScreen();
                        },
                      );
                    },
                    child: const Text("Don't have an account yet? Sign Up"),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget form() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 100,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int value) async {
                final SignInTypeEnum enumValue = _controller.intToEnum(value);
                _controller
                  ..onChangedSignInTypeValue(enumValue)
                  ..updateCurrentIndex(value);
                await animateToPage(value);
              },
              itemCount: SignInTypeEnum.values.length,
              itemBuilder: (BuildContext context, int index) {
                return index == 0 ? index0() : index1();
              },
            ),
          ),
          Obx(
            () {
              return TextFormField(
                controller: _passwordController,
                onChanged: _controller.password,
                keyboardType: TextInputType.visiblePassword,
                validator: (String? value) {
                  return value == null || value.isEmpty
                      ? "Please fill out this field."
                      : !Fzregex.hasMatch(value, FzPattern.passwordHard)
                          ? "Please fill out valid input."
                          : null;
                },
                obscureText: _controller.obscureText.value,
                decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                    onPressed: _controller.changeObscureText,
                    icon: Icon(
                      _controller.obscureText.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
                textInputAction: TextInputAction.done,
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> animateToPage(int page) async {
    await _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
    );
    return Future<void>.value();
  }

  Widget index0() {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: _emailAddressController,
            onChanged: _controller.email,
            keyboardType: TextInputType.emailAddress,
            validator: (String? value) {
              return value == null || value.isEmpty
                  ? "Please fill out this field."
                  : !Fzregex.hasMatch(value, FzPattern.email)
                      ? "Please fill out valid input."
                      : null;
            },
            decoration: const InputDecoration(labelText: "Email Address"),
            textInputAction: TextInputAction.next,
          ),
        ),
      ],
    );
  }

  Widget index1() {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: _phoneCodeController,
            onChanged: _controller.phoneCode,
            keyboardType: TextInputType.phone,
            textCapitalization: TextCapitalization.words,
            validator: (String? value) {
              return value == null || value.isEmpty
                  ? "Please fill out this field."
                  : !Fzregex.hasMatch(value, FzPattern.phone)
                      ? "Please fill out valid input."
                      : null;
            },
            decoration: const InputDecoration(labelText: "Phone Code"),
            textInputAction: TextInputAction.next,
            readOnly: true,
            onTap: countryPicker,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: TextFormField(
            controller: _phoneNumberController,
            onChanged: _controller.phoneNumber,
            keyboardType: TextInputType.phone,
            textCapitalization: TextCapitalization.words,
            validator: (String? value) {
              return value == null || value.isEmpty
                  ? "Please fill out this field."
                  : !Fzregex.hasMatch(value, FzPattern.numericOnly)
                      ? "Please fill out valid input."
                      : null;
            },
            decoration: const InputDecoration(labelText: "Phone Number"),
            textInputAction: TextInputAction.next,
          ),
        ),
      ],
    );
  }

  Widget ageGroupSelectionRadioListTile() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: SignInTypeEnum.values.length,
      itemBuilder: (BuildContext context, int index) {
        final SignInTypeEnum ageEnum = SignInTypeEnum.values[index];
        return Obx(
          () {
            return Center(
              child: RadioListTile<SignInTypeEnum>(
                dense: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                activeColor: Colors.blue,
                contentPadding: EdgeInsets.zero,
                title: Text(signInTypeEnumTitle(ageEnum)),
                value: ageEnum,
                groupValue: _controller.signInTypeValue.value,
                onChanged: (SignInTypeEnum? value) async {
                  _controller.onChangedSignInTypeValue(value);
                  final int intValue = _controller.enumToInt(value);
                  _controller.updateCurrentIndex(intValue);
                  await animateToPage(intValue);
                },
              ),
            );
          },
        );
      },
    );
  }

  String signInTypeEnumTitle(SignInTypeEnum signInTypeEnum) {
    switch (signInTypeEnum) {
      case SignInTypeEnum.email:
        return "Email";
      case SignInTypeEnum.phone:
        return "Phone";
    }
  }

  void countryPicker() {
    return showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        final String formattedPhoneCode = "+${country.phoneCode}";
        _controller.updateUserPhoneCode(formattedPhoneCode);
        _phoneCodeController.text = formattedPhoneCode;
      },
    );
  }

  Future<void> decryptAndCheckPassword() async {
    List<Map<dynamic, dynamic>> data = <Map<dynamic, dynamic>>[];
    _controller.currentIndex.value == 0
        ? data = await DatabaseSingleton().getInfoFromEmail(
            email: _controller.email.value,
          )
        : _controller.currentIndex.value == 1
            ? data = await DatabaseSingleton().getInfoFromPhone(
                phoneCode: _controller.phoneCode.value,
                phoneNumber: _controller.phoneNumber.value,
              )
            : log("Error : decryptAndCheckPassword() : getDetails()");
    if (data.isNotEmpty) {
      final String encodedJson = json.encode(data[0]);
      final dynamic decodedJson = json.decode(encodedJson);
      final UserModel userModel = UserModel.fromJson(decodedJson);
      final String encrypted = userModel.password ?? "";
      final String decrypted = CryptographySingleton().decryptMyData(encrypted);
      decrypted == _controller.password.value
          ? _controller.currentIndex.value == 0
              ? await furtherSteps()
              : _controller.currentIndex.value == 1
                  ? userModel.isVerifiedByPhone ?? false
                      ? await furtherSteps()
                      : await cautionDialog()
                  : log("Error : decryptAndCheckPassword() : Cryptography()")
          : FunctionSingleton().showSnackBar(
              text: "Password doesn't match.",
            );
    } else if (data.isEmpty) {
      log("decryptAndCheckPassword() : data.isEmpty ");
    } else {
      log("furtherSteps() : Unknown error ");
    }
    return Future<void>.value();
  }

  Future<void> furtherSteps() async {
    final String snapshotKey = await setKey();
    if (snapshotKey.isNotEmpty) {
      await navigateToHome(snapshotKey);
    } else if (snapshotKey.isEmpty) {
      log("furtherSteps() : snapshotKey.isEmpty ");
    } else {
      log("furtherSteps() : Unknown error ");
    }

    return Future<void>.value();
  }

  Future<String> setKey() async {
    String keyId = "";
    _controller.currentIndex.value == 0
        ? keyId = await DatabaseSingleton().getIdFromEmail(
            email: _controller.email.value,
          )
        : _controller.currentIndex.value == 1
            ? keyId = await DatabaseSingleton().getIdFromPhone(
                phoneCode: _controller.phoneCode.value,
                phoneNumber: _controller.phoneNumber.value,
              )
            : log("setKey() : Unknown currentIndex");
    await StorageSingleton().setKey(keyId: keyId);
    return Future<String>.value(keyId);
  }

  Future<void> navigateToHome(String snapshotKey) async {
    _controller.resetSignInTypeValue();
    await FunctionSingleton().navigateToHome(
      snapshotKey: snapshotKey,
      isFromSignIn: true,
    );
    return Future<void>.value();
  }

  Future<void> cautionDialog() {
    return Future<void>.value(
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Forgot the phone number verification?"),
            content: const Text(
              // ignore: lines_longer_than_80_chars
              "We've found the associated credential for this account, but due to a lack of phone verification, we won't let you sign in with your phone number. Please sign in by email first & verifying your phone number.",
            ),
            actions: <Widget>[
              FilledButton(
                child: const Text("Okay"),
                onPressed: () async {
                  Get.back();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    await AnalyticsSingleton().setCurrentScreen(screenName: "Login Screen");
    return Future<void>.value();
  }
}
