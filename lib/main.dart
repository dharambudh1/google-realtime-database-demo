import "dart:async";
import "dart:developer";

import "package:country_picker/country_picker.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:get/get.dart";
import "package:keyboard_dismisser/keyboard_dismisser.dart";
import "package:realtime_database_demo/firebase_options.dart";
import "package:realtime_database_demo/screens/home_screen.dart";
import "package:realtime_database_demo/screens/login_screen.dart";
import "package:realtime_database_demo/singleton/analytics_singleton.dart";
import "package:realtime_database_demo/singleton/database_singleton.dart";
import "package:realtime_database_demo/singleton/error_handler_singleton.dart";
import "package:realtime_database_demo/singleton/storage_singleton.dart";

List<Map<dynamic, dynamic>> findOne = <Map<dynamic, dynamic>>[];

void main() async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await AnalyticsSingleton().analyticsInitialize();
      FlutterError.onError = (FlutterErrorDetails details) async {
        await ErrorHandlerSingleton().sendToCrashlytics(
          exception: details.exception,
          stackTrace: details.stack ?? StackTrace.current,
          hint: "FlutterError.onError",
          onError: true,
          shouldSendReportToCrashlytics: true,
        );
      };
      await AnalyticsSingleton().logAppOpen();
      await StorageSingleton().initStorage();
      final String storageKey = StorageSingleton().getKey();
      storageKey.isNotEmpty
          ? findOne = await DatabaseSingleton().findOne(key: storageKey)
          : log("storageKey isEmpty");
      runApp(const MyApp());
    },
    (Object error, StackTrace stack) async {
      await ErrorHandlerSingleton().sendToCrashlytics(
        exception: error,
        stackTrace: stack,
        hint: "runZonedGuarded",
        onError: false,
        shouldSendReportToCrashlytics: true,
      );
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: GetMaterialApp(
        navigatorKey: Get.key,
        navigatorObservers: <NavigatorObserver>[GetObserver()],
        title: "Realtime Database",
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorSchemeSeed: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: findOne.isNotEmpty ? const HomeScreen() : const LoginScreen(),
        // home: const SignInScreen(),
        debugShowCheckedModeBanner: false,
        enableLog: false,
        supportedLocales: const <Locale>[Locale("en")],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          CountryLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
