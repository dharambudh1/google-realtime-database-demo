import "package:connectivity_plus/connectivity_plus.dart";

class NetworkSingleton {
  factory NetworkSingleton() {
    return _singleton;
  }

  NetworkSingleton._internal();

  static final NetworkSingleton _singleton = NetworkSingleton._internal();

  Future<bool> isConnected() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();
    switch (result) {
      case ConnectivityResult.bluetooth:
        return Future<bool>.value(false);
      case ConnectivityResult.wifi:
        return Future<bool>.value(true);
      case ConnectivityResult.ethernet:
        return Future<bool>.value(true);
      case ConnectivityResult.mobile:
        return Future<bool>.value(true);
      case ConnectivityResult.none:
        return Future<bool>.value(false);
      case ConnectivityResult.vpn:
        return Future<bool>.value(true);
    }
  }
}
