import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum NetworkType { wifi, ethernet, mobile, offline }

class NetworkInfo {
  static const _channel = MethodChannel('com.rabee.omran.network');
  static const _eventChannel = EventChannel('com.rabee.omran.network/events');

  Future<NetworkType> getCurrentNetworkType() async {
    if (kIsWeb) {
      return NetworkType.wifi;
    }
    final String type = await _channel.invokeMethod('getNetworkType');
    return _parseType(type);
  }

  Stream<NetworkType> get onNetworkChanged => kIsWeb
      ? Stream.value(NetworkType.wifi)
      : _eventChannel.receiveBroadcastStream().map(
          (event) => _parseType(event as String),
        );

  NetworkType _parseType(String type) {
    switch (type) {
      case 'wifi':
        return NetworkType.wifi;
      case 'ethernet':
        return NetworkType.ethernet;
      case 'mobile':
        return NetworkType.mobile;
      default:
        return NetworkType.offline;
    }
  }
}
