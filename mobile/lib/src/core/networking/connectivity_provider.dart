import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus { isConnected, isDisconnected, initializing }

/// Simple connectivity provider using connectivity_plus
final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  return Connectivity().onConnectivityChanged.map((results) {
    // connectivity_plus 6.0 returns a List<ConnectivityResult>
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return ConnectivityStatus.isDisconnected;
    }
    return ConnectivityStatus.isConnected;
  });
});
