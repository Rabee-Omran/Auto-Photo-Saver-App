import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../core/constants/constants.dart';
import '../models/photo_model.dart';

enum WebSocketStatus { connected, disconnected, connecting, error }

class PhotoWebSocketService {
  static const String _wsUrl = 'ws://localhost:8000/ws/photo/';
  WebSocketChannel? _channel;
  final _errorController = StreamController<String>.broadcast();
  final BehaviorSubject<WebSocketStatus> _statusController =
      BehaviorSubject.seeded(WebSocketStatus.disconnected);
  final _photoUpdatesController = StreamController<PhotoModel>.broadcast();
  StreamSubscription? _channelSubscription;
  bool _disposed = false;

  PhotoWebSocketService();

  void connect() {
    if (_disposed) return;
    _statusController.add(WebSocketStatus.connecting);
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      _statusController.add(WebSocketStatus.connected);
      _channelSubscription?.cancel();
      _channelSubscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
        cancelOnError: true,
      );
    } catch (e) {
      _handleError(e);
    }
  }

  void disconnect() {
    _statusController.add(WebSocketStatus.disconnected);
    _channelSubscription?.cancel();
    _channelSubscription = null;
    _channel?.sink.close();
    _channel = null;
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      if (data['type'] == 'photo_update' && data['image'] != null) {
        _photoUpdatesController.add(PhotoModel.fromJson(data['image']));
      }
    } catch (e) {
      _errorController.add('WebSocket message error: ${e.toString()}');
    }
  }

  void _handleError(dynamic error) {
    _statusController.add(WebSocketStatus.error);
    _errorController.add('WebSocket error: ${error.toString()}');
    _reconnect();
  }

  void _handleDisconnect() {
    _statusController.add(WebSocketStatus.disconnected);
    if (!_disposed) _reconnect();
  }

  void _reconnect() {
    if (_disposed) return;
    Future.delayed(const Duration(seconds: 5), () {
      if (!_disposed && _statusController.value == WebSocketStatus.error) {
        connect();
      }
    });
  }

  Stream<PhotoModel> get photoUpdates => _photoUpdatesController.stream;
  Stream<String> get errors => _errorController.stream;
  Stream<WebSocketStatus> get status => _statusController.stream;
  WebSocketStatus get currentStatus => _statusController.value;

  void dispose() {
    _disposed = true;
    disconnect();
    _errorController.close();
    _statusController.close();
    _photoUpdatesController.close();
  }
}
