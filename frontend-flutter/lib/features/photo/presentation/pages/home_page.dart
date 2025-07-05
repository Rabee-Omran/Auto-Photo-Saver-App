import 'dart:io';
import 'package:auto_photo_saver_app/core/network/network_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/localization_extension.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/toast_utils.dart';
import '../bloc/photo_cubit.dart';
import '../../../../core/network/network_cubit.dart';
import '../widgets/network_status_icon.dart';
import '../widgets/photo_card.dart';
import '../widgets/empty_state.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';

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
                    if (!kIsWeb) ...[NetworkStatusIcon(), SizedBox(width: 12)],
                    IconButton(
                      icon: const Icon(Icons.settings),
                      tooltip: l10n.settings,
                      onPressed: () => context.push(Routes.settings),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: l10n.latestDownload,
                      onPressed:
                          (networkState.type == NetworkType.wifi ||
                              networkState.type == NetworkType.ethernet)
                          ? () => context.read<PhotoCubit>().fetchLatestPhoto()
                          : null,
                    ),
                    SizedBox(width: 12),
                  ],
                ),
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: BlocBuilder<PhotoCubit, PhotoState>(
                    builder: (context, photoState) {
                      if (photoState is PhotoLoaded) {
                        final photo = photoState.photo;
                        return SingleChildScrollView(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,

                              children: [PhotoCard(photo: photo)],
                            ),
                          ),
                        );
                      } else {
                        return Center(child: _mapStateToWidget(photoState));
                      }
                    },
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
        message: photoState.message,
        onRetry: () => context.read<PhotoCubit>().fetchLatestPhoto(),
      );
    } else if (photoState is PhotoNoInternetState) {
      return const EmptyState();
    } else {
      return const LoadingWidget();
    }
  }
}
