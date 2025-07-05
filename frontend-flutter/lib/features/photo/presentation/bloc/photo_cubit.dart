// ignore_for_file: unused_field

import 'package:auto_photo_saver_app/core/constants/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:auto_photo_saver_app/core/services/shared_prefs_service.dart';
import '../../domain/entities/photo.dart';
import '../../domain/usecases/get_latest_photo.dart';
import '../../../../core/utils/gallery_saver_utils.dart';
import '../../../../core/error/failure.dart';
import 'dart:async';
import '../../../../core/network/network_info.dart';

part 'photo_state.dart';

class PhotoCubit extends Cubit<PhotoState> {
  final GetLatestPhoto getLatestPhoto;
  final SharedPrefsService sharedPrefsService;
  int? _lastPhotoId;
  Timer? _periodicTimer;

  PhotoCubit(this.getLatestPhoto, this.sharedPrefsService)
    : super(PhotoInitial());

  void startPeriodicFetch() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      fetchLatestPhoto(emitLoading: false);
    });
  }

  void stopPeriodicFetch() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  void updateNetworkType(NetworkType type) {
    if (type == NetworkType.wifi || type == NetworkType.ethernet) {
      fetchLatestPhoto(emitLoading: false);
      stopPeriodicFetch();
      startPeriodicFetch();
    } else {
      stopPeriodicFetch();
    }
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
      emit(
        PhotoLoaded(
          Photo(
            id: id,
            image: path,
            originalFileName: fileName,
            fileSize: fileSize,
            uploadedAt: DateTime.parse(uploadedAt),
            lastDownloadDate: lastDownloadDate,
          ),
        ),
      );
    }
  }

  Future<void> fetchLatestPhoto({bool emitLoading = true}) async {
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
    _periodicTimer?.cancel();
    return super.close();
  }
}
