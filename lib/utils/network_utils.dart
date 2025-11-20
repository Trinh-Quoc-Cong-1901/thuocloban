import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUtils {
  static final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connection
  static bool _hasConnection = true;

  /// Initialize network monitoring
  static Future<void> init() async {
    // Check initial connectivity
    _hasConnection = await hasInternetConnection();

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((_) async {
      _hasConnection = await hasInternetConnection();
    });
  }

  /// Get current connection status (synchronous)
  static bool get hasConnection => _hasConnection;

  /// Check for actual internet connectivity (asynchronous)
  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final connectivityResult = _primaryConnectivityResult(connectivityResults);

      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Try to ping a reliable server
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get connectivity type
  static Future<ConnectivityResult> getConnectivityType() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    return _primaryConnectivityResult(connectivityResults);
  }

  /// Check if connected to WiFi
  static Future<bool> isConnectedToWiFi() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    return connectivityResults.contains(ConnectivityResult.wifi);
  }

  /// Check if connected to mobile data
  static Future<bool> isConnectedToMobile() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    return connectivityResults.contains(ConnectivityResult.mobile);
  }

  /// Get connection status as string
  static Future<String> getConnectionStatus() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    final connectivityResult = _primaryConnectivityResult(connectivityResults);

    switch (connectivityResult) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'No Connection';
    }
  }

  /// Stream of connectivity changes
  static Stream<ConnectivityResult> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(_primaryConnectivityResult);

  /// Test connection to specific host
  static Future<bool> canReachHost(
    String host, {
    int port = 80,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get network connection details
  static Future<Map<String, dynamic>> getNetworkInfo() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    final hasInternet = await hasInternetConnection();
    final status = await getConnectionStatus();

    return {
      'hasConnection': hasInternet,
      'connectionType':
          _primaryConnectivityResult(connectivityResults).name,
      'connectionStatus': status,
      'isWiFi': connectivityResults.contains(ConnectivityResult.wifi),
      'isMobile': connectivityResults.contains(ConnectivityResult.mobile),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  static ConnectivityResult _primaryConnectivityResult(
      List<ConnectivityResult> results) {
    if (results.isEmpty) {
      return ConnectivityResult.none;
    }

    final detected = results.toSet();
    const priority = [
      ConnectivityResult.wifi,
      ConnectivityResult.ethernet,
      ConnectivityResult.mobile,
      ConnectivityResult.vpn,
      ConnectivityResult.bluetooth,
      ConnectivityResult.other,
      ConnectivityResult.none,
    ];

    for (final type in priority) {
      if (detected.contains(type)) {
        return type;
      }
    }

    return results.first;
  }
}
