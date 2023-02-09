import "dart:developer";

import "package:firebase_database/firebase_database.dart";

class DatabaseSingleton {
  factory DatabaseSingleton() {
    return _singleton;
  }

  DatabaseSingleton._internal();

  static final DatabaseSingleton _singleton = DatabaseSingleton._internal();

  final DatabaseReference ref = FirebaseDatabase.instance.ref().child("Users");

  /* Check if exists start */
  Future<bool> isNumberExists({
    required String phoneNumber,
  }) async {
    bool exist = false;
    final DataSnapshot dataSnapshot = await ref.get();
    for (final DataSnapshot element in dataSnapshot.children) {
      if (element.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> map = <dynamic, dynamic>{};
        map = (element.value ?? <dynamic, dynamic>{}) as Map<dynamic, dynamic>;
        if (map.isNotEmpty) {
          if (map.containsKey("phone_number")) {
            if (map["phone_number"] == phoneNumber) {
              exist = true;
            } else {}
          } else {
            log("isNumberExists(): Map doesn't containsKey: phone_number");
          }
        } else {
          log("isNumberExists(): Map isEmpty");
        }
      } else {
        log("isNumberExists(): element.value is not Map");
      }
    }
    return Future<bool>.value(exist);
  }

  Future<bool> isEmailExists({
    required String email,
  }) async {
    bool exist = false;
    final DataSnapshot dataSnapshot = await ref.get();
    for (final DataSnapshot element in dataSnapshot.children) {
      if (element.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> map = <dynamic, dynamic>{};
        map = (element.value ?? <dynamic, dynamic>{}) as Map<dynamic, dynamic>;
        if (map.isNotEmpty) {
          if (map.containsKey("email_address")) {
            if (map["email_address"] == email) {
              exist = true;
            } else {}
          } else {
            log("isEmailExists() : Map doesn't containsKey: email_address");
          }
        } else {
          log("isEmailExists(): Map isEmpty");
        }
      } else {
        log("isEmailExists(): element.value is not Map");
      }
    }
    return Future<bool>.value(exist);
  }

  /* Check if exists end */

  /* Data creation start */
  Future<void> insertAll({
    required List<Map<String, dynamic>> userModelList,
  }) async {
    await Future.forEach(
      userModelList,
      (Map<dynamic, dynamic> item) async {
        await ref.push().set(item);
      },
    );
    return Future<void>.value();
  }

  Future<void> insertOne({
    required Map<String, dynamic> userModel,
  }) async {
    await ref.push().set(userModel);
    return Future<void>.value();
  }

  Future<String> getKeyOfLastInsertedData() async {
    final DataSnapshot dataSnapshot = await ref.get();
    String key = "";
    if (dataSnapshot.children.isEmpty) {
      log("getKeyOfLastInsertedData(): dataSnapshot.children.isEmpty");
    } else {
      key = dataSnapshot.children.last.key ?? "";
    }
    return Future<String>.value(key);
  }

  /* Data creation end */

  /* Data finding start */
  Future<List<Map<dynamic, dynamic>>> findAll() async {
    final List<Map<dynamic, dynamic>> list = <Map<dynamic, dynamic>>[];
    final DataSnapshot dataSnapshot = await ref.get();
    for (final DataSnapshot element in dataSnapshot.children) {
      if (element.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> map = <dynamic, dynamic>{};
        map = (element.value ?? <dynamic, dynamic>{}) as Map<dynamic, dynamic>;
        if (map.isNotEmpty) {
          list.add(map);
        } else {
          log("findAll(): Map isEmpty");
        }
      } else {
        log("findAll(): element.value is not Map");
      }
    }
    return Future<List<Map<dynamic, dynamic>>>.value(list);
  }

