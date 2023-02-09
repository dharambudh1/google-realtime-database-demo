import "dart:async";

import "package:after_layout/after_layout.dart";
import "package:country_picker/country_picker.dart";
import "package:flutter/material.dart";
import "package:fzregex/fzregex.dart";
import "package:fzregex/utils/pattern.dart";
import "package:get/get.dart";
import "package:intl/intl.dart";
import "package:realtime_database_demo/controllers/sign_up_controller.dart";
import "package:realtime_database_demo/singleton/analytics_singleton.dart";
import "package:realtime_database_demo/singleton/function_singleton.dart";
import "package:realtime_database_demo/singleton/network_singleton.dart";

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with AfterLayoutMixin<SignUpScreen> {
  final SignUpController _controller = Get.put(SignUpController());
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _phoneCodeController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailAddressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _fullNameController.dispose();
    _birthDateController.dispose();
    _experienceController.dispose();
    _phoneCodeController.dispose();
    _phoneNumberController.dispose();
    _emailAddressController.dispose();
    _passwordController.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign-up Screen"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.navigate_next),
        onPressed: () async {
          if (_formKey.currentState?.validate() ?? false) {
            final bool isConnected = await NetworkSingleton().isConnected();
            if (isConnected) {
              if (await _controller.isNumberExists()) {
                FunctionSingleton().showSnackBar(
                  text: "Phone number is already exist, try another.",
                );
                return Future<void>.value();
              }
              if (await _controller.isEmailExists()) {
                FunctionSingleton().showSnackBar(
                  text: "Email address is already exist, try another.",
                );
                return Future<void>.value();
              }
              await decisionDialog();
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
            child: form(),
          ),
        ),
      ),
    );
  }

  Widget form() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _fullNameController,
            onChanged: _controller.fullName,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.words,
            validator: (String? value) {
              return value == null || value.isEmpty
                  ? "Please fill out this field."
                  : !Fzregex.hasMatch(value, FzPattern.name)
                      ? "Please fill out valid input."
                      : null;
            },
            decoration: const InputDecoration(labelText: "Full Name"),
            textInputAction: TextInputAction.next,
          ),
          TextFormField(
            controller: _birthDateController,
            onChanged: _controller.birthDate,
            keyboardType: TextInputType.datetime,
            textCapitalization: TextCapitalization.words,
            validator: (String? value) {
              return value == null || value.isEmpty
                  ? "Please fill out this field."
                  : null;
            },
            decoration: const InputDecoration(labelText: "Birth Date"),
            textInputAction: TextInputAction.next,
            readOnly: true,
            onTap: datePicker,
          ),
          TextFormField(
            controller: _experienceController,
            onChanged: _controller.experience,
            keyboardType: TextInputType.number,
            textCapitalization: TextCapitalization.words,
            validator: (String? value) {
              return value == null || value.isEmpty
                  ? "Please fill out this field."
                  : !Fzregex.hasMatch(value, FzPattern.numericOnly)
                      ? "Please fill out valid input."
                      : null;
            },
            decoration: const InputDecoration(labelText: "Experience"),
            textInputAction: TextInputAction.next,
          ),
          Row(
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
          ),
          TextFormField(
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
          const SizedBox(height: 24),
          const Text("🔘 Minimum character: 8"),
          const Text("🔘 Allowing all character except 'whitespace'"),
          const Text(
            // ignore: lines_longer_than_80_chars
            "🔘 Must contains at least: 1 uppercase letter, 1 lowecase letter, 1 number, & 1 special character (symbol)",
          ),
          const SizedBox(height: 24),
          const Text("Do want to be a Premium user?"),
          const SizedBox(height: 10),
          ageGroupSelectionRadioListTile(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Future<void> datePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      final String formattedDate = DateFormat("yyyy-MM-dd").format(pickedDate);
      _controller.updateUserBirthDate(formattedDate);
      _birthDateController.text = formattedDate;
    } else {}
    return Future<void>.value();
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

  Widget ageGroupSelectionRadioListTile() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: PremiumUserEnum.values.length,
      itemBuilder: (BuildContext context, int index) {
        final PremiumUserEnum ageEnum = PremiumUserEnum.values[index];
        return Obx(
          () {
            return Center(
              child: RadioListTile<PremiumUserEnum>(
                dense: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                activeColor: Colors.blue,
                contentPadding: EdgeInsets.zero,
                title: Text(premiumUserEnumTitle(ageEnum)),
                value: ageEnum,
                groupValue: _controller.premiumUserValue.value,
                onChanged: _controller.onChangedPremiumUserValue,
              ),
            );
          },
        );
      },
    );
  }

  String premiumUserEnumTitle(PremiumUserEnum ageEnum) {
    switch (ageEnum) {
      case PremiumUserEnum.no:
        return "No";
      case PremiumUserEnum.yes:
        return "Yes";
    }
  }

  Future<void> decisionDialog() {
    return Future<void>.value(
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Skip phone number verification?"),
            content: const Text(
              // ignore: lines_longer_than_80_chars
              "You won't be able to sign in with your phone number until & unless you verify your phone number with us.",
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Skip"),
                onPressed: () async {
                  Get.back();
                  await _controller.skipOrContinue();
                },
              ),
              FilledButton(
                child: const Text("Verify"),
                onPressed: () async {
                  Get.back();
                  await _controller.navigateToOTP();
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
    await AnalyticsSingleton().setCurrentScreen(screenName: "Sign-up Screen");
    return Future<void>.value();
  }
}
