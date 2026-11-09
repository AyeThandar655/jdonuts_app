import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'api_config.dart';

/// Answers "can we actually reach the internet right now?".
abstract interface class ConnectivityService {
  /// Emits the current reachability, then every change.
  Stream<bool> watchOnline();

  /// A one-off reachability check.
  Future<bool> isOnline();
}

/// connectivity_plus tells us an interface is up; a DNS / socket probe tells
/// us packets really flow (captive portals and airplane mode both fail it).
final class DeviceConnectivityService implements ConnectivityService {
  DeviceConnectivityService({
    required ApiConfig config,
    Connectivity? connectivity,
  })  : _config = config,
        _connectivity = connectivity ?? Connectivity();

  final ApiConfig _config;
  final Connectivity _connectivity;

  static const String _probeHost = 'one.one.one.one';
  static const Duration _probeTimeout = Duration(seconds: 3);

  @override
  Stream<bool> watchOnline() async* {
    yield await isOnline();
    await for (final results in _connectivity.onConnectivityChanged) {
      yield _hasInterface(results) && await _probe();
    }
  }

  @override
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return _hasInterface(results) && await _probe();
  }

  bool _hasInterface(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  Future<bool> _probe() async {
    final uri = Uri.tryParse(_config.baseUrl);
    try {
      if (_config.isConfigured && uri != null && uri.hasPort) {
        final socket =
            await Socket.connect(uri.host, uri.port, timeout: _probeTimeout);
        socket.destroy();
        return true;
      }
      final result =
          await InternetAddress.lookup(_probeHost).timeout(_probeTimeout);
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }
}

/// Always-online / always-offline service for tests.
final class FixedConnectivityService implements ConnectivityService {
  const FixedConnectivityService({required this.online});
  final bool online;

  @override
  Future<bool> isOnline() async => online;

  @override
  Stream<bool> watchOnline() => Stream<bool>.value(online);
}
