import "dart:async";
import "dart:developer";
import "dart:io";

import "package:after_layout/after_layout.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:get/get.dart";
import "package:pinput/pinput.dart";
import "package:realtime_database_demo/controllers/otp_verify_controller.dart";
import "package:realtime_database_demo/models/user_model.dart";
import "package:realtime_database_demo/singleton/analytics_singleton.dart";
import "package:realtime_database_demo/singleton/function_singleton.dart";
import "package:realtime_database_demo/singleton/network_singleton.dart";
import "package:telephony/telephony.dart";

class OTPVerifyScreen extends StatefulWidget {
  const OTPVerifyScreen({
    required this.snapshotKey,
    required this.userModel,
    super.key,
  });

  final String snapshotKey;
  final UserModel userModel;

  @override
  State<OTPVerifyScreen> createState() => _OTPVerifyScreenState();
}

class _OTPVerifyScreenState extends State<OTPVerifyScreen>
    with AfterLayoutMixin<OTPVerifyScreen> {
  final OTPVerifyController _controller = Get.put(OTPVerifyController());
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller
      ..updateSnapshotKey(widget.snapshotKey)
      ..updateUserModel(widget.userModel);
    if (Platform.isAndroid) {
      try {
        Telephony.instance.listenIncomingSms(
          onNewMessage: (SmsMessage message) async {
            final String body = message.body ?? "";
            final bool condStmt1 = body.contains(_controller.authDomain[0]);
            final bool condStmt2 = body.contains(_controller.authDomain[1]);
            final bool condStmt3 = body.contains(_controller.authDomain[2]);
            if (condStmt1 || condStmt2 || condStmt3) {
              _controller.updateOtpNumber(
                body[0] + body[1] + body[2] + body[3] + body[4] + body[5],
              );
              _otpController.text =
                  body[0] + body[1] + body[2] + body[3] + body[4] + body[5];
              await verifyOTP();
            } else {}
          },
          listenInBackground: false,
        );
      } on PlatformException catch (e) {
        log("Telephony.instance.listenIncomingSms() : code: ${e.code}");
        log("Telephony.instance.listenIncomingSms() : message: ${e.message}");
        log("Telephony.instance.listenIncomingSms() : details: ${e.details}");
        log("Telephony.instance.listenIncomingSms() : stack: ${e.stacktrace}");
      }
    } else {}
  }

  @override
  void dispose() {
    _otpController.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("OTP Verify"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.navigate_next),
        onPressed: () async {
          if (_formKey.currentState?.validate() ?? false) {
            await verifyOTP();
          } else {}
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 100),
                const Text("Enter the code sent to the number"),
                const SizedBox(height: 24),
                Text(_controller.getFullNumber()),
                const SizedBox(height: 24),
                form(),
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
      child: Pinput(
        controller: _otpController,
        onChanged: _controller.otpNumber,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        validator: (String? value) {
          return value == null || value.isEmpty
              ? "Please fill out this field."
              : value.length != 6
                  ? "Please fill out valid input."
                  : null;
        },
        length: 6,
      ),
    );
  }

  Future<void> loginWithPhone() async {
    final bool isConnected = await NetworkSingleton().isConnected();
    if (isConnected) {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _controller.getFullNumber(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await signingIn(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == "invalid-phone-number") {
            log(e.message.toString());
            FunctionSingleton().showSnackBar(
              text: "The provided phone number is not valid.",
            );
          } else {
            log(e.message.toString());
            FunctionSingleton().showSnackBar(
              text: e.message.toString(),
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          _controller.updateVerificationID(verificationId);
          log("codeSent verificationID: $verificationId");
          log("codeSent resendToken:    $resendToken");
          setState(() {});
        },
        timeout: const Duration(seconds: 120),
        codeAutoRetrievalTimeout: (String verificationId) {
          log("codeAutoRetrievalTimeout verificationId: $verificationId");
        },
      );
    } else {
      FunctionSingleton().showSnackBar(
        text: "Please check your internet connection!",
      );
    }
    return Future<void>.value();
  }

  Future<void> verifyOTP() async {
    final bool isConnected = await NetworkSingleton().isConnected();
    if (isConnected) {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _controller.verificationID.value,
        smsCode: _controller.otpNumber.value,
      );
      await signingIn(credential);
    } else {
      FunctionSingleton().showSnackBar(
        text: "Please check your internet connection!",
      );
    }
    return Future<void>.value();
  }

  Future<void> signingIn(PhoneAuthCredential credential) async {
    try {
      final UserCredential cred;
      cred = await FirebaseAuth.instance.signInWithCredential(credential);
      await cred.user?.delete();
      await FirebaseAuth.instance.signOut();
      await FunctionSingleton().skipOrContinue(
        snapshotKey: _controller.snapshotKey.value,
        userModel: _controller.getModelData(),
        isVerified: true,
        isFromSignIn: false,
      );
    } on FirebaseAuthException catch (e) {
      log("Error occurred: $e");
      FunctionSingleton().showSnackBar(
        text: "An entered OTP is invalid and please enter the correct OTP.",
      );
    }
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    await AnalyticsSingleton().setCurrentScreen(screenName: "OTP Screen");
    await loginWithPhone();
    return Future<void>.value();
  }
}