  Future<List<Map<dynamic, dynamic>>> findOne({
    required String key,
  }) async {
    final List<Map<dynamic, dynamic>> list = <Map<dynamic, dynamic>>[];
    final DataSnapshot dataSnapshot = await ref.get();
    for (final DataSnapshot element in dataSnapshot.children) {
      if (element.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> map = <dynamic, dynamic>{};
        map = (element.value ?? <dynamic, dynamic>{}) as Map<dynamic, dynamic>;
        if (map.isNotEmpty) {
          if (element.key == key) {
            list.add(map);
          } else {
            log("findOne() : Map doesn't containsKey: $key");
          }
        } else {
          log("findOne(): Map isEmpty");
        }
      } else {
        log("findOne(): element.value is not Map");
      }
    }
    return Future<List<Map<dynamic, dynamic>>>.value(list);
  }

  Future<List<Map<dynamic, dynamic>>> getInfoFromEmail({
    required String email,
  }) async {
    final List<Map<dynamic, dynamic>> list = <Map<dynamic, dynamic>>[];
    final DataSnapshot dataSnapshot = await ref.get();
    for (final DataSnapshot element in dataSnapshot.children) {
      if (element.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> map = <dynamic, dynamic>{};
        map = (element.value ?? <dynamic, dynamic>{}) as Map<dynamic, dynamic>;
        if (map.isNotEmpty) {
          if (map.containsKey("email_address")) {
            if (map["email_address"] == email) {
              list.add(map);
            } else {}
          } else {
            log("getInfoFromEmail() : Map doesn't containsKey: email_address");
          }
        } else {
          log("getInfoFromEmail(): Map isEmpty");
        }
      } else {
        log("getInfoFromEmail(): element.value is not Map");
      }
    }
    return Future<List<Map<dynamic, dynamic>>>.value(list);
  }

  Future<String> getIdFromEmail({
    required String email,
  }) async {
    String id = "";
    final DataSnapshot dataSnapshot = await ref.get();
    for (final DataSnapshot element in dataSnapshot.children) {
      if (element.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> map = <dynamic, dynamic>{};
        map = (element.value ?? <dynamic, dynamic>{}) as Map<dynamic, dynamic>;
        if (map.isNotEmpty) {
          if (map.containsKey("email_address")) {
            if (map["email_address"] == email) {
              id = element.key ?? "";
            } else {}
          } else {
            log("getIdFromEmail() : Map doesn't containsKey: email_address");
          }
        } else {
          log("getIdFromEmail(): Map isEmpty");
        }
      } else {
        log("getIdFromEmail(): element.value is not Map");
      }
    }
    return Future<String>.value(id);
  }

  Future<List<Map<dynamic, dynamic>>> getInfoFromPhone({
    required String phoneCode,
    required String phoneNumber,
  }) async {
    final List<Map<dynamic, dynamic>> list = <Map<dynamic, dynamic>>[];
    final DataSnapshot dataSnapshot = await ref.get();
    for (final DataSnapshot element in dataSnapshot.children) {
      if (element.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> map = <dynamic, dynamic>{};
        map = (element.value ?? <dynamic, dynamic>{}) as Map<dynamic, dynamic>;
        if (map.isNotEmpty) {
          final bool outerCondition1 = map.containsKey("phone_code");
          final bool outerCondition2 = map.containsKey("phone_number");
          if (outerCondition1 && outerCondition2) {
            final bool innerCondition1 = map["phone_code"] == phoneCode;
            final bool innerCondition2 = map["phone_number"] == phoneNumber;
            if (innerCondition1 && innerCondition2) {
              list.add(map);
            } else {}
          } else {
            log("getInfoFromPhone() : Map doesn't containsKey: password");
          }
        } else {
          log("getInfoFromPhone(): Map isEmpty");
        }
      } else {
        log("getInfoFromPhone(): element.value is not Map");
      }
    }
    return Future<List<Map<dynamic, dynamic>>>.value(list);
  }

