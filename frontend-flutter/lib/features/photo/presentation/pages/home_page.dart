import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/localization_extension.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/toast_utils.dart';
import '../bloc/photo_cubit/photo_cubit.dart';
import '../../../../core/network/network_cubit.dart';
import '../widgets/network_status_icon.dart';
import '../widgets/photo_card.dart';
import '../widgets/empty_state.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../widgets/photo_websocket_status_icon.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PhotoCubit>().loadLastPhotoFromStorage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<PhotoCubit, PhotoState>(
      builder: (context, photoState) {
        return BlocListener<PhotoCubit, PhotoState>(
          listener: (context, state) {
            if (state is PhotoNoInternetState) {
              ToastUtils.showNoInternetConnectionToast(context);
            } else if (state is PhotoErrorState) {
              ToastUtils.showErrorToast(context, state.message);
            } else if (state is PhotoImageSaved) {
              if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
                ToastUtils.showSuccessToast(
                  context,
                  context.l10n.imageSavedToGallery,
                );
              } else {
                ToastUtils.showSuccessToast(
                  context,
                  context.l10n.imageSavedToDownloads,
                );
              }
            }
          },
          child: BlocConsumer<NetworkCubit, NetworkState>(
            listener: (context, networkState) {
              context.read<PhotoCubit>().updateNetworkType(networkState.type);
            },
            builder: (context, networkState) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(l10n.appTitle),
                  actions: [
                    SizedBox(width: 12),
                    BlocBuilder<NetworkCubit, NetworkState>(
                      builder: (context, state) {
                        if (state.type == NetworkType.wifi ||
                            state.type == NetworkType.ethernet) {
                          return PhotoWebSocketStatusIcon();
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                    SizedBox(width: 12),
                    if (!kIsWeb) ...[NetworkStatusIcon(), SizedBox(width: 12)],
                    IconButton(
                      icon: const Icon(Icons.settings),
                      tooltip: l10n.settings,
                      onPressed: () => context.push(Routes.settings),
                    ),
                    SizedBox(width: 12),
                  ],
                ),
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: BlocBuilder<PhotoCubit, PhotoState>(
                          builder: (context, photoState) {
                            if (photoState.photo != null) {
                              final photo = photoState.photo;
                              return SingleChildScrollView(
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,

                                    children: [PhotoCard(photo: photo!)],
                                  ),
                                ),
                              );
                            } else {
                              return Center(
                                child: _mapStateToWidget(photoState),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  _mapStateToWidget(PhotoState photoState) {
    if (photoState is PhotoLoading) {
      return const LoadingWidget();
    } else if (photoState is PhotoErrorState) {
      return CustomErrorWidget(
        message: context.l10n.realTimeInfo,
        onRetry: null,
      );
    } else if (photoState is PhotoNoInternetState) {
      return const EmptyState();
    } else {
      return const LoadingWidget();
    }
  }
}
