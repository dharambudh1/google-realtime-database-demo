import "dart:developer";

import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:realtime_database_demo/models/user_model.dart";
import "package:realtime_database_demo/screens/home_screen.dart";
import "package:realtime_database_demo/screens/otp_verify_screen.dart";
import "package:realtime_database_demo/singleton/analytics_singleton.dart";
import "package:realtime_database_demo/singleton/database_singleton.dart";
import "package:realtime_database_demo/singleton/storage_singleton.dart";

class FunctionSingleton {
  factory FunctionSingleton() {
    return _singleton;
  }

  FunctionSingleton._internal();

  static final FunctionSingleton _singleton = FunctionSingleton._internal();

  Future<void> skipOrContinue({
    required String snapshotKey,
    required UserModel userModel,
    required bool isVerified,
    required bool isFromSignIn,
  }) async {
    await FunctionSingleton().insertOrUpdateRecord(
      snapshotKey: snapshotKey,
      userModel: userModel,
      isVerified: isVerified,
    );
    await StorageSingleton().setKey(
      keyId: await DatabaseSingleton().getKeyOfLastInsertedData(),
    );
    await FunctionSingleton().navigateToHome(
      snapshotKey: snapshotKey,
      isFromSignIn: isFromSignIn,
    );
    return Future<void>.value();
  }

  Future<void> insertOrUpdateRecord({
    required String snapshotKey,
    required UserModel userModel,
    required bool isVerified,
  }) async {
    userModel.isVerifiedByPhone = isVerified;
    snapshotKey.isEmpty
        ? await DatabaseSingleton().insertOne(
            userModel: userModel.toJson(),
          )
        : await DatabaseSingleton().updateOne(
            key: snapshotKey,
            userModel: userModel.toJson(),
          );
    return Future<void>.value();
  }

  Future<void> navigateToHome({
    required String snapshotKey,
    required bool isFromSignIn,
  }) async {
    snapshotKey.isNotEmpty && isFromSignIn
        ? await AnalyticsSingleton().logLogin()
        : snapshotKey.isEmpty && !isFromSignIn
            ? await AnalyticsSingleton().logSignUp()
            : snapshotKey.isNotEmpty && !isFromSignIn
                ? log("Get.back() : Navigate back to Home Screen")
                : log("Unknown error on navigateToHome() while sending logs");
    snapshotKey.isNotEmpty && isFromSignIn
        ? await Get.offAll(const HomeScreen())
        : snapshotKey.isEmpty && !isFromSignIn
            ? await Get.offAll(const HomeScreen())
            : snapshotKey.isNotEmpty && !isFromSignIn
                ? Get.back()
                : log("Unknown error on navigateToHome() while navigate");
    // snapshotKey.isEmpty ? await Get.offAll(const HomeScreen()) : Get.back();
    return Future<void>.value();
  }

  Future<void> navigateToOTP({
    required String snapshotKey,
    required UserModel userModel,
  }) async {
    await Get.to(
      () {
        return OTPVerifyScreen(
          snapshotKey: snapshotKey,
          userModel: userModel,
        );
      },
    );
    return Future<void>.value();
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar({
    required String text,
  }) {
    return ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }
}
