import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../domain/network_status.dart';

class InternetNetworkStatus implements NetworkStatus {
  @override
  Future<bool> get hasInternet async {
    if (kIsWeb) return true;
    try {
      return await InternetConnection().hasInternetAccess;
    } catch (_) {
      return false;
    }
  }
}
