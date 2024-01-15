import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionCheckerHelper {
  Future<bool> checkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    return true;
  }
}
