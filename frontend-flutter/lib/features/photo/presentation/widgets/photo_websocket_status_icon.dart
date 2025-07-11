import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/websocket_cubit.dart';
import '../../../photo/data/services/photo_websocket_service.dart';

class PhotoWebSocketStatusIcon extends StatelessWidget {
  const PhotoWebSocketStatusIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WebSocketCubit, WebSocketStatus>(
      builder: (context, status) {
        IconData icon = Icons.sync;
        Color color = Colors.orange;
        switch (status) {
          case WebSocketStatus.connecting:
            icon = Icons.sync;
            color = Colors.orange;
            break;
          case WebSocketStatus.connected:
            icon = Icons.check_circle_outline;
            color = Colors.green;
            break;
          case WebSocketStatus.disconnected:
            icon = Icons.wifi_off;
            color = Colors.red;
            break;
          case WebSocketStatus.error:
            icon = Icons.error_outline;
            color = Colors.red;
            break;
        }
        return Icon(icon, color: color, size: 20);
      },
    );
  }
}
