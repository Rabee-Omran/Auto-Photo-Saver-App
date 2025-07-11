// ignore_for_file: unused_field

import 'package:auto_photo_saver_app/core/constants/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:auto_photo_saver_app/core/services/shared_prefs_service.dart';
import '../../../../../core/error/failure.dart';
import '../../../domain/entities/photo.dart';
import '../../../../../core/utils/gallery_saver_utils.dart';
import 'dart:async';
import '../../../../../core/network/network_info.dart';
import '../../../data/services/photo_websocket_service.dart';
import '../../../data/models/photo_model.dart';
import '../../../domain/usecases/get_latest_photo.dart';

part 'photo_state.dart';

class PhotoCubit extends Cubit<PhotoState> {
  final SharedPrefsService sharedPrefsService;
  final PhotoWebSocketService webSocketService;
  final GetLatestPhoto getLatestPhoto;
  int? _lastPhotoId;
  Photo? _latestPhoto;
  StreamSubscription<PhotoModel>? _wsSubscription;
  StreamSubscription<String>? _wsErrorSubscription;

  PhotoCubit(
    this.sharedPrefsService,
    this.webSocketService,
    this.getLatestPhoto,
  ) : super(PhotoInitial());

  void updateNetworkType(NetworkType type) {
    debugPrint('Network type changed to: $type');
    if (type == NetworkType.wifi || type == NetworkType.ethernet) {
      _startWebSocket();
      _fetchLatestPhoto(); // Fetch latest photo when network becomes available
    } else {
      _stopWebSocket();
    }
  }

  void _startWebSocket() {
    debugPrint('Starting WebSocket');
    _stopWebSocket(); // Ensure no duplicate listeners

    // Connect WebSocket
    webSocketService.connect();

    // Listen to photo updates
    _wsSubscription = webSocketService.photoUpdates.listen((photoModel) async {
      debugPrint('Received WebSocket photo');
      final photo = photoModel.toEntity();
      if (_lastPhotoId == photo.id) return;
      _lastPhotoId = photo.id;
      _latestPhoto = photo;
      final lastDownloadDate = DateTime.now();
      try {
        final localPath = await GallerySaverUtils.saveImageToGallery(
          photo.image,
          photo.originalFileName,
        );
        await _saveLastPhoto(photo, localPath ? photo.image : null);
        if (localPath) {
          emit(
            PhotoImageSaved(
              photo: photo.copyWith(lastDownloadDate: lastDownloadDate),
            ),
          );
        }
      } catch (e) {
        emit(
          PhotoErrorState(
            message: Constants.serverErrorMessage,
            photo: photo.copyWith(lastDownloadDate: lastDownloadDate),
          ),
        );
      }
      emit(PhotoLoaded(photo.copyWith(lastDownloadDate: lastDownloadDate)));
    });

    // Listen to WebSocket errors
    _wsErrorSubscription = webSocketService.errors.listen((error) {
      emit(
        PhotoErrorState(
          message: Constants.serverErrorMessage,
          photo: _latestPhoto,
        ),
      );
    });
  }

  void _stopWebSocket() {
    debugPrint('Stopping WebSocket');
    _wsSubscription?.cancel();
    _wsSubscription = null;
    _wsErrorSubscription?.cancel();
    _wsErrorSubscription = null;
    webSocketService.disconnect();
  }

  Future<void> _fetchLatestPhoto({bool emitLoading = true}) async {
    if (emitLoading) {
      emit(PhotoLoading());
    }
    final result = await getLatestPhoto();
    result.fold((failure) => emit(_mapFailureToState(failure)), (photo) async {
      if (_lastPhotoId == photo.id) {
        final lastDownloadDate = sharedPrefsService.lastDownloadDate;
        emit(PhotoLoaded(photo.copyWith(lastDownloadDate: lastDownloadDate)));
        return;
      }

      _lastPhotoId = photo.id;
      final lastDownloadDate = DateTime.now();

      try {
        final localPath = await GallerySaverUtils.saveImageToGallery(
          photo.image,
          photo.originalFileName,
        );

        await _saveLastPhoto(photo, localPath ? photo.image : null);

        if (localPath) {
          emit(PhotoImageSaved());
        }
      } catch (e) {
        emit(PhotoErrorState(message: Constants.serverErrorMessage));
      }
      emit(PhotoLoaded(photo.copyWith(lastDownloadDate: lastDownloadDate)));
    });
  }

  Future<void> loadLastPhotoFromStorage() async {
    final prefs = sharedPrefsService;
    final id = prefs.lastPhotoId;
    final path = prefs.lastPhotoPath;
    final fileName = prefs.lastPhotoFileName;
    final uploadedAt = prefs.lastPhotoUploadedAt;
    final fileSize = prefs.lastPhotoFileSize;
    final lastDownloadDate = prefs.lastDownloadDate;
    if (id != null &&
        path != null &&
        fileName != null &&
        uploadedAt != null &&
        fileSize != null) {
      _lastPhotoId = id;
      _latestPhoto = Photo(
        id: id,
        image: path,
        originalFileName: fileName,
        fileSize: fileSize,
        uploadedAt: DateTime.parse(uploadedAt),
        lastDownloadDate: lastDownloadDate,
      );
      emit(PhotoLoaded(_latestPhoto!));
    }
  }

  Future<void> _saveLastPhoto(Photo photo, String? localPath) async {
    final prefs = sharedPrefsService;
    await prefs.setLastPhotoId(photo.id);
    await prefs.setLastPhotoPath(localPath ?? photo.image);
    await prefs.setLastPhotoFileName(photo.originalFileName);
    await prefs.setLastPhotoUploadedAt(photo.uploadedAt.toIso8601String());
    await prefs.setLastPhotoFileSize(photo.fileSize);
    await prefs.setLastDownloadDate(DateTime.now());
  }

  PhotoState _mapFailureToState(Failure failure) {
    if (failure is NoInternetConnectionFailure) {
      return PhotoNoInternetState();
    }
    return PhotoErrorState(message: failure.message);
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    _wsErrorSubscription?.cancel();
    return super.close();
  }
}
