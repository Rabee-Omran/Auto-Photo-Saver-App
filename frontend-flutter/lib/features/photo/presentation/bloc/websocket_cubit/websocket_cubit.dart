import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/photo_websocket_service.dart';

class WebSocketCubit extends Cubit<WebSocketStatus> {
  final PhotoWebSocketService webSocketService;
  late final StreamSubscription<WebSocketStatus> _statusSubscription;

  WebSocketCubit(this.webSocketService) : super(WebSocketStatus.disconnected) {
    _statusSubscription = webSocketService.status.listen(emit);
  }

  @override
  Future<void> close() {
    _statusSubscription.cancel();
    return super.close();
  }
}