  Future<String> getIdFromPhone({
    required String phoneCode,
    required String phoneNumber,
  }) async {
    String id = "";
    final DataSnapshot dataSnapshot = await ref.get();
    for (final DataSnapshot element in dataSnapshot.children) {
      if (element.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> map = <dynamic, dynamic>{};
        map = (element.value ?? <dynamic, dynamic>{}) as Map<dynamic, dynamic>;
        if (map.isNotEmpty) {
          final bool outerCondition1 = map.containsKey("phone_code");
          final bool outerCondition2 = map.containsKey("phone_number");
          if (outerCondition1 && outerCondition2) {
            final bool innerCondition1 = map["phone_code"] == phoneCode;
            final bool innerCondition2 = map["phone_number"] == phoneNumber;
            if (innerCondition1 && innerCondition2) {
              id = element.key ?? "";
            } else {}
          } else {
            log("getIdFromPhone() : Map doesn't containsKey: password");
          }
        } else {
          log("getIdFromPhone(): Map isEmpty");
        }
      } else {
        log("getIdFromPhone(): element.value is not Map");
      }
    }
    return Future<String>.value(id);
  }

  /* Data finding end */

  /* Data modification start */
  Future<void> updateAll() async {
    final DataSnapshot dataSnapshot = await ref.get();
    for (final DataSnapshot element in dataSnapshot.children) {
      if (element.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> map = <dynamic, dynamic>{};
        map = (element.value ?? <dynamic, dynamic>{}) as Map<dynamic, dynamic>;
        if (map.isNotEmpty) {
          final Map<String, dynamic> userModelToJson = <String, dynamic>{};
          /*final UserModel userModel = UserModel(
            fullName: "",
            birthDate: "",
            experience: 0,
            phoneCode: "",
            phoneNumber: "",
            emailAddress: "",
            password: "",
            isPremiumUser: false,
            isVerifiedByPhone: false,
            createdAt: "",
            updatedAt: "",
          );
          userModelToJson = userModel.toJson();*/
          await ref.child(element.key ?? "").update(userModelToJson);
        } else {
          log("updateAll(): Map isEmpty");
        }
      } else {
        log("updateAll(): element.value is not Map");
      }
    }
    return Future<void>.value();
  }

  Future<void> updateOne({
    required String key,
    required Map<String, dynamic> userModel,
  }) async {
    final DataSnapshot dataSnapshot = await ref.get();
    for (final DataSnapshot element in dataSnapshot.children) {
      if (element.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> map = <dynamic, dynamic>{};
        map = (element.value ?? <dynamic, dynamic>{}) as Map<dynamic, dynamic>;
        if (map.isNotEmpty) {
          if (element.key == key) {
            await ref.child(key).update(userModel);
          } else {
            log("updateOne() : Map doesn't containsKey: $key");
          }
        } else {
          log("updateOne(): Map isEmpty");
        }
      } else {
        log("updateOne(): element.value is not Map");
      }
    }
    return Future<void>.value();
  }

  /* Data modification end */

  /* Data removal start */
  Future<void> removeAll() async {
    final DataSnapshot dataSnapshot = await ref.get();
    for (final DataSnapshot element in dataSnapshot.children) {
      if (element.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> map = <dynamic, dynamic>{};
        map = (element.value ?? <dynamic, dynamic>{}) as Map<dynamic, dynamic>;
        if (map.isNotEmpty) {
          await ref.child(element.key ?? "").remove();
        } else {
          log("removeAll(): Map isEmpty");
        }
      } else {
        log("removeAll(): element.value is not Map");
      }
    }
    return Future<void>.value();
  }

  Future<void> removeOne({
    required String key,
  }) async {
    final DataSnapshot dataSnapshot = await ref.get();
    for (final DataSnapshot element in dataSnapshot.children) {
      if (element.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> map = <dynamic, dynamic>{};
        map = (element.value ?? <dynamic, dynamic>{}) as Map<dynamic, dynamic>;
        if (map.isNotEmpty) {
          if (element.key == key) {
            await ref.child(key).remove();
          } else {
            log("removeOne() : Map doesn't containsKey: $key");
          }
        } else {
          log("removeOne(): Map isEmpty");
        }
      } else {
        log("removeOne(): element.value is not Map");
      }
    }
    return Future<void>.value();
  }
/* Data removal end */
}
