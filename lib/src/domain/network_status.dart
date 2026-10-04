/// Reports whether the device can reach the network.
abstract class NetworkStatus {
  /// Whether the device currently has internet access.
  Future<bool> get hasInternet;
}
