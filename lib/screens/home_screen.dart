import "dart:async";
import "dart:developer";

import "package:after_layout/after_layout.dart";
import "package:firebase_database/firebase_database.dart";
import "package:firebase_database/ui/firebase_animated_list.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:modal_bottom_sheet/modal_bottom_sheet.dart";
import "package:realtime_database_demo/controllers/home_controller.dart";
import "package:realtime_database_demo/models/user_model.dart";
import "package:realtime_database_demo/screens/login_screen.dart";
import "package:realtime_database_demo/singleton/analytics_singleton.dart";
import "package:realtime_database_demo/singleton/database_singleton.dart";
import "package:realtime_database_demo/singleton/error_handler_singleton.dart";
import "package:realtime_database_demo/singleton/function_singleton.dart";
import "package:realtime_database_demo/singleton/storage_singleton.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, AfterLayoutMixin<HomeScreen> {
  final HomeController _controller = Get.put(HomeController());
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Database"),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
              ),
              onPressed: showBottomSheet,
              child: const Icon(Icons.new_releases_outlined),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
              ),
              onPressed: () async {
                await StorageSingleton().erase();
                await Get.offAll(const LoginScreen());
              },
              child: const Icon(Icons.logout_outlined),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(icon: Icon(Icons.face), text: "Me"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: FirebaseAnimatedList(
              query: DatabaseSingleton().ref,
              itemBuilder: (
                BuildContext context,
                DataSnapshot snapshot,
                Animation<double> animation,
                int index,
              ) {
                // final String encodedJson = json.encode(snapshot.value);
                // final dynamic decodedJson = json.decode(encodedJson);
                // final UserModel userModel = UserModel.fromJson(decodedJson);
                return _controller.isMe(snapshot.key ?? "")
                    ? sizeTransition(
                        context,
                        snapshot,
                        animation,
                        index,
                      )
                    : const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget sizeTransition(
    BuildContext context,
    DataSnapshot snapshot,
    Animation<double> animation,
    int index,
  ) {
    final UserModel userModel = _controller.getData(snapshot.value ?? Object());
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: <Widget>[
            ListTile(
              title: const Text("ID"),
              subtitle: Text(snapshot.key ?? ""),
              leading: const Icon(Icons.numbers),
            ),
            ListTile(
              title: const Text("Full Name"),
              subtitle: Text(userModel.fullName ?? ""),
              leading: const Icon(Icons.person),
            ),
            ListTile(
              title: const Text("Date of Birth"),
              subtitle: Text(userModel.birthDate ?? ""),
              leading: const Icon(Icons.cake),
            ),
            ListTile(
              title: const Text("Experience"),
              subtitle: Text(userModel.experience.toString()),
              leading: const Icon(Icons.work_history),
            ),
            ListTile(
              title: const Text("Phone Code"),
              subtitle: Text(userModel.phoneCode.toString()),
              leading: const Icon(Icons.dialpad),
            ),
            ListTile(
              title: const Text("Phone Number"),
              subtitle: Text(userModel.phoneNumber.toString()),
              leading: const Icon(Icons.call),
            ),
            ListTile(
              title: const Text("Email Address"),
              subtitle: Text(userModel.emailAddress ?? ""),
              leading: const Icon(Icons.alternate_email),
            ),
            ListTile(
              title: const Text("Premium User"),
              subtitle: Text(userModel.isPremiumUser.toString()),
              leading: const Icon(Icons.star),
            ),
            ListTile(
              title: const Text("Verified User"),
              subtitle: Text(userModel.isVerifiedByPhone.toString()),
              leading: const Icon(Icons.verified),
              trailing: !(userModel.isVerifiedByPhone ?? false)
                  ? TextButton(
                      onPressed: () async {
                        await _controller.navigateToOTP(
                          snapshotKey: snapshot.key ?? "",
                          userModel: userModel,
                        );
                      },
                      child: const Text("Verify"),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showBottomSheet() async {
    await showBarModalBottomSheet(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: 10,
            ),
            ListTile(
              title: const Text("Success"),
              subtitle: const Text("Call A Successful Function"),
              leading: const Icon(Icons.check_circle),
              onTap: () async {
                Get.back();
                await transporter(onTryFunction: successfulFunction);
              },
            ),
            ListTile(
              title: const Text("Exception"),
              subtitle: const Text("Throw A Known Exception"),
              leading: const Icon(Icons.report),
              onTap: () async {
                Get.back();
                await transporter(onTryFunction: throwAKnownException);
              },
            ),
            ListTile(
              title: const Text("Error"),
              subtitle: const Text("Throw An Unknown Error"),
              leading: const Icon(Icons.error),
              onTap: () async {
                Get.back();
                await transporter(onTryFunction: throwAnUnknownError);
              },
            ),
            const SizedBox(
              height: 24,
            ),
          ],
        );
      },
    );
    return Future<void>.value();
  }

  // Successfully execute
  void successfulFunction() {
    log("came to testFunction");
    return;
  }

  // Exception caught
  void throwAKnownException() {
    throw Exception("Crash : ${DateTime.now()}");
  }

  // Error occurred
  void throwAnUnknownError() {
    final Error error = ArgumentError("Crash : ${DateTime.now()}");
    throw error;
  }

  Future<void> transporter({
    required Function() onTryFunction,
  }) async {
    await ErrorHandlerSingleton().handlerMethod(
      // if true, it will reflect to:
      // Android: https://console.firebase.google.com/project/realtime-database-demo-ed1c0/crashlytics/app/android:com.example.realtime_database_demo
      // iOS: https://console.firebase.google.com/project/realtime-database-demo-ed1c0/crashlytics/app/ios:com.app.notificationapps
      shouldSendReportToCrashlytics: true,

      // use suspicious method call here
      onTryFunction: () async {
        await onTryFunction();
      },

      // what if suspicious method successfully completed
      onExecutionSuccessfullyCompleted: () async {
        log("came to executionSuccessfullyCompleted");
        log("Executed successfully.");
        FunctionSingleton().showSnackBar(text: "Executed successfully.");
      },

      // what if they caught an known exception
      onExceptionCaught: (Exception exception, StackTrace stackTrace) async {
        log("came to onExceptionCaught");
        log("Crash report sent.");
        FunctionSingleton().showSnackBar(text: "Crash report sent.");
      },

      // what if they got an unknown error
      onErrorOccurred: (Object object, StackTrace stackTrace) async {
        log("came to onErrorOccurred");
        log("Crash report sent.");
        FunctionSingleton().showSnackBar(text: "Crash report sent.");
      },

      // what if finally called
      onFinallyCalled: (ErrorStatus errorStatus) async {
        log("came to onFinallyCalled");
        switch (errorStatus) {
          case ErrorStatus.success:
            log("Yay : $errorStatus");
            break;
          case ErrorStatus.failure:
            log("Oops : $errorStatus");
            break;
          case ErrorStatus.unknown:
            log("Oh : $errorStatus");
            break;
        }
      },
    );
    return Future<void>.value();
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    await AnalyticsSingleton().setCurrentScreen(screenName: "Home Screen");
    return Future<void>.value();
  }
}
