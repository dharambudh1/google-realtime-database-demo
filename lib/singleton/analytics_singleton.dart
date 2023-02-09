import "dart:developer";

import "package:firebase_analytics/firebase_analytics.dart";

class AnalyticsSingleton {
  factory AnalyticsSingleton() {
    return _singleton;
  }

  AnalyticsSingleton._internal();

  static final AnalyticsSingleton _singleton = AnalyticsSingleton._internal();

  FirebaseAnalytics instance = FirebaseAnalytics.instance;

  Future<void> analyticsInitialize() async {
    final bool isSupported = await instance.isSupported();
    log("analyticsInitialize() : isSupported: $isSupported");
    await instance.setAnalyticsCollectionEnabled(isSupported);
    log("analyticsInitialize() : setAnalyticsCollectionEnabled: $isSupported");
    return Future<void>.value();
  }

  Future<void> logAppOpen() async {
    await instance.logAppOpen();
    log("logAppOpen() called");
    return Future<void>.value();
  }

  Future<void> logSignUp() async {
    await instance.logSignUp(signUpMethod: "sign_up");
    log("logSignUp() called");
    return Future<void>.value();
  }

  Future<void> logLogin() async {
    await instance.logLogin(loginMethod: "login");
    log("logLogin() called");
    return Future<void>.value();
  }

  Future<void> setCurrentScreen({required String screenName}) async {
    await instance.setCurrentScreen(screenName: screenName);
    log("setCurrentScreen(): $screenName");
    return Future<void>.value();
  }
}
