part of 'photo_cubit.dart';

abstract class PhotoState extends Equatable {
  final Photo? photo;
  const PhotoState({this.photo});
  @override
  List<Object?> get props => [photo];
}

class PhotoInitial extends PhotoState {
  const PhotoInitial({super.photo});
}

class PhotoLoading extends PhotoState {
  const PhotoLoading({super.photo});
}

class PhotoLoaded extends PhotoState {
  const PhotoLoaded(Photo photo) : super(photo: photo);
}

class PhotoImageSaved extends PhotoState {
  const PhotoImageSaved({super.photo});
}

class PhotoErrorState extends PhotoState {
  final String message;
  const PhotoErrorState({required this.message, super.photo});
  @override
  List<Object?> get props => [message, photo];
}

class PhotoNoInternetState extends PhotoState {
  const PhotoNoInternetState({super.photo});
}
