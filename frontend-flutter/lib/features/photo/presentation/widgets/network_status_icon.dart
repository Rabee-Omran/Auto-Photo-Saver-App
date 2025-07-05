import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/network_cubit.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/extensions/localization_extension.dart';
import '../../../../core/theme/app_colors.dart';

class NetworkStatusIcon extends StatelessWidget {
  const NetworkStatusIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkCubit, NetworkState>(
      builder: (context, state) {
        final l10n = context.l10n;
        String status;
        IconData icon;
        Color color;
        switch (state.type) {
          case NetworkType.wifi:
          case NetworkType.ethernet:
            status = l10n.wifiEthernet;
            icon = Icons.wifi;
            color = AppColors.success;
            break;
          case NetworkType.mobile:
            status = l10n.mobileData;
            icon = Icons.network_cell;
            color = AppColors.warning;
            break;
          case NetworkType.offline:
            status = l10n.offline;
            icon = Icons.signal_wifi_off;
            color = AppColors.error;
            break;
        }
        return Tooltip(
          message: '${l10n.networkStatus}: $status',
          child: Icon(icon, color: color),
        );
      },
    );
  }
}
